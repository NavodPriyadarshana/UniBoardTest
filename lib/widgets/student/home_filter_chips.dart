import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
// HOME FILTER CHIPS WIDGET
// Horizontally scrollable filter options.
// Selected chip shown in blue, others in white.
// ─────────────────────────────────────────────
class HomeFilterChips extends StatelessWidget {

  final int selectedIndex;
  final ValueChanged<int> onFilterSelected;

  const HomeFilterChips({
    super.key,
    required this.selectedIndex,
    required this.onFilterSelected,
  });

  static const List<String> _filters = [
    'All',
    'Room Type',
    'Price',
    'Distance',
    'Gender',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final bool isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onFilterSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2B658B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2B658B)
                      : const Color(0xFFDDE3F0),
                ),
              ),
              child: Text(
                _filters[index],
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF2B658B),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}