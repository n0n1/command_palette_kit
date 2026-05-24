import 'package:command_palette_kit/src/domain/entities/command_entity.dart';
import 'package:flutter/material.dart';

/// Abstraction for executing command palette actions.
abstract class CommandActionExecutor {
  Future<void> execute(BuildContext context, CommandEntity command);
}
