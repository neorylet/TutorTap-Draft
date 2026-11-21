import 'package:cloud_firestore/cloud_firestore.dart';

const Object kUnset = Object();

DateTime? dateTimeFromFirestore(Object? value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

Object? dateTimeToFirestore(DateTime? value) =>
    value == null ? null : Timestamp.fromDate(value);

double doubleFrom(Object? value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

int intFrom(Object? value, [int fallback = 0]) {
  if (value is num) return value.round();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

String stringFrom(Object? value, [String fallback = '']) =>
    value == null ? fallback : value.toString();

bool boolFrom(Object? value, [bool fallback = false]) {
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  return fallback;
}

List<String> stringListFrom(Object? value) {
  if (value is! List) return const <String>[];
  return value.map((dynamic item) => item.toString()).toList(growable: true);
}

List<Map<String, dynamic>> mapListFrom(Object? value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value
      .whereType<Map>()
      .map((Map item) => Map<String, dynamic>.from(item))
      .toList(growable: true);
}

Map<String, dynamic> mapFrom(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

T enumFrom<T>(Object? value, Map<String, T> values, T fallback) {
  final String? key = value?.toString().toLowerCase();
  if (key == null) return fallback;
  return values[key] ?? fallback;
}
