import 'package:flutter/material.dart';

IconData iconForModuleFile(String type) {
  switch (type.toLowerCase()) {
    case 'pdf':
      return Icons.picture_as_pdf;
    case 'ppt':
    case 'pptx':
      return Icons.slideshow;
    case 'doc':
    case 'docx':
      return Icons.description;
    case 'image':
    case 'png':
    case 'jpg':
    case 'jpeg':
      return Icons.image_outlined;
    default:
      return Icons.attach_file;
  }
}
