import 'package:command_palette_kit/src/domain/entities/command_entity.dart';
import 'package:equatable/equatable.dart';

/// Base class for command palette events
abstract class CommandPaletteEvent extends Equatable {
  const CommandPaletteEvent();

  @override
  List<Object?> get props => [];
}

/// Load commands event
class LoadCommandsEvent extends CommandPaletteEvent {
  const LoadCommandsEvent();
}

/// Search commands event
class SearchCommandsEvent extends CommandPaletteEvent {
  final String query;

  const SearchCommandsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Execute command event
class ExecuteCommandEvent extends CommandPaletteEvent {
  final CommandEntity command;

  const ExecuteCommandEvent(this.command);

  @override
  List<Object?> get props => [command];
}

/// Show command palette event
class ShowCommandPaletteEvent extends CommandPaletteEvent {
  const ShowCommandPaletteEvent();
}

/// Hide command palette event
class HideCommandPaletteEvent extends CommandPaletteEvent {
  const HideCommandPaletteEvent();
}

/// Toggle command palette event
class ToggleCommandPaletteEvent extends CommandPaletteEvent {
  const ToggleCommandPaletteEvent();
}
