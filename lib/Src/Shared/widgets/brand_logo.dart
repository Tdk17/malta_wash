import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 64, this.logoUrl});
  final double size;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * .28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6A00), Color(0xFF2563EB)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6A00).withOpacity(.20),
            blurRadius: size * .28,
            offset: Offset(0, size * .10),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        'MW',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * .30,
          fontWeight: FontWeight.w900,
          letterSpacing: -1,
        ),
      ),
    );
  }
}
