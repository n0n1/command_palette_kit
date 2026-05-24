import 'package:command_palette_kit/src/data/datasources/command_local_data_source.dart';
import 'package:command_palette_kit/src/domain/entities/command_entity.dart';
import 'package:command_palette_kit/src/domain/repositories/command_repository.dart';

/// Implementation of command repository
class CommandRepositoryImpl implements CommandRepository {
  final CommandLocalDataSource localDataSource;

  CommandRepositoryImpl(this.localDataSource);

  @override
  Future<List<CommandEntity>> getCommands() async {
    final commandModels = await localDataSource.getCommands();
    return commandModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<CommandEntity>> searchCommands(String query) async {
    final commandModels = await localDataSource.getCommands();
    final commands = commandModels.map((model) => model.toEntity()).toList();

    if (query.isEmpty) {
      return commands;
    }

    return commands.where((cmd) => cmd.matches(query)).toList();
  }
}
