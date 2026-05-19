import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
// BOTTOM NAV BAR WIDGET
// Student navigation bar with 5 tabs:
// Home, Search, Bookings, Chat, Profile
// ─────────────────────────────────────────────
class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  static const List<Map<String, dynamic>> _items = [
    {'icon': Icons.home_rounded,              'label': 'Home'},
    {'icon': Icons.search_rounded,            'label': 'Search'},
    {'icon': Icons.calendar_today_rounded,    'label': 'Bookings'},
    {'icon': Icons.chat_bubble_outline_rounded,'label': 'Chat'},
    {'icon': Icons.person_outline_rounded,    'label': 'Profile'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFDDE3F0), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(
          vertical: 10, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (index) {
          final bool isSelected = selectedIndex == index;
          final Color itemColor = isSelected
              ? const Color(0xFF2B658B)
              : Colors.grey.shade400;

          return GestureDetector(
            onTap: () => onItemSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2B658B).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _items[index]['icon'] as IconData,
                    size: 24,
                    color: itemColor,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _items[index]['label'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: itemColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}