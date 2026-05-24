import 'package:command_palette_kit/src/domain/entities/command_entity.dart';

/// Command model for JSON serialization
class CommandModel {
  final String id;
  final String title;
  final String? description;
  final String? category;
  final List<String> keywords;
  final String? icon;
  final String? shortcut;
  final CommandActionModel action;

  const CommandModel({
    required this.id,
    required this.title,
    this.description,
    this.category,
    this.keywords = const [],
    this.icon,
    this.shortcut,
    required this.action,
  });

  factory CommandModel.fromJson(Map<String, dynamic> json) {
    return CommandModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      icon: json['icon'] as String?,
      shortcut: json['shortcut'] as String?,
      action: CommandActionModel.fromJson(
        json['action'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      'keywords': keywords,
      if (icon != null) 'icon': icon,
      if (shortcut != null) 'shortcut': shortcut,
      'action': action.toJson(),
    };
  }

  CommandEntity toEntity() {
    return CommandEntity(
      id: id,
      title: title,
      description: description,
      category: category,
      keywords: keywords,
      icon: icon,
      shortcut: shortcut,
      action: action.toEntity(),
    );
  }
}

/// Command action model
class CommandActionModel {
  final String type;
  final String? route;
  final Map<String, dynamic>? params;

  const CommandActionModel({required this.type, this.route, this.params});

  factory CommandActionModel.fromJson(Map<String, dynamic> json) {
    return CommandActionModel(
      type: json['type'] as String,
      route: json['route'] as String?,
      params: json['params'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (route != null) 'route': route,
      if (params != null) 'params': params,
    };
  }

  CommandAction toEntity() {
    final actionType = CommandActionType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => CommandActionType.custom,
    );

    return CommandAction(type: actionType, route: route, params: params);
  }
}
