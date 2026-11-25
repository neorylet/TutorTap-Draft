// Cloudinary orphan purge for TutorTap.
// Lists assets under CLOUDINARY_PREFIX, compares them with every URL and
// publicId still referenced anywhere in Firestore, and destroys the rest.
//
// Dry run by default - nothing is deleted without --delete.
//
//   cd tool
//   npm install firebase-admin
//   $env:CLOUDINARY_CLOUD_NAME = "lyz8sp5z"
//   $env:CLOUDINARY_API_KEY = "<api key>"
//   $env:CLOUDINARY_API_SECRET = "<api secret>"
//   $env:GOOGLE_APPLICATION_CREDENTIALS = "C:\keys\tutortap-service-account.json"
//
//   node purge_cloudinary.mjs
//   node purge_cloudinary.mjs --delete
//
// Assets younger than MIN_AGE_HOURS (default 24) are never touched: an upload
// reaches Cloudinary before the module document is saved, so a brand new asset
// can look unreferenced while the save is still in flight.

import { readFileSync } from 'node:fs';
import { cert, initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

const CLOUD = process.env.CLOUDINARY_CLOUD_NAME;
const KEY = process.env.CLOUDINARY_API_KEY;
const SECRET = process.env.CLOUDINARY_API_SECRET;
const SA_PATH = process.env.GOOGLE_APPLICATION_CREDENTIALS;
const ALL_PREFIXES = process.argv.includes('--all-prefixes');
const PREFIX = ALL_PREFIXES ? '' : (process.env.CLOUDINARY_PREFIX ?? 'tutortap/modules/');
const MIN_AGE_HOURS = Number(process.env.MIN_AGE_HOURS ?? 24);
const DELETE = process.argv.includes('--delete');

for (const [name, value] of Object.entries({
  CLOUDINARY_CLOUD_NAME: CLOUD,
  CLOUDINARY_API_KEY: KEY,
  CLOUDINARY_API_SECRET: SECRET,
  GOOGLE_APPLICATION_CREDENTIALS: SA_PATH,
})) {
  if (!value) {
    console.error('missing env var ' + name);
    process.exit(1);
  }
}

const auth = 'Basic ' + Buffer.from(KEY + ':' + SECRET).toString('base64');

function urlCandidates(set, url) {
  if (!url) return;
  const at = url.indexOf('/upload/');
  if (at < 0) return;
  let path = decodeURIComponent(url.slice(at + 8));
  const firstSlash = path.indexOf('/');
  if (firstSlash > 0 && /^v[0-9]+$/.test(path.slice(0, firstSlash))) {
    path = path.slice(firstSlash + 1);
  }
  set.add(path); // raw assets keep the extension
  const dot = path.lastIndexOf('.');
  const slash = path.lastIndexOf('/');
  if (dot > slash) set.add(path.slice(0, dot)); // image assets drop it
}

async function listAll(resourceType) {
  const out = [];
  let cursor;
  do {
    const url = new URL('https://api.cloudinary.com/v1_1/' + CLOUD + '/resources/' + resourceType + '/upload');
    if (PREFIX) url.searchParams.set('prefix', PREFIX);
    url.searchParams.set('max_results', '500');
    if (cursor) url.searchParams.set('next_cursor', cursor);
    const res = await fetch(url, { headers: { Authorization: auth } });
    if (!res.ok) throw new Error(resourceType + ' list failed: ' + res.status + ' ' + (await res.text()));
    const data = await res.json();
    for (const resource of data.resources) out.push({ ...resource, resource_type: resourceType });
    cursor = data.next_cursor;
  } while (cursor);
  return out;
}

async function destroy(resourceType, publicIds) {
  const url = new URL('https://api.cloudinary.com/v1_1/' + CLOUD + '/resources/' + resourceType + '/upload');
  for (const id of publicIds) url.searchParams.append('public_ids[]', id);
  const res = await fetch(url, { method: 'DELETE', headers: { Authorization: auth } });
  if (!res.ok) throw new Error('delete ' + resourceType + ' failed: ' + res.status + ' ' + (await res.text()));
  return res.json();
}

const app = initializeApp({
  credential: cert(JSON.parse(readFileSync(SA_PATH, 'utf8'))),
});
const db = getFirestore(app);

const referenced = new Set();
let docsScanned = 0;
let collectionsScanned = 0;

function harvest(value) {
  if (typeof value === 'string') {
    if (value.indexOf('/upload/') >= 0) urlCandidates(referenced, value);
    return;
  }
  if (Array.isArray(value)) {
    for (const item of value) harvest(item);
    return;
  }
  if (value && typeof value === 'object') {
    for (const item of Object.values(value)) harvest(item);
  }
}

for (const collection of await db.listCollections()) {
  collectionsScanned += 1;
  const snapshot = await collection.get();
  for (const doc of snapshot.docs) {
    docsScanned += 1;
    harvest(doc.data());
  }
}

if (docsScanned === 0) {
  console.error('No documents found - refusing to run. Wrong project in the service account?');
  process.exit(1);
}

console.log(docsScanned + ' docs in ' + collectionsScanned + ' collections, ' + referenced.size + ' referenced ids, prefix ' + (PREFIX || '(whole account)'));

const assets = [...(await listAll('image')), ...(await listAll('raw'))];
const cutoff = Date.now() - MIN_AGE_HOURS * 3600000;
const unreferenced = assets.filter((a) => !referenced.has(a.public_id));
const fresh = unreferenced.filter((a) => Date.parse(a.created_at) >= cutoff);
const orphans = unreferenced.filter((a) => Date.parse(a.created_at) < cutoff);

console.log(assets.length + ' assets found, ' + unreferenced.length + ' unreferenced: ' + orphans.length + ' deletable, ' + fresh.length + ' held back (younger than ' + MIN_AGE_HOURS + 'h)');

let bytes = 0;
for (const a of unreferenced) {
  const held = fresh.includes(a);
  if (!held) bytes += a.bytes;
  const mb = (a.bytes / 1048576).toFixed(2);
  const days = Math.floor((Date.now() - Date.parse(a.created_at)) / 86400000);
  console.log('  ' + (held ? 'HOLD' : 'DEL ') + '  ' + a.resource_type.padEnd(5) + mb.padStart(8) + ' MB  ' + String(days).padStart(4) + 'd  ' + a.public_id);
}
console.log('reclaimable now: ' + (bytes / 1048576).toFixed(2) + ' MB');

if (!DELETE) {
  console.log("");
  console.log('Dry run. Re-run with --delete to destroy the assets above.');
  process.exit(0);
}
if (orphans.length === 0) process.exit(0);

for (const resourceType of ['image', 'raw']) {
  const ids = orphans.filter((a) => a.resource_type === resourceType).map((a) => a.public_id);
  for (let i = 0; i < ids.length; i += 100) {
    const batch = ids.slice(i, i + 100);
    await destroy(resourceType, batch);
    console.log('deleted ' + batch.length + ' ' + resourceType + ' asset(s)');
  }
}
console.log('done');
