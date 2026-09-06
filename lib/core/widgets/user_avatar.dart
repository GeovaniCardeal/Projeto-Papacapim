import 'dart:io';
import 'package:flutter/material.dart';
import '../../app/theme.dart';

class UserAvatar extends StatelessWidget {
  final double radius;
  final File? imageFile;
  final String? imageUrl;

  const UserAvatar({
    super.key,
    this.radius = 32,
    this.imageFile,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? provider;

    if (imageFile != null) {
      provider = FileImage(imageFile!);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      provider = NetworkImage(imageUrl!);
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.border,
      backgroundImage: provider,
      child: provider == null
          ? Icon(Icons.person_outline, size: radius, color: Colors.white)
          : null,
    );
  }
}
