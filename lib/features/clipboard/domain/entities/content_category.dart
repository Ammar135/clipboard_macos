enum ContentCategory {
  text,
  image,
  url,
  email,
  phone,
  color,
  code;

  String get storageValue => name;

  static ContentCategory fromStorage(String value) {
    for (final category in ContentCategory.values) {
      if (category.storageValue == value) {
        return category;
      }
    }
    return ContentCategory.text;
  }
}
