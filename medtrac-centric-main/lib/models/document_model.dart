class Document {
  final String id;
  final String name;
  final DateTime createdAt;
  final String type;
  final bool isShared;

  const Document({
    required this.id, 
    required this.name,
    required this.createdAt,
    required this.type,
    this.isShared = false,
  });
}