import 'package:flutter/material.dart';

class CoffeeAppLogo extends StatelessWidget {
  const CoffeeAppLogo({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.local_cafe, color: Colors.orange[800], size: size),
    );
  }
}
