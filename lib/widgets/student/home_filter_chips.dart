import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
// HOME FILTER CHIPS WIDGET
// Filters listings by room type and gender.
// ─────────────────────────────────────────────
class HomeFilterChips extends StatelessWidget {

  final int selectedIndex;
  final ValueChanged<int> onFilterSelected;

  const HomeFilterChips({
    super.key,
    required this.selectedIndex,
    required this.onFilterSelected,
  });

  static const List<Map<String, dynamic>> _filters = [
    {'label': 'All',    'icon': Icons.home_rounded},
    {'label': 'Single', 'icon': Icons.person_rounded},
    {'label': 'Double', 'icon': Icons.people_rounded},
    {'label': 'Shared', 'icon': Icons.groups_rounded},
    {'label': 'Male',   'icon': Icons.male_rounded},
    {'label': 'Female', 'icon': Icons.female_rounded},
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
          final String label = _filters[index]['label'];
          final IconData icon = _filters[index]['icon'];

          return GestureDetector(
            onTap: () => onFilterSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2B658B)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2B658B)
                      : const Color(0xFFDDE3F0),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 14,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF2B658B),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF2B658B),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}