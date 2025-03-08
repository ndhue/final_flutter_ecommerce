class Category {
  final String id;
  final String name;
  final String description;
  final String icon;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['fields']['id']['stringValue'],
      name: json['fields']['name']['stringValue'],
      description: json['fields']['description']['stringValue'],
      icon: json['fields']['icon']['stringValue'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "fields": {
        "id": {"stringValue": id},
        "name": {"stringValue": name},
        "description": {"stringValue": description},
        "icon": {"stringValue": icon},
      },
    };
  }
}
