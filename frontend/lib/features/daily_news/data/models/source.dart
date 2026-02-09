import '../../domain/entities/source.dart';

class SourceModel extends Source {
  const SourceModel({
    String? id,
    String? name,
  }) : super(id: id, name: name);

  factory SourceModel.fromJson(Map<String, dynamic> map) {
    return SourceModel(
      id: map['id'] ?? "",
      name: map['name'] ?? "",
    );
  }
}
