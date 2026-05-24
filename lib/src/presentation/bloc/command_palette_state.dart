import 'package:command_palette_kit/src/domain/entities/command_entity.dart';
import 'package:equatable/equatable.dart';

/// Base class for command palette states
abstract class CommandPaletteState extends Equatable {
  const CommandPaletteState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CommandPaletteInitial extends CommandPaletteState {
  const CommandPaletteInitial();
}

/// Loading state
class CommandPaletteLoading extends CommandPaletteState {
  const CommandPaletteLoading();
}

/// Loaded state with commands
class CommandPaletteLoaded extends CommandPaletteState {
  final List<CommandEntity> commands;
  final bool isVisible;
  final String searchQuery;

  const CommandPaletteLoaded({
    required this.commands,
    this.isVisible = false,
    this.searchQuery = '',
  });

  CommandPaletteLoaded copyWith({
    List<CommandEntity>? commands,
    bool? isVisible,
    String? searchQuery,
  }) {
    return CommandPaletteLoaded(
      commands: commands ?? this.commands,
      isVisible: isVisible ?? this.isVisible,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [commands, isVisible, searchQuery];
}

/// Error state
class CommandPaletteError extends CommandPaletteState {
  final String message;

  const CommandPaletteError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Command executing state
class CommandExecuting extends CommandPaletteState {
  final CommandEntity command;

  const CommandExecuting(this.command);

  @override
  List<Object?> get props => [command];
}

/// Command executed state
class CommandExecuted extends CommandPaletteState {
  final CommandEntity command;

  const CommandExecuted(this.command);

  @override
  List<Object?> get props => [command];
}
