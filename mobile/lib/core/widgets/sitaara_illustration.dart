import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SitaaraIllustration extends StatelessWidget {
  const SitaaraIllustration(
    this.name, {
    super.key,
    this.height = 180,
    this.semanticLabel,
  });

  final String name;
  final double height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    'assets/illustrations/$name.svg',
    height: height,
    fit: BoxFit.contain,
    semanticsLabel: semanticLabel,
  );
}

String childIllustrationFor(DateTime dateOfBirth) {
  final days = DateTime.now().difference(dateOfBirth).inDays;
  if (days < 540) return 'child_baby';
  if (days < 1095) return 'child_toddler';
  return 'child_preschool';
}
