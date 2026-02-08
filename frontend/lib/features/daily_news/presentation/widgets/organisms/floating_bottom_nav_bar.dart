import 'package:flutter/material.dart';

class FloatingBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FloatingBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E) // Dark surface
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset:
                const Offset(0, -5), // Shadow upwards to separate from content
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.home_rounded, 'Home', 0),
              _buildNavItem(context, Icons.search_rounded, 'Explore', 1),
              _buildNavItem(context, Icons.bookmark_border_rounded, 'Saved', 2),
              _buildNavItem(
                  context, Icons.person_outline_rounded, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, IconData icon, String label, int index) {
    final isSelected = currentIndex == index;
    // Primary color for selected state
    final selectedColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
            : const EdgeInsets.all(10),
        decoration: isSelected
            ? BoxDecoration(
                color:
                    selectedColor, // Primary color for selected item background
                borderRadius: BorderRadius.circular(25),
              )
            : null,
        child: Row(
          children: [
            Icon(
              icon,
              // White icon if selected (on blue bg), otherwise Grey/Black
              color: isSelected ? Colors.white : Colors.grey,
              size: 26,
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
