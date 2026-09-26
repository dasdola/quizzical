import 'package:flutter/material.dart';

/// Pastel card backgrounds, cycled through the category grid
/// (sky, mint, butter, lavender, rose, peach - as in the design).
const List<Color> kCategoryCardColors = [
  Color(0xFFBFE0FB),
  Color(0xFFB9F3D3),
  Color(0xFFFFF6B8),
  Color(0xFFE6CCFF),
  Color(0xFFFFC2CC),
  Color(0xFFFFE3C4),
];

/// Maps an OpenTDB category id to an icon.
IconData iconForCategory(int id) {
  switch (id) {
    case 9:
      return Icons.public_rounded;
    case 10:
      return Icons.menu_book_rounded;
    case 11:
      return Icons.movie_rounded;
    case 12:
      return Icons.music_note_rounded;
    case 13:
      return Icons.theater_comedy_rounded;
    case 14:
      return Icons.tv_rounded;
    case 15:
      return Icons.sports_esports_rounded;
    case 16:
      return Icons.casino_rounded;
    case 17:
      return Icons.biotech_rounded;
    case 18:
      return Icons.computer_rounded;
    case 19:
      return Icons.calculate_rounded;
    case 20:
      return Icons.auto_stories_rounded;
    case 21:
      return Icons.sports_soccer_rounded;
    case 22:
      return Icons.map_rounded;
    case 23:
      return Icons.history_edu_rounded;
    case 24:
      return Icons.account_balance_rounded;
    case 25:
      return Icons.palette_rounded;
    case 26:
      return Icons.star_rounded;
    case 27:
      return Icons.pets_rounded;
    case 28:
      return Icons.directions_car_rounded;
    case 29:
      return Icons.auto_awesome_rounded;
    case 30:
      return Icons.devices_rounded;
    case 31:
      return Icons.movie_filter_rounded;
    case 32:
      return Icons.brush_rounded;
    default:
      return Icons.category_rounded;
  }
}
