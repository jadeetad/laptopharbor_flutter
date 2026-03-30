import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../models/product.dart';
import '../theme.dart';
import 'laptop_svg_widget.dart';
import 'auth_bottom_sheet.dart';

// ─── App NavBar ───────────────────────────────────────────────────────────────
class AppNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String? currentRoute;
  const AppNavBar({super.key, this.currentRoute});

  @override Size get preferredSize => const Size.fromHeight(66);

  @override
  Widget build(BuildContext context) {
    final auth    = context.watch<AuthProvider>();
    final cart    = context.watch<CartProvider>();
    final wishlist = context.watch<WishlistProvider>();
    final w = MediaQuery.of(context).size.width;

    return Container(
      height: 66,
      decoration: const BoxDecoration(
        color: Color(0xC8FFFFFF),
        border: Border(bottom: BorderSide(color: Color(0x0F000000))),
        boxShadow: [
          BoxShadow(color: Color(0xE6FFFFFF), blurRadius: 0, offset: Offset(0, 1)),
          BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 4)),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: w > 900 ? 56 : w > 600 ? 32 : 16),
      child: Row(
        children: [
          // Logo — always visible
          GestureDetector(
            onTap: () => context.go('/'),
            child: Row(children: [
              const LogoWidget(size: 32),
              const SizedBox(width: 10),
              Text('LaptopHarbor', style: GoogleFonts.syne(
                fontWeight: FontWeight.w800, fontSize: 17,
                letterSpacing: -0.4, color: AppColors.ink,
              )),
            ]),
          ),
          const Spacer(),
          // Nav links — show from 768px+
          if (w > 768) ...[
            _NavLink('Home', '/'),
            _NavLink('Products', '/products'),
            _NavLink('Deals', '/deals'),
            _NavLink('Support', '/support'),
            const SizedBox(width: 12),
          ],
          // Icons
          _NavIconBtn(icon: Icons.search, onTap: () =>
              showSearch(context: context, delegate: _ProductSearchDelegate())),
          const SizedBox(width: 4),
          Stack(clipBehavior: Clip.none, children: [
            _NavIconBtn(
              icon: Icons.favorite_border,
              onTap: () => auth.isLoggedIn ? context.go('/wishlist') : showAuthBottomSheet(context),
            ),
            if (auth.isLoggedIn && wishlist.count > 0)
              Positioned(top: -2, right: -2, child: _Badge(wishlist.count)),
          ]),
          const SizedBox(width: 4),
          Stack(clipBehavior: Clip.none, children: [
            _NavIconBtn(
              icon: Icons.shopping_bag_outlined,
              accent: cart.itemCount > 0,
              onTap: () => auth.isLoggedIn ? context.go('/cart') : showAuthBottomSheet(context),
            ),
            if (cart.itemCount > 0)
              Positioned(top: -2, right: -2, child: _Badge(cart.itemCount)),
          ]),
          const SizedBox(width: 10),
          if (auth.isLoggedIn)
            _PillButton(label: 'My Account', onTap: () => context.go('/profile'), ghost: true)
          else
            _PillButton(label: 'Sign In', onTap: () => showAuthBottomSheet(context)),
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label, route;
  const _NavLink(this.label, this.route);
  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final active = loc == route || (route != '/' && loc.startsWith(route));
    return TextButton(
      onPressed: () => context.go(route),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label, style: GoogleFonts.dmSans(
        fontSize: 14, fontWeight: active ? FontWeight.w500 : FontWeight.w400,
        color: active ? AppColors.accent : AppColors.ink2,
      )),
    );
  }
}

class _NavIconBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool accent;
  const _NavIconBtn({required this.icon, required this.onTap, this.accent = false});
  @override State<_NavIconBtn> createState() => _NavIconBtnState();
}
class _NavIconBtnState extends State<_NavIconBtn> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _h = true),
    onExit: (_) => setState(() => _h = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 38, height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.accent
              ? AppColors.accentLight
              : (_h ? AppColors.bg2 : Colors.transparent),
          border: Border.all(
            color: widget.accent
                ? AppColors.accent
                : (_h ? AppColors.ink2 : AppColors.border2),
          ),
        ),
        child: Icon(widget.icon, size: 16,
            color: widget.accent ? AppColors.accent : AppColors.ink),
      ),
    ),
  );
}

class _Badge extends StatelessWidget {
  final int n;
  const _Badge(this.n);
  @override
  Widget build(BuildContext context) => Container(
    width: 16, height: 16,
    decoration: BoxDecoration(
      color: AppColors.accent, shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 2),
    ),
    child: Center(child: Text('$n',
        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700))),
  );
}

class _PillButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool ghost;
  const _PillButton({required this.label, required this.onTap, this.ghost = false});
  @override State<_PillButton> createState() => _PillButtonState();
}
class _PillButtonState extends State<_PillButton> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _h = true),
    onExit: (_) => setState(() => _h = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.translationValues(0, _h ? -1 : 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        decoration: BoxDecoration(
          color: widget.ghost
              ? (_h ? AppColors.bg2 : Colors.transparent)
              : (_h ? AppColors.accent : AppColors.ink),
          borderRadius: BorderRadius.circular(50),
          border: widget.ghost ? Border.all(color: AppColors.border2) : null,
        ),
        child: Text(widget.label, style: GoogleFonts.dmSans(
          fontSize: 13, fontWeight: FontWeight.w500,
          color: widget.ghost ? AppColors.ink : Colors.white,
        )),
      ),
    ),
  );
}

// ─── Product Card ─────────────────────────────────────────────────────────────
class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;
  const ProductCard({super.key, required this.product, this.onTap});
  @override State<ProductCard> createState() => _ProductCardState();
}
class _ProductCardState extends State<ProductCard> {
  bool _h = false;

  @override
  Widget build(BuildContext context) {
    final auth     = context.watch<AuthProvider>();
    final wishlist = context.watch<WishlistProvider>();
    final cart     = context.watch<CartProvider>();
    final p = widget.product;

    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit:  (_) => setState(() => _h = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        transform: Matrix4.translationValues(0, _h ? -5 : 0, 0),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _h ? const Color(0x26000000) : AppColors.border),
          boxShadow: _h
              ? [const BoxShadow(color: Color(0x14000000), blurRadius: 48, offset: Offset(0, 20))]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: GestureDetector(
            onTap: widget.onTap ?? () => context.go('/products/${p.id}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                SizedBox(
                  height: 172,
                  child: Stack(children: [
                    Container(
                      width: double.infinity,
                      color: _hexColor(p.bgColor),
                      child: Center(
                        child: AnimatedScale(
                          scale: _h ? 1.06 : 1.0,
                          duration: const Duration(milliseconds: 350),
                          child: LaptopSvgWidget(bgColor: p.bgColor, screenColor: p.screenColor, width: 130),
                        ),
                      ),
                    ),
                    if (p.badge != null)
                      Positioned(top: 10, left: 10, child: BadgeChip(p.badge!)),
                    Positioned(
                      top: 10, right: 10,
                      child: AnimatedOpacity(
                        opacity: _h ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: _WishBtn(
                          active: wishlist.isWishlisted(p.id),
                          onTap: () {
                            if (!auth.isLoggedIn) { showAuthBottomSheet(context); return; }
                            wishlist.toggle(p, auth.user!.id);
                          },
                        ),
                      ),
                    ),
                  ]),
                ),
                // Body
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p.brand.toUpperCase(), style: GoogleFonts.jetBrainsMono(
                        fontSize: 9.5, color: AppColors.ink3, letterSpacing: 1.0)),
                    const SizedBox(height: 4),
                    Text(p.name, style: GoogleFonts.syne(
                        fontSize: 13.5, fontWeight: FontWeight.w600,
                        letterSpacing: -0.2, color: AppColors.ink, height: 1.3),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    StarRating(count: p.rating, reviews: p.reviews),
                    const SizedBox(height: 8),
                    Wrap(spacing: 4, runSpacing: 4,
                        children: p.specs.entries.take(3).map((e) => SpecPill(e.value)).toList()),
                    const SizedBox(height: 10),
                    // Price row
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (p.oldPrice != null)
                          Text('\$${p.oldPrice!.toStringAsFixed(0)}',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10.5, color: AppColors.ink3,
                              decoration: TextDecoration.lineThrough)),
                        Text('\$${p.price.toStringAsFixed(0)}',
                          style: GoogleFonts.syne(
                            fontSize: 16, fontWeight: FontWeight.w700,
                            letterSpacing: -0.5, color: AppColors.ink)),
                      ]),
                      _RoundCartBtn(onTap: () {
                        if (!auth.isLoggedIn) { showAuthBottomSheet(context); return; }
                        cart.addItem(p, userId: auth.user!.id);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('${p.name} added to cart'),
                          duration: const Duration(seconds: 2),
                        ));
                      }),
                    ]),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WishBtn extends StatefulWidget {
  final bool active;
  final VoidCallback onTap;
  const _WishBtn({required this.active, required this.onTap});
  @override State<_WishBtn> createState() => _WishBtnState();
}
class _WishBtnState extends State<_WishBtn> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _h = true),
    onExit:  (_) => setState(() => _h = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: _h ? Colors.white : const Color(0xA6FFFFFF),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xD9FFFFFF)),
        ),
        child: Icon(widget.active ? Icons.favorite : Icons.favorite_border,
            size: 13, color: widget.active ? Colors.red : AppColors.ink2),
      ),
    ),
  );
}

class _RoundCartBtn extends StatefulWidget {
  final VoidCallback onTap;
  const _RoundCartBtn({required this.onTap});
  @override State<_RoundCartBtn> createState() => _RoundCartBtnState();
}
class _RoundCartBtnState extends State<_RoundCartBtn> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _h = true),
    onExit:  (_) => setState(() => _h = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: _h ? AppColors.accent : AppColors.ink,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 13),
      ),
    ),
  );
}

// ─── Badge Chip ───────────────────────────────────────────────────────────────
class BadgeChip extends StatelessWidget {
  final String label;
  const BadgeChip(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    Color bg, fg, bd;
    switch (label.toUpperCase()) {
      case 'SALE': bg = AppColors.badgeSaleBg; fg = AppColors.badgeSaleFg; bd = AppColors.badgeSaleBd; break;
      case 'NEW':  bg = AppColors.badgeNewBg;  fg = AppColors.badgeNewFg;  bd = AppColors.badgeNewBd;  break;
      case 'HOT':  bg = AppColors.badgeHotBg;  fg = AppColors.badgeHotFg;  bd = AppColors.badgeHotBd;  break;
      default:     bg = AppColors.bg2; fg = AppColors.ink3; bd = AppColors.border2;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(50),
        border: Border.all(color: bd),
      ),
      child: Text(label, style: GoogleFonts.jetBrainsMono(
          fontSize: 9.5, fontWeight: FontWeight.w500,
          color: fg, letterSpacing: 0.5)),
    );
  }
}

// ─── Spec Pill ────────────────────────────────────────────────────────────────
class SpecPill extends StatelessWidget {
  final String label;
  const SpecPill(this.label, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: AppColors.bg2, borderRadius: BorderRadius.circular(4),
    ),
    child: Text(label, style: GoogleFonts.jetBrainsMono(
        fontSize: 9.5, color: AppColors.ink3)),
  );
}

// ─── Star Rating ──────────────────────────────────────────────────────────────
class StarRating extends StatelessWidget {
  final int count;
  final int? reviews;
  final double size;
  const StarRating({super.key, required this.count, this.reviews, this.size = 10});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      ...List.generate(5, (i) => Icon(
        i < count ? Icons.star_rounded : Icons.star_outline_rounded,
        color: i < count ? AppColors.starFilled : AppColors.starEmpty,
        size: size,
      )),
      if (reviews != null) ...[
        const SizedBox(width: 3),
        Text('($reviews)', style: GoogleFonts.dmSans(
            fontSize: 10, color: AppColors.ink3)),
      ],
    ],
  );
}

// ─── Section Header ───────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title, subtitle;
  final String? linkLabel;
  final VoidCallback? onLink;
  const SectionHeader({super.key, required this.title, required this.subtitle,
      this.linkLabel, this.onLink});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.syne(
            fontSize: 28, fontWeight: FontWeight.w700,
            letterSpacing: -1.5, color: AppColors.ink, height: 1.05)),
        const SizedBox(height: 6),
        Text(subtitle, style: GoogleFonts.dmSans(
            fontSize: 14, color: AppColors.ink3, fontWeight: FontWeight.w300)),
      ])),
      if (linkLabel != null && onLink != null) ...[
        const SizedBox(width: 16),
        GestureDetector(
          onTap: onLink,
          child: Text(linkLabel!, style: GoogleFonts.dmSans(
              fontSize: 13, color: AppColors.ink3,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.border2)),
        ),
      ],
    ],
  );
}

// ─── App Footer ───────────────────────────────────────────────────────────────
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final px = w > 900 ? 80.0 : w > 600 ? 40.0 : 24.0;

    return Container(
      color: AppColors.bg,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Divider(color: AppColors.border, height: 1),
        Padding(
          padding: EdgeInsets.fromLTRB(px, 64, px, 36),
          child: Column(children: [
            if (w > 700)
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(flex: 2, child: _FooterBrand()),
                Expanded(child: _FooterCol('Shop', [('All Laptops','/products'),('Deals','/deals')])),
                Expanded(child: _FooterCol('Company', [('About Us','/'),('Blog','/')])),
                Expanded(child: _FooterCol('Support', [('Contact','/support'),('FAQ','/support')])),
              ])
            else
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _FooterBrand(),
                const SizedBox(height: 32),
                Row(children: [
                  Expanded(child: _FooterCol('Shop', [('All Laptops','/products'),('Deals','/deals')])),
                  Expanded(child: _FooterCol('Support', [('Contact','/support'),('FAQ','/support')])),
                ]),
              ]),
            const SizedBox(height: 32),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Flexible(child: RichText(text: TextSpan(
                style: GoogleFonts.jetBrainsMono(fontSize: 11.5, color: AppColors.ink3),
                children: const [
                  TextSpan(text: '© 2026 '),
                  TextSpan(text: 'LaptopHarbor',
                      style: TextStyle(color: AppColors.accent)),
                  TextSpan(text: '. All rights reserved.'),
                ],
              ))),
              Text('Built with precision.',
                  style: GoogleFonts.jetBrainsMono(fontSize: 11.5, color: AppColors.ink3)),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _FooterBrand extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        const LogoWidget(size: 22),
        const SizedBox(width: 8),
        Text('LaptopHarbor', style: GoogleFonts.syne(
            fontWeight: FontWeight.w800, fontSize: 17,
            letterSpacing: -0.4, color: AppColors.ink)),
      ]),
      const SizedBox(height: 12),
      Text('Your destination for premium laptops.\nCurated picks, unbeatable prices, expert support.',
        style: GoogleFonts.dmSans(
            fontSize: 13, color: AppColors.ink3,
            fontWeight: FontWeight.w300, height: 1.6),
      ),
    ]
  );
}

class _FooterCol extends StatelessWidget {
  final String title;
  final List<(String, String)> links;
  const _FooterCol(this.title, this.links);
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title.toUpperCase(), style: GoogleFonts.jetBrainsMono(
          fontSize: 9.5, color: AppColors.ink3,
          fontWeight: FontWeight.w500, letterSpacing: 1.0)),
      const SizedBox(height: 16),
      ...links.map((l) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GestureDetector(
          onTap: () => context.go(l.$2),
          child: Text(l.$1, style: GoogleFonts.dmSans(
              fontSize: 13, color: AppColors.ink3, fontWeight: FontWeight.w300)),
        ),
      )),
    ],
  );
}

// ─── Search Delegate ──────────────────────────────────────────────────────────
class _ProductSearchDelegate extends SearchDelegate {
  @override List<Widget> buildActions(BuildContext c) =>
      [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];
  @override Widget buildLeading(BuildContext c) =>
      IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(c, null));
  @override Widget buildResults(BuildContext c) {
    c.go('/products?q=${Uri.encodeComponent(query)}'); close(c, null);
    return const SizedBox.shrink();
  }
  @override Widget buildSuggestions(BuildContext c) =>
      Center(child: Text('Search laptops, brands, specs...',
          style: GoogleFonts.dmSans(color: AppColors.ink3)));
}

Color _hexColor(String hex) {
  try { return Color(int.parse(hex.replaceFirst('#', '0xFF'))); }
  catch (_) { return const Color(0xFF111111); }
}

