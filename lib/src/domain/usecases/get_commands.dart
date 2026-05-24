import 'package:command_palette_kit/src/domain/entities/command_entity.dart';
import 'package:command_palette_kit/src/domain/repositories/command_repository.dart';

/// Use case for getting all commands
class GetCommands {
  final CommandRepository repository;

  GetCommands(this.repository);

  Future<List<CommandEntity>> call() async {
    return repository.getCommands();
  }
}
