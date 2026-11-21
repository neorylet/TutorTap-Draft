abstract final class CloudinaryConfig {
  static const String cloudName = 'YOUR_CLOUD_NAME';
  static const String unsignedUploadPreset = 'tutortap_unsigned';

  static Uri uploadUri() => Uri.parse(
    'https://api.cloudinary.com/v1_1/$cloudName/auto/upload',
  );

  static String avatarFolder(String uid) => 'tutortap/avatars/$uid';

  static String credentialFolder(String uid) => 'tutortap/credentials/$uid';

  static String moduleFolder(String tutorId) => 'tutortap/modules/$tutorId';

  static String submissionFolder(String assignmentId) =>
      'tutortap/submissions/$assignmentId';

  static String avatarUrl(String secureUrl) => _transform(
    secureUrl,
    'w_200,h_200,c_fill,g_face,q_auto,f_auto',
  );

  static String thumbnailUrl(String secureUrl) =>
      _transform(secureUrl, 'w_400,q_auto,f_auto');

  static String _transform(String secureUrl, String transformation) {
    if (secureUrl.isEmpty || !secureUrl.contains('/upload/')) {
      return secureUrl;
    }
    return secureUrl.replaceFirst(
      '/upload/',
      '/upload/$transformation/',
    );
  }
}
