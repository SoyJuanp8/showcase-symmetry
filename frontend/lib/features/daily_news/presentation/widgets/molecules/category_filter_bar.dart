import 'package:flutter/material.dart';

class CategoryFilterBar extends StatefulWidget {
  const CategoryFilterBar({super.key});

  @override
  State<CategoryFilterBar> createState() => _CategoryFilterBarState();
}

class _CategoryFilterBarState extends State<CategoryFilterBar> {
  int _selectedIndex = 0;
  final List<String> _categories = [
    'All',
    'Politics',
    'Sports',
    'Health',
    'Tech',
    'Science'
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final isSelected = _selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _categories[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
