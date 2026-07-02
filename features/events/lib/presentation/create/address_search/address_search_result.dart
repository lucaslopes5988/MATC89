class AddressSearchResult {
  const AddressSearchResult({
    required this.title,
    required this.subtitle,
    required this.latitude,
    required this.longitude,
  });

  final String title;
  final String subtitle;
  final double latitude;
  final double longitude;

  String get displayText {
    if (subtitle.trim().isEmpty || subtitle.trim() == title.trim()) {
      return title;
    }
    return '$title, $subtitle';
  }
}
