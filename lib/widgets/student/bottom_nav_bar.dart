import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
// BOTTOM NAV BAR WIDGET
// Shows Home, Search, Saved, Chats, Profile.
// Active item shown in blue, others in gray.
// ─────────────────────────────────────────────
class BottomNavBar extends StatelessWidget {

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  static const List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.home_rounded,             'label': 'Home'},
    {'icon': Icons.search_rounded,           'label': 'Search'},
    {'icon': Icons.favorite_border_rounded,  'label': 'Saved'},
    {'icon': Icons.chat_bubble_outline_rounded, 'label': 'Chats'},
    {'icon': Icons.person_outline_rounded,   'label': 'Profile'},
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_navItems.length, (index) {
          final bool isSelected = selectedIndex == index;
          final Color itemColor = isSelected
              ? const Color(0xFF2B658B)
              : Colors.grey.shade400;

          return GestureDetector(
            onTap: () => onItemSelected(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _navItems[index]['icon'] as IconData,
                  size: 26,
                  color: itemColor,
                ),
                const SizedBox(height: 4),
                Text(
                  _navItems[index]['label'],
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
          );
        }),
      ),
    );
  }
}