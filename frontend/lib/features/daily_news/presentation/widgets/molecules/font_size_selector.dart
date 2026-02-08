import 'package:flutter/material.dart';

class FontSizeSelector extends StatelessWidget {
  final double currentSize;
  final Function(double) onSizeSelected;

  const FontSizeSelector({
    super.key,
    required this.currentSize,
    required this.onSizeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSizeOption('Small', 14.0),
          const SizedBox(height: 18),
          _buildSizeOption('Standard', 18.0),
          const SizedBox(height: 18),
          _buildSizeOption('Large', 22.0),
        ],
      ),
    );
  }

  Widget _buildSizeOption(String label, double size) {
    bool isSelected = currentSize == size;
    return GestureDetector(
      onTap: () => onSizeSelected(size),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF3A4A7D) : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
