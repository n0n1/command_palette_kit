import 'package:command_palette_kit/src/domain/entities/command_entity.dart';

/// Repository interface for commands
abstract class CommandRepository {
  /// Get all available commands
  Future<List<CommandEntity>> getCommands();

  /// Search commands by query
  Future<List<CommandEntity>> searchCommands(String query);
}
