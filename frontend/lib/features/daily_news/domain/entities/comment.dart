import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String? id;
  final String? userId; // ID of the user who commented
  final String? userName; // Display name of the user
  final String? userAvatar; // Avatar URL of the user
  final String? text;
  final String? createdAt; // ISO8601 string

  const CommentEntity({
    this.id,
    this.userId,
    this.userName,
    this.userAvatar,
    this.text,
    this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, userId, userName, userAvatar, text, createdAt];
}
