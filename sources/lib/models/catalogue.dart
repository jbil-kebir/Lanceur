class CatalogueRaccourci {
  final String id;
  final String label;
  final String url;

  const CatalogueRaccourci({
    required this.id,
    required this.label,
    required this.url,
  });

  factory CatalogueRaccourci.fromJson(Map<String, dynamic> json) {
    return CatalogueRaccourci(
      id: json['id'] as String,
      label: json['label'] as String,
      url: json['url'] as String,
    );
  }
}

class CatalogueCategorie {
  final String id;
  final String label;
  final List<CatalogueRaccourci> shortcuts;

  const CatalogueCategorie({
    required this.id,
    required this.label,
    required this.shortcuts,
  });

  factory CatalogueCategorie.fromJson(Map<String, dynamic> json) {
    final shortcuts = (json['shortcuts'] as List)
        .map((s) => CatalogueRaccourci.fromJson(s as Map<String, dynamic>))
        .toList();
    return CatalogueCategorie(
      id: json['id'] as String,
      label: json['label'] as String,
      shortcuts: shortcuts,
    );
  }
}
