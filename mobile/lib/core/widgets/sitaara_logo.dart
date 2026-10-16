import 'package:flutter/material.dart';

class SitaaraLogo extends StatelessWidget {
  const SitaaraLogo({super.key, this.width = 174, this.onDark = false});

  final double width;
  final bool onDark;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: 'Sitaara',
    child: Image.asset(
      onDark
          ? 'assets/images/sitaara_logo_primary.png'
          : 'assets/images/sitaara_logo_alternate.png',
      width: width,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    ),
  );
}
