import 'package:flutter/material.dart';

import '../../domain/entities/content_category.dart';

class ContentCategoryIcon {
  static IconData iconFor(ContentCategory category) {
    return switch (category) {
      ContentCategory.url => Icons.language,
      ContentCategory.email => Icons.email_outlined,
      ContentCategory.phone => Icons.phone_outlined,
      ContentCategory.color => Icons.palette_outlined,
      ContentCategory.code => Icons.code,
      ContentCategory.image => Icons.image_outlined,
      ContentCategory.text => Icons.notes,
    };
  }

  static String labelFor(ContentCategory category) {
    return switch (category) {
      ContentCategory.url => 'URL',
      ContentCategory.email => 'Email',
      ContentCategory.phone => 'Phone',
      ContentCategory.color => 'Color',
      ContentCategory.code => 'Code',
      ContentCategory.image => 'Image',
      ContentCategory.text => 'Text',
    };
  }
}
