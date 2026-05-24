import 'package:flutter/material.dart';

/// Quick Action entity for Command Palette
/// Represents frequently used actions shown as chips
class QuickAction {
  /// Unique identifier
  final String id;

  /// Display label
  final String label;

  /// Icon for visual identification
  final IconData icon;

  /// Action to execute when tapped
  final VoidCallback onTap;

  /// Color for the chip (optional, uses primary by default)
  final Color? color;

  /// Keyboard shortcut display (optional)
  final String? shortcut;

  /// Category for grouping (optional)
  final String? category;

  const QuickAction({
    required this.id,
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
    this.shortcut,
    this.category,
  });

  /// Create Project quick action
  static QuickAction createProject({required VoidCallback onTap}) {
    return QuickAction(
      id: 'quick_create_project',
      label: 'Create Project',
      icon: Icons.rocket_launch_outlined,
      onTap: onTap,
      shortcut: 'Cmd+N',
      category: 'create',
    );
  }

  /// New Chat quick action
  static QuickAction newChat({required VoidCallback onTap}) {
    return QuickAction(
      id: 'quick_new_chat',
      label: 'New Chat',
      icon: Icons.chat_bubble_outline,
      onTap: onTap,
      shortcut: 'Cmd+Shift+C',
      category: 'create',
    );
  }

  /// New Note quick action
  static QuickAction newNote({required VoidCallback onTap}) {
    return QuickAction(
      id: 'quick_new_note',
      label: 'New Note',
      icon: Icons.note_add_outlined,
      onTap: onTap,
      shortcut: 'Cmd+Shift+N',
      category: 'create',
    );
  }

  /// Search quick action
  static QuickAction search({required VoidCallback onTap}) {
    return QuickAction(
      id: 'quick_search',
      label: 'Search',
      icon: Icons.search,
      onTap: onTap,
      shortcut: 'Cmd+F',
      category: 'utility',
    );
  }
}
