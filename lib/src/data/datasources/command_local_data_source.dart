import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:command_palette_kit/src/data/models/command_model.dart';

/// Local data source for commands
abstract class CommandLocalDataSource {
  /// Load commands from JSON file
  Future<List<CommandModel>> getCommands();
}

/// Implementation of command local data source
class CommandLocalDataSourceImpl implements CommandLocalDataSource {
  static const String defaultCommandsPath = 'assets/data/commands.json';
  static const Set<String> _disabledCommandIds = {
    'orbit:reset',
    'orbit:pause',
    'orbit:resume',
    'orbit:add_electron',
    'orbit:show_info',
    'orbit:hide_info',
  };

  final bool isDevelopment;
  final String commandsPath;

  const CommandLocalDataSourceImpl({
    required this.isDevelopment,
    this.commandsPath = defaultCommandsPath,
  });

  @override
  Future<List<CommandModel>> getCommands() async {
    final jsonString = await rootBundle.loadString(commandsPath);
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    final commandsJson = jsonData['commands'] as List<dynamic>;

    var commands = commandsJson
        .map((json) => CommandModel.fromJson(json as Map<String, dynamic>))
        .toList();

    commands = commands
        .where((command) => !_disabledCommandIds.contains(command.id))
        .toList();

    if (!isDevelopment) {
      commands = commands.where((cmd) => !cmd.id.startsWith('admin:')).toList();
    }

    return commands;
  }
}
