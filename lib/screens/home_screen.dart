import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../services/product_service.dart';
import '../theme.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/laptop_svg_widget.dart';
import '../widgets/auth_bottom_sheet.dart';

const _categories = [
  {'name': 'Gaming',    'count': 340, 'icon': Icons.sports_esports_outlined,   'brands': ['ASUS ROG','MSI','Razer','Lenovo LOQ']},
  {'name': 'Business',  'count': 218, 'icon': Icons.work_outline,               'brands': ['Lenovo','Dell','HP EliteBook','Microsoft']},
  {'name': 'Creator',   'count': 129, 'icon': Icons.brush_outlined,             'brands': ['Apple','Dell XPS','HP Spectre','Huawei']},
  {'name': 'Student',   'count': 412, 'icon': Icons.school_outlined,            'brands': ['HP','Lenovo IdeaPad','Acer Aspire','ASUS']},
  {'name': 'Ultrabook', 'count': 187, 'icon': Icons.laptop_outlined,            'brands': ['Dell XPS','ASUS ZenBook','LG Gram','Samsung']},
  {'name': 'Budget',    'count': 296, 'icon': Icons.savings_outlined,           'brands': ['Acer','HP Pavilion','Lenovo IdeaPad','ASUS']},
];

const _brands = ['Dell','Apple','Lenovo','ASUS','HP','Acer','MSI','Razer','Samsung','LG','Microsoft','Huawei'];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  List<Product> _featured = [];
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }
  @override void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    final p = await ProductService.getFeatured();
    if (mounted) setState(() { _featured = p; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const AppNavBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(children: [
          _HeroSection(ctrl: _searchCtrl, onSearch: () {
            final q = _searchCtrl.text.trim();
            context.go(q.isNotEmpty ? '/products?q=${Uri.encodeComponent(q)}' : '/products');
          }),
          const _MarqueeStrip(),
          _RevealSection(child: _CategorySection()),
          _RevealSection(child: _FeaturedSection(products: _featured, loading: _loading)),
          _RevealSection(child: const _WhySection()),
          const AppFooter(),
        ]),
      ),
    );
  }
}

// ─── Scroll reveal wrapper ────────────────────────────────────────────────────
class _RevealSection extends StatefulWidget {
  final Widget child;
  const _RevealSection({required this.child});
  @override State<_RevealSection> createState() => _RevealSectionState();
}
class _RevealSectionState extends State<_RevealSection> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    // Auto-trigger — in production use visibility_detector
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _opacity,
    child: SlideTransition(position: _slide, child: widget.child),
  );
}

// ─── Hero ─────────────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final TextEditingController ctrl;
  final VoidCallback onSearch;
  const _HeroSection({required this.ctrl, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w > 900;

    return Container(
      color: AppColors.bg,
      constraints: BoxConstraints(minHeight: isWide ? MediaQuery.of(context).size.height - 66 : 0),
      child: Stack(children: [
        // Grid background
        Positioned.fill(child: CustomPaint(painter: _GridPainter())),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 80 : w > 600 ? 40 : 20,
            vertical: isWide ? 0 : 40,
          ),
          child: isWide
              ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Expanded(flex: 5, child: _HeroText(ctrl: ctrl, onSearch: onSearch)),
                  const SizedBox(width: 32),
                  Expanded(flex: 4, child: _HeroVisual()),
                ])
              : Column(children: [
                  _HeroText(ctrl: ctrl, onSearch: onSearch),
                  const SizedBox(height: 48),
                  _HeroVisual(),
                  const SizedBox(height: 40),
                ]),
        ),
      ]),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x07000000)
      ..strokeWidth = 1;
    const step = 56.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override bool shouldRepaint(_) => false;
}

class _HeroText extends StatelessWidget {
  final TextEditingController ctrl;
  final VoidCallback onSearch;
  const _HeroText({required this.ctrl, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final fs = w > 1200 ? 78.0 : w > 900 ? 62.0 : w > 600 ? 52.0 : 42.0;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Eyebrow
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xB3FFFFFF),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: AppColors.border2),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _BlinkDot(),
          const SizedBox(width: 8),
          Text('2026 COLLECTION — NOW LIVE', style: GoogleFonts.jetBrainsMono(
              fontSize: 11, color: AppColors.ink3, letterSpacing: 0.06)),
        ]),
      ),
      const SizedBox(height: 28),
      // H1
      RichText(
        text: TextSpan(
          style: GoogleFonts.syne(
            fontSize: fs, fontWeight: FontWeight.w800,
            letterSpacing: -2.5, color: AppColors.ink, height: 0.98,
          ),
        children: [
  TextSpan(text: 'Find Your\n'),
  TextSpan(text: 'Perfect', style: TextStyle(color: AppColors.accent)),
  TextSpan(text: '\nMachine.'),
],
        ),
      ),
      const SizedBox(height: 24),
      Text(
        'Premium laptops for every ambition. Gaming, business, design, student — curated, compared, delivered.',
        style: GoogleFonts.dmSans(
            fontSize: 16, fontWeight: FontWeight.w300,
            color: AppColors.ink3, height: 1.7),
      ),
      const SizedBox(height: 36),
      // Search pill
      Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: const Color(0xA6FFFFFF),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: const Color(0xCCFFFFFF)),
          boxShadow: const [
            BoxShadow(color: Color(0x12000000), blurRadius: 28, offset: Offset(0, 4)),
          ],
        ),
        padding: const EdgeInsets.all(5),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: ctrl,
              onSubmitted: (_) => onSearch(),
              style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.ink),
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                hintText: 'Search laptops, brands, specs...',
                hintStyle: GoogleFonts.dmSans(fontSize: 14, color: AppColors.ink3),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                isDense: true,
              ),
            ),
          ),
          _SearchBtn(onTap: onSearch),
        ]),
      ),
      const SizedBox(height: 44),
      // Stats
      Row(mainAxisSize: MainAxisSize.min, children: [
        _Stat('2,400+', 'Products'),
        Container(width: 1, height: 36, color: AppColors.border2,
            margin: const EdgeInsets.symmetric(horizontal: 24)),
        _Stat('48', 'Brands'),
        Container(width: 1, height: 36, color: AppColors.border2,
            margin: const EdgeInsets.symmetric(horizontal: 24)),
        _Stat('98%', 'Satisfaction'),
      ]),
    ]);
  }
}

class _BlinkDot extends StatefulWidget {
  @override State<_BlinkDot> createState() => _BlinkDotState();
}
class _BlinkDotState extends State<_BlinkDot> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(); }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, __) => Opacity(
      opacity: (_c.value < 0.5) ? (1 - _c.value * 2) * 0.7 + 0.3 : (_c.value - 0.5) * 2 * 0.7 + 0.3,
      child: Container(width: 6, height: 6,
          decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
    ),
  );
}

class _SearchBtn extends StatefulWidget {
  final VoidCallback onTap;
  const _SearchBtn({required this.onTap});
  @override State<_SearchBtn> createState() => _SearchBtnState();
}
class _SearchBtnState extends State<_SearchBtn> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _h = true),
    onExit:  (_) => setState(() => _h = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: _h ? AppColors.accent : AppColors.ink,
          borderRadius: BorderRadius.circular(44),
        ),
        child: Text('Search', style: GoogleFonts.dmSans(
            fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
      ),
    ),
  );
}

class _Stat extends StatelessWidget {
  final String num, label;
  const _Stat(this.num, this.label);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(num, style: GoogleFonts.syne(
        fontSize: 24, fontWeight: FontWeight.w700,
        letterSpacing: -0.8, color: AppColors.ink)),
    Text(label, style: GoogleFonts.dmSans(
        fontSize: 11, color: AppColors.ink3, fontWeight: FontWeight.w300)),
  ]);
}

class _HeroVisual extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final laptopW = w > 900 ? 320.0 : 260.0;
    return Center(
      child: SizedBox(
        width: laptopW + 80,
        height: laptopW + 80,
        child: Stack(alignment: Alignment.center, children: [
          // Glow
          Container(
            width: laptopW, height: laptopW,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.accent.withOpacity(0.08), Colors.transparent,
              ]),
            ),
          ),
          HeroLaptopWidget(width: laptopW),
          // Spec chips
          Positioned(top: 20, left: 0, child: _SpecChip('Intel Core i9-14900H')),
          Positioned(top: 80, right: 0, child: _SpecChip('RTX 4080 16GB')),
          Positioned(bottom: 80, left: 0, child: _SpecChip('32GB DDR5 RAM')),
          Positioned(bottom: 20, right: 0, child: _SpecChip('2TB NVMe SSD')),
        ]),
      ),
    );
  }
}

class _SpecChip extends StatelessWidget {
  final String label;
  const _SpecChip(this.label);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
    decoration: BoxDecoration(
      color: const Color(0x99FFFFFF),
      borderRadius: BorderRadius.circular(50),
      border: Border.all(color: const Color(0xD1FFFFFF)),
      boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 4))],
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 6, height: 6,
          decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
      const SizedBox(width: 7),
      Text(label, style: GoogleFonts.jetBrainsMono(
          fontSize: 10.5, color: AppColors.ink2)),
    ]),
  );
}

// ─── Marquee ──────────────────────────────────────────────────────────────────
class _MarqueeStrip extends StatefulWidget {
  const _MarqueeStrip();
  @override State<_MarqueeStrip> createState() => _MarqueeStripState();
}
class _MarqueeStripState extends State<_MarqueeStrip> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 22))..repeat();
  }
  @override void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColors.border),
        ),
      ),
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) {
            final allBrands = [..._brands, ..._brands, ..._brands, ..._brands];
            return Row(
              children: allBrands.map((b) => Transform.translate(
                offset: Offset(-_c.value * (_brands.length * 140.0), 0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 44),
                  child: Text(b.toUpperCase(), style: GoogleFonts.syne(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: const Color(0x33000000),
                  )),
                ),
              )).toList(),
            );
          },
        ),
      ),
    );
  }
}

// ─── Categories ───────────────────────────────────────────────────────────────
class _CategorySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final px = w > 900 ? 80.0 : w > 600 ? 40.0 : 20.0;
    return Padding(
      padding: EdgeInsets.fromLTRB(px, 96, px, 96),
      child: Column(children: [
        SectionHeader(
          title: 'Shop by Category',
          subtitle: 'Every machine, matched to your mission.',
          linkLabel: 'Browse all →',
          onLink: () => context.go('/products'),
        ),
        const SizedBox(height: 52),
        ..._categories.map((cat) => _CategoryRow(
          name: cat['name'] as String,
          count: cat['count'] as int,
          icon: cat['icon'] as IconData,
          brands: cat['brands'] as List<String>,
          onTap: () => context.go('/products?cat=${(cat['name'] as String).toLowerCase()}'),
        )),
      ]),
    );
  }
}

class _CategoryRow extends StatefulWidget {
  final String name;
  final int count;
  final IconData icon;
  final List<String> brands;
  final VoidCallback onTap;
  const _CategoryRow({required this.name, required this.count, required this.icon,
      required this.brands, required this.onTap});
  @override State<_CategoryRow> createState() => _CategoryRowState();
}
class _CategoryRowState extends State<_CategoryRow> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit:  (_) => setState(() => _h = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 0),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: _h ? AppColors.bg2 : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: const Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(children: [
            // Icon container
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: _h ? Colors.white : AppColors.bg2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _h ? const Color(0x33001AFF) : AppColors.border2,
                ),
              ),
              child: Icon(widget.icon,
                  color: _h ? AppColors.accent : AppColors.ink2, size: 20),
            ),
            const SizedBox(width: 20),
            // Name
            Text(widget.name, style: GoogleFonts.syne(
                fontSize: 17, fontWeight: FontWeight.w700,
                letterSpacing: -0.4, color: AppColors.ink)),
            const SizedBox(width: 20),
            // Brand pills — hide on small screens
            if (w > 600) Expanded(
              child: Wrap(spacing: 6, children: widget.brands.asMap().entries.map((e) {
                final isFirst = e.key == 0;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                  decoration: BoxDecoration(
                    color: isFirst ? AppColors.accentLight : Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: isFirst ? const Color(0x331A1AFF) : AppColors.border2,
                    ),
                  ),
                  child: Text(e.value, style: GoogleFonts.dmSans(
                    fontSize: 11, fontWeight: FontWeight.w500,
                    color: isFirst ? AppColors.accent : AppColors.ink2,
                  )),
                );
              }).toList()),
            )
            else const Spacer(),
            const SizedBox(width: 8),
            Text('${widget.count} laptops', style: GoogleFonts.jetBrainsMono(
                fontSize: 11, color: AppColors.ink3)),
            const SizedBox(width: 8),
            // Arrow circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32, height: 32,
              transform: Matrix4.translationValues(_h ? 3 : 0, 0, 0),
              decoration: BoxDecoration(
                color: _h ? AppColors.ink : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border2),
              ),
              child: Icon(Icons.arrow_forward,
                  size: 13, color: _h ? Colors.white : AppColors.ink2),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─── Featured Products ────────────────────────────────────────────────────────
class _FeaturedSection extends StatelessWidget {
  final List<Product> products;
  final bool loading;
  const _FeaturedSection({required this.products, required this.loading});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final px = w > 900 ? 80.0 : w > 600 ? 40.0 : 20.0;
    final cols = w > 1100 ? 4 : w > 700 ? 3 : 2;

    return Container(
      color: AppColors.bg,
      padding: EdgeInsets.fromLTRB(px, 0, px, 96),
      child: Column(children: [
        SectionHeader(
          title: 'Featured Laptops',
          subtitle: 'Trending picks, hand-curated for 2026.',
          linkLabel: 'View all →',
          onLink: () => context.go('/products'),
        ),
        const SizedBox(height: 52),
        if (loading)
          const Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator())
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              childAspectRatio: 0.72,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length,
            itemBuilder: (_, i) => ProductCard(product: products[i]),
          ),
      ]),
    );
  }
}

// ─── Why Section ──────────────────────────────────────────────────────────────
class _WhySection extends StatelessWidget {
  const _WhySection();

  static const _points = [
    {'icon': Icons.local_shipping_outlined, 'title': 'Fast Delivery',   'desc': 'Same-day dispatch on orders before 2pm. Tracked nationwide.'},
    {'icon': Icons.price_check_outlined,    'title': 'Price Match',     'desc': 'Find it cheaper? We match it — no questions asked.'},
    {'icon': Icons.verified_outlined,       'title': '2-Year Warranty', 'desc': 'All laptops covered. Hardware repairs handled by us.'},
    {'icon': Icons.headset_mic_outlined,    'title': 'Expert Support',  'desc': 'Live chat with a tech specialist, not a bot. Always.'},
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final px = w > 900 ? 80.0 : w > 600 ? 40.0 : 20.0;
    final cols = w > 700 ? 4 : 2;

    return Container(
      color: AppColors.ink,
      padding: EdgeInsets.fromLTRB(px, 96, px, 96),
      child: w > 900
        ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            SizedBox(width: 300, child: _WhyText()),
            const SizedBox(width: 80),
            Expanded(child: _WhyGrid(cols: cols)),
          ])
        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _WhyText(),
            const SizedBox(height: 48),
            _WhyGrid(cols: cols),
          ]),
    );
  }
}

class _WhyText extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Why choose us', style: GoogleFonts.jetBrainsMono(
          fontSize: 10, color: const Color(0x4DFFFFFF),
          letterSpacing: 1.2)),
      const SizedBox(height: 12),
      Text('The Harbor\nDifference.', style: GoogleFonts.syne(
          fontSize: 38, fontWeight: FontWeight.w700,
          letterSpacing: -1.5, color: Colors.white, height: 1.05)),
      const SizedBox(height: 16),
      Text('We don\'t just sell laptops — we match you with the right machine for your life, backed by the best service around.',
        style: GoogleFonts.dmSans(
            fontSize: 14, color: const Color(0x66FFFFFF),
            fontWeight: FontWeight.w300, height: 1.7),
        maxLines: 5),
    ],
  );
}

class _WhyGrid extends StatelessWidget {
  final int cols;
  const _WhyGrid({required this.cols});
  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: cols, childAspectRatio: 1.5,
      crossAxisSpacing: 14, mainAxisSpacing: 14,
    ),
    itemCount: _WhySection._points.length,
    itemBuilder: (_, i) => _WhyCard(_WhySection._points[i]),
  );
}

class _WhyCard extends StatefulWidget {
  final Map<String, dynamic> data;
  const _WhyCard(this.data);
  @override State<_WhyCard> createState() => _WhyCardState();
}
class _WhyCardState extends State<_WhyCard> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _h = true),
    onExit:  (_) => setState(() => _h = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      transform: Matrix4.translationValues(0, _h ? -3 : 0, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _h
            ? const Color(0x17FFFFFF)
            : const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _h ? const Color(0x29FFFFFF) : const Color(0x14FFFFFF),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: const Color(0x14FFFFFF),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(widget.data['icon'] as IconData, color: Colors.white, size: 17),
        ),
        const SizedBox(height: 16),
        Text(widget.data['title'] as String, style: GoogleFonts.syne(
            fontSize: 13.5, fontWeight: FontWeight.w600,
            color: Colors.white, letterSpacing: -0.3)),
        const SizedBox(height: 7),
        Text(widget.data['desc'] as String, style: GoogleFonts.dmSans(
            fontSize: 11.5, color: const Color(0x61FFFFFF),
            fontWeight: FontWeight.w300, height: 1.6),
            maxLines: 3, overflow: TextOverflow.ellipsis),
      ]),
    ),
  );
}
