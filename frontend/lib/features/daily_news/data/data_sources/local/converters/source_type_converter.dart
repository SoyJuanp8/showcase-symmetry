import 'dart:convert';
import 'package:floor/floor.dart';
import '../../../../domain/entities/source.dart';

class SourceTypeConverter extends TypeConverter<Source?, String?> {
  @override
  Source? decode(String? databaseValue) {
    if (databaseValue == null) {
      return null;
    }
    final Map<String, dynamic> map = json.decode(databaseValue);
    return Source(
      id: map['id'],
      name: map['name'],
    );
  }

  @override
  String? encode(Source? value) {
    if (value == null) {
      return null;
    }
    return json.encode({
      'id': value.id,
      'name': value.name,
    });
  }
}
