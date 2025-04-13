import 'package:final_ecommerce/utils/format.dart';
import 'package:flutter/material.dart';

final List<Map<String, String>> sortOptions = [
  {'name': 'Name (A-Z)', 'key': 'name_asc'},
  {'name': 'Name (Z-A)', 'key': 'name_desc'},
  {'name': 'Price (Low to High)', 'key': 'sellingPrice_asc'},
  {'name': 'Price (High to Low)', 'key': 'sellingPrice_desc'},
];

class FilterSection extends StatelessWidget {
  final VoidCallback onSortPressed;
  final VoidCallback onFilterPressed;
  final String selectedSortOption;

  const FilterSection({
    super.key,
    required this.onSortPressed,
    required this.onFilterPressed,
    required this.selectedSortOption,
  });

  @override
  Widget build(BuildContext context) {
    final selectedSortName =
        sortOptions.firstWhere(
          (option) => option['key'] == selectedSortOption,
          orElse: () => {'name': ''},
        )['name'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (selectedSortName != null && selectedSortName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              'Sort by: $selectedSortName',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: onSortPressed,
              icon: const Icon(Icons.sort, color: Colors.grey),
            ),
            IconButton(
              onPressed: onFilterPressed,
              icon: const Icon(Icons.filter_alt_outlined, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}

void showSortByBottomSheet(
  BuildContext context,
  Function(String) onSortSelected,
) {
  showModalBottomSheet(
    context: context,
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              sortOptions.map((option) {
                return ListTile(
                  leading: const Icon(Icons.sort),
                  title: Text(option['name']!),
                  onTap: () => onSortSelected(option['key']!),
                );
              }).toList(),
        ),
      );
    },
  );
}

void showFilterBottomSheet(
  BuildContext context, {
  required RangeValues currentRange,
  required List<String> currentCategories,
  required List<String> currentBrands,
  required Function(List<String>, List<String>, RangeValues) onApplyFilter,
}) {
  List<String> categories = [
    'Desktops',
    'Laptops',
    'Monitors',
    'Speakers',
    'Keyboards',
    'Headphones',
  ];
  List<String> brands = ['Apple', 'Dell', 'HP', 'Lenovo', 'Samsung', 'Sony'];
  List<String> selectedCategories = currentCategories;
  List<String> selectedBrands = currentBrands;
  RangeValues selectedRange = currentRange;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Filter Options',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                /// Category
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Category'),
                ),
                Wrap(
                  spacing: 8,
                  children:
                      categories.map((category) {
                        final isSelected = selectedCategories.contains(
                          category,
                        );
                        return FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedCategories.add(category);
                              } else {
                                selectedCategories.remove(category);
                              }
                            });
                          },
                        );
                      }).toList(),
                ),

                const SizedBox(height: 16),

                /// Brand
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Brand'),
                ),
                Wrap(
                  spacing: 8,
                  children:
                      brands.map((brand) {
                        final isSelected = selectedBrands.contains(brand);
                        return FilterChip(
                          label: Text(brand),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedBrands.add(brand);
                              } else {
                                selectedBrands.remove(brand);
                              }
                            });
                          },
                        );
                      }).toList(),
                ),

                const SizedBox(height: 16),

                /// Price Range
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Price Range'),
                ),
                RangeSlider(
                  values: selectedRange,
                  min: 0,
                  max: 100000000,
                  divisions: 10,
                  labels: RangeLabels(
                    FormatHelper.formatCurrency(selectedRange.start),
                    FormatHelper.formatCurrency(selectedRange.end),
                  ),
                  onChanged: (range) {
                    setState(() {
                      selectedRange = range;
                    });
                  },
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      onApplyFilter(
                        selectedCategories,
                        selectedBrands,
                        selectedRange,
                      );
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.done),
                    label: const Text('Apply'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      );
    },
  );
}
