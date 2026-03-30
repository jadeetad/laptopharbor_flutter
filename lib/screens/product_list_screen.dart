import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../theme.dart';
import '../widgets/shared_widgets.dart';

const _categories = ['All', 'Gaming', 'Business', 'Creator', 'Student', 'Ultrabook', 'Budget'];
const _brands = ['All', 'ASUS', 'Apple', 'Dell', 'HP', 'Lenovo', 'MSI', 'Razer', 'Microsoft', 'LG', 'Acer'];
const _ramOpts = ['All', '8GB', '16GB', '32GB', '64GB', '128GB'];

class ProductListScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialQuery;
  const ProductListScreen({super.key, this.initialCategory, this.initialQuery});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> _products = [];
  bool _loading = true;

  late String _category;
  String _brand = 'All';
  String _ram = 'All';
  RangeValues _priceRange = const RangeValues(0, 4000);
  String _sortBy = 'featured';
  late TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _category = _categories.firstWhere(
      (c) => c.toLowerCase() == (widget.initialCategory ?? ''),
      orElse: () => 'All',
    );
    _searchCtrl = TextEditingController(text: widget.initialQuery ?? '');
    _load();
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final products = await ProductService.getProducts(
      category: _category == 'All' ? null : _category,
      brand: _brand == 'All' ? null : _brand,
      minPrice: _priceRange.start > 0 ? _priceRange.start : null,
      maxPrice: _priceRange.end < 4000 ? _priceRange.end : null,
      searchQuery: _searchCtrl.text,
      sortBy: _sortBy,
    );
    if (mounted) setState(() { _products = products; _loading = false; });
  }

  void _clearAll() {
    setState(() {
      _category = 'All'; _brand = 'All'; _ram = 'All';
      _priceRange = const RangeValues(0, 4000);
      _searchCtrl.clear();
    });
    _load();
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FilterSheet(
        category: _category, brand: _brand, ram: _ram,
        priceRange: _priceRange,
        onApply: (cat, brand, ram, range) {
          setState(() {
            _category = cat; _brand = brand; _ram = ram; _priceRange = range;
          });
          _load();
        },
        onClear: _clearAll,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppNavBar(currentRoute: '/products'),
      body: Column(
        children: [
          // Filter bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(children: [
              Row(children: [
                // Filter button
                OutlinedButton.icon(
                  onPressed: _showFilters,
                  icon: const Icon(Icons.tune, size: 18),
                  label: const Text('Filters'),
                ),
                const SizedBox(width: 10),
                // Search
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onSubmitted: (_) => _load(),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Sort
                _SortDropdown(value: _sortBy, onChanged: (v) { setState(() => _sortBy = v); _load(); }),
              ]),
              const SizedBox(height: 10),
              // Category quick pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((c) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c),
                      selected: _category == c,
                      onSelected: (_) { setState(() => _category = c); _load(); },
                      selectedColor: AppColors.accent,
                      labelStyle: TextStyle(
                          color: _category == c ? Colors.white : AppColors.ink,
                          fontSize: 13),
                    ),
                  )).toList(),
                ),
              ),
            ]),
          ),
          // Results
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('${_products.length} laptops found',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                    ? _EmptyState(onClear: _clearAll)
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _products.length,
                        itemBuilder: (_, i) => ProductCard(
                          product: _products[i],
                          onTap: () => context.go('/products/${_products[i].id}'),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _SortDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _SortDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      underline: const SizedBox(),
      style: const TextStyle(fontSize: 13, color: AppColors.ink),
      items: const [
        DropdownMenuItem(value: 'featured', child: Text('Featured')),
        DropdownMenuItem(value: 'price-asc', child: Text('Price ↑')),
        DropdownMenuItem(value: 'price-desc', child: Text('Price ↓')),
        DropdownMenuItem(value: 'rating', child: Text('Top rated')),
      ],
      onChanged: (v) => onChanged(v!),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final String category, brand, ram;
  final RangeValues priceRange;
  final Function(String, String, String, RangeValues) onApply;
  final VoidCallback onClear;
  const _FilterSheet({
    required this.category, required this.brand, required this.ram,
    required this.priceRange, required this.onApply, required this.onClear,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String _cat, _brand, _ram;
  late RangeValues _range;

  @override
  void initState() {
    super.initState();
    _cat = widget.category; _brand = widget.brand; _ram = widget.ram; _range = widget.priceRange;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      builder: (_, ctrl) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(controller: ctrl, children: [
          const SizedBox(height: 12),
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Filters', style: Theme.of(context).textTheme.headlineSmall),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          ]),
          _FilterGroup('Category', _categories, _cat, (v) => setState(() => _cat = v)),
          _FilterGroup('Brand', _brands, _brand, (v) => setState(() => _brand = v)),
          _FilterGroup('RAM', _ramOpts, _ram, (v) => setState(() => _ram = v)),
          const SizedBox(height: 16),
          Text('Price range — \$${_range.start.round()} – \$${_range.end.round()}',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          RangeSlider(
            values: _range,
            min: 0, max: 4000, divisions: 80,
            activeColor: AppColors.accent,
            onChanged: (v) => setState(() => _range = v),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () { widget.onClear(); Navigator.pop(context); }, child: const Text('Clear all'))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: () { widget.onApply(_cat, _brand, _ram, _range); Navigator.pop(context); },
              child: const Text('Apply'),
            )),
          ]),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}

class _FilterGroup extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;
  const _FilterGroup(this.title, this.options, this.selected, this.onSelect);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8, runSpacing: 8,
        children: options.map((o) => ChoiceChip(
          label: Text(o),
          selected: selected == o,
          onSelected: (_) => onSelect(o),
          selectedColor: AppColors.accent,
          labelStyle: TextStyle(color: selected == o ? Colors.white : AppColors.ink, fontSize: 13),
        )).toList(),
      ),
    ],
  );
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onClear;
  const _EmptyState({required this.onClear});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
        const SizedBox(height: 16),
        const Text('No laptops found', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        const SizedBox(height: 8),
        const Text('Try adjusting your filters or search term', style: TextStyle(color: AppColors.textMuted)),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: onClear, child: const Text('Clear filters')),
      ],
    ),
  );
}
