import 'package:flutter/material.dart';
import 'dart:io';
import '../../app/theme.dart';

/// Avatar circular. Aceita um caminho de arquivo local (File, usado depois de
/// tirar foto/escolher da galeria) ou cai num ícone padrão quando não há foto.
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
    if (imageFile != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.border,
        backgroundImage: FileImage(imageFile!),
      );
    }
    if (imageUrl != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.border,
        backgroundImage: AssetImage(imageUrl!),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.border,
      child: Icon(Icons.person_outline, size: radius, color: Colors.white),
    );
  }
}
