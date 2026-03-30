import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LaptopSvgWidget extends StatelessWidget {
  final String bgColor;
  final String screenColor;
  final double width;

  const LaptopSvgWidget({
    super.key,
    required this.bgColor,
    required this.screenColor,
    this.width = 140,
  });

  String _buildSvg() => '''
<svg width="${width}" viewBox="0 0 220 140" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="5" width="200" height="118" rx="9" fill="$bgColor"/>
  <rect x="16" y="11" width="188" height="106" rx="6" fill="$screenColor" opacity="0.85"/>
  <rect x="0" y="124" width="220" height="11" rx="3" fill="$bgColor"/>
  <rect x="80" y="131" width="60" height="4" rx="2" fill="rgba(0,0,0,0.2)"/>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      _buildSvg(),
      width: width,
    );
  }
}

class HeroLaptopWidget extends StatelessWidget {
  final double width;
  const HeroLaptopWidget({super.key, this.width = 300});

  @override
  Widget build(BuildContext context) {
    const svgString = '''
<svg width="340" viewBox="0 0 340 230" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="28" y="8" width="284" height="182" rx="11" fill="#0d0d0d"/>
  <rect x="34" y="14" width="272" height="170" rx="8" fill="#141420"/>
  <rect x="50" y="30" width="70" height="7" rx="3.5" fill="rgba(255,255,255,0.14)"/>
  <rect x="50" y="46" width="120" height="4" rx="2" fill="rgba(255,255,255,0.06)"/>
  <rect x="196" y="44" width="94" height="64" rx="9" fill="rgba(26,26,255,0.18)"/>
  <rect x="204" y="52" width="78" height="8" rx="4" fill="rgba(255,255,255,0.12)"/>
  <rect x="50" y="78" width="128" height="72" rx="8" fill="rgba(255,255,255,0.03)"/>
  <rect x="18" y="188" width="304" height="6" rx="3" fill="#1a1a1a"/>
  <path d="M8 194 L18 194 L322 194 L332 194 L342 222 H0 Z" fill="#0e0e0e"/>
  <rect x="128" y="210" width="84" height="4" rx="2" fill="#1e1e1e"/>
  <circle cx="170" cy="18" r="3.5" fill="#1c1c1c"/>
</svg>
''';
    return SvgPicture.string(svgString, width: width);
  }
}

// Logo SVG as a widget
class LogoWidget extends StatelessWidget {
  final double size;
  const LogoWidget({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    const svgString = '''
<svg width="36" height="36" viewBox="0 0 36 36" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M4 30 C4 16 32 16 32 30" stroke="#0a0a0a" stroke-width="2.2" fill="none" stroke-linecap="round"/>
  <line x1="4" y1="30" x2="4" y2="34" stroke="#0a0a0a" stroke-width="2.2" stroke-linecap="round"/>
  <line x1="32" y1="30" x2="32" y2="34" stroke="#0a0a0a" stroke-width="2.2" stroke-linecap="round"/>
  <line x1="2" y1="34" x2="34" y2="34" stroke="#0a0a0a" stroke-width="2.2" stroke-linecap="round"/>
  <rect x="11" y="19" width="14" height="9" rx="1.5" fill="#0a0a0a"/>
  <rect x="12" y="20" width="12" height="7" rx="1" fill="#1a1aff"/>
  <rect x="8" y="28" width="20" height="2" rx="1" fill="#0a0a0a"/>
</svg>
''';
    return SvgPicture.string(svgString, width: size, height: size);
  }
}
