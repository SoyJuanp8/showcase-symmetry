import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? profileImageUrl;
  final String? userName;
  final double radius;
  final double fontSize;

  const UserAvatar({
    super.key,
    this.profileImageUrl,
    this.userName,
    this.radius = 20,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    // Check if we have a valid image URL (not null, not empty, not default placeholder)
    final bool hasValidImage = profileImageUrl != null &&
        profileImageUrl!.isNotEmpty &&
        !profileImageUrl!
            .contains('cdn-icons-png') && // Avoid the upload placeholder
        !profileImageUrl!.contains(
            'pravatar'); // Avoid the random placeholder if we still had it

    if (hasValidImage) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(profileImageUrl!),
        backgroundColor: Colors.grey.shade200,
        onBackgroundImageError: (_, __) {
          // Fallback handled by not showing anything or showing standard placeholder
        },
      );
    }

    // Fallback: Initials on Blue Background
    String initial = 'U';
    if (userName != null && userName!.isNotEmpty) {
      initial = userName![0].toUpperCase();
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF3A4A7D), // Primary Blue
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
