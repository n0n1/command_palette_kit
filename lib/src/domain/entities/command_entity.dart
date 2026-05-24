/// Command entity for command palette
class CommandEntity {
  final String id;
  final String title;
  final String? description;
  final String? category;
  final List<String> keywords;
  final String? icon;
  final String? shortcut;
  final CommandAction action;

  const CommandEntity({
    required this.id,
    required this.title,
    this.description,
    this.category,
    this.keywords = const [],
    this.icon,
    this.shortcut,
    required this.action,
  });

  /// Check if command matches search query
  bool matches(String query) {
    final lowerQuery = query.toLowerCase();
    return title.toLowerCase().contains(lowerQuery) ||
        (description?.toLowerCase().contains(lowerQuery) ?? false) ||
        keywords.any((k) => k.toLowerCase().contains(lowerQuery)) ||
        id.toLowerCase().contains(lowerQuery);
  }
}

/// Command action types
enum CommandActionType {
  navigate,
  orbitControl,
  settingsControl,
  debugControl,
  projectsControl,
  notesControl,
  chatsControl,
  theme,
  custom,
}

/// Command action definition
class CommandAction {
  final CommandActionType type;
  final String? route;
  final Map<String, dynamic>? params;

  const CommandAction({required this.type, this.route, this.params});

  CommandAction.navigate(this.route)
      : type = CommandActionType.navigate,
        params = null;

  CommandAction.orbitControl(String action)
      : type = CommandActionType.orbitControl,
        route = null,
        params = {'action': action};

  CommandAction.settingsControl(String action)
      : type = CommandActionType.settingsControl,
        route = null,
        params = {'action': action};

  CommandAction.debugControl(String action)
      : type = CommandActionType.debugControl,
        route = null,
        params = {'action': action};

  CommandAction.projectsControl(String action)
      : type = CommandActionType.projectsControl,
        route = null,
        params = {'action': action};

  CommandAction.notesControl(String action)
      : type = CommandActionType.notesControl,
        route = null,
        params = {'action': action};

  CommandAction.chatsControl(String action)
      : type = CommandActionType.chatsControl,
        route = null,
        params = {'action': action};

  CommandAction.theme(String theme)
      : type = CommandActionType.theme,
        route = null,
        params = {'theme': theme};

  CommandAction.custom(this.params)
      : type = CommandActionType.custom,
        route = null;
}
