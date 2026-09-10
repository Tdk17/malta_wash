import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 64, this.logoUrl});
  final double size;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    final image = logoUrl != null && logoUrl!.isNotEmpty
        ? Image.network(logoUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _local())
        : _local();
    return ClipOval(child: SizedBox(width: size, height: size, child: image));
  }

  Widget _local() => Image.asset('assets/branding/clinicar_logo.png', fit: BoxFit.cover);
}
