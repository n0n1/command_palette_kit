import 'package:command_palette_kit/src/domain/entities/command_entity.dart';
import 'package:command_palette_kit/src/domain/repositories/command_repository.dart';

/// Use case for searching commands
class SearchCommands {
  final CommandRepository repository;

  SearchCommands(this.repository);

  Future<List<CommandEntity>> call(String query) async {
    return repository.searchCommands(query);
  }
}
