import 'package:command_palette_kit/src/domain/entities/command_entity.dart';
import 'package:command_palette_kit/src/domain/usecases/get_commands.dart';
import 'package:command_palette_kit/src/domain/usecases/search_commands.dart';
import 'package:command_palette_kit/src/presentation/bloc/command_palette_event.dart';
import 'package:command_palette_kit/src/presentation/bloc/command_palette_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// BLoC for command palette
class CommandPaletteBloc
    extends Bloc<CommandPaletteEvent, CommandPaletteState> {
  final GetCommands getCommands;
  final SearchCommands searchCommands;

  CommandPaletteBloc({required this.getCommands, required this.searchCommands})
      : super(const CommandPaletteInitial()) {
    on<LoadCommandsEvent>(_onLoadCommands);
    on<SearchCommandsEvent>(_onSearchCommands);
    on<ExecuteCommandEvent>(_onExecuteCommand);
    on<ShowCommandPaletteEvent>(_onShowCommandPalette);
    on<HideCommandPaletteEvent>(_onHideCommandPalette);
    on<ToggleCommandPaletteEvent>(_onToggleCommandPalette);
  }

  Future<List<CommandEntity>> _loadCommands() async {
    return await getCommands();
  }

  Future<void> _onLoadCommands(
    LoadCommandsEvent event,
    Emitter<CommandPaletteState> emit,
  ) async {
    emit(const CommandPaletteLoading());

    try {
      final commands = await _loadCommands();
      emit(CommandPaletteLoaded(commands: commands));
    } catch (e) {
      emit(const CommandPaletteError('Failed to load commands'));
    }
  }

  Future<void> _onSearchCommands(
    SearchCommandsEvent event,
    Emitter<CommandPaletteState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CommandPaletteLoaded) return;

    try {
      final commands = await searchCommands(event.query);
      emit(currentState.copyWith(commands: commands, searchQuery: event.query));
    } catch (e) {
      emit(const CommandPaletteError('Failed to search commands'));
    }
  }

  Future<void> _onExecuteCommand(
    ExecuteCommandEvent event,
    Emitter<CommandPaletteState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CommandPaletteLoaded) return;

    emit(CommandExecuting(event.command));

    // Wait a bit to show execution feedback
    await Future.delayed(const Duration(milliseconds: 100));

    emit(CommandExecuted(event.command));

    // Return to loaded state with palette hidden
    emit(currentState.copyWith(isVisible: false, searchQuery: ''));
  }

  Future<void> _onShowCommandPalette(
    ShowCommandPaletteEvent event,
    Emitter<CommandPaletteState> emit,
  ) async {
    final currentState = state;
    if (currentState is CommandPaletteLoaded) {
      emit(currentState.copyWith(isVisible: true));
      return;
    }

    if (currentState is CommandPaletteLoading) {
      return;
    }

    emit(const CommandPaletteLoading());

    try {
      final commands = await _loadCommands();
      emit(CommandPaletteLoaded(commands: commands, isVisible: true));
    } catch (e) {
      emit(const CommandPaletteError('Failed to load commands'));
    }
  }

  void _onHideCommandPalette(
    HideCommandPaletteEvent event,
    Emitter<CommandPaletteState> emit,
  ) {
    final currentState = state;
    if (currentState is CommandPaletteLoaded) {
      emit(currentState.copyWith(isVisible: false, searchQuery: ''));
    }
  }

  Future<void> _onToggleCommandPalette(
    ToggleCommandPaletteEvent event,
    Emitter<CommandPaletteState> emit,
  ) async {
    final currentState = state;
    if (currentState is CommandPaletteLoaded) {
      emit(
        currentState.copyWith(
          isVisible: !currentState.isVisible,
          searchQuery: '',
        ),
      );
      return;
    }

    if (currentState is CommandPaletteLoading) {
      return;
    }

    emit(const CommandPaletteLoading());

    try {
      final commands = await _loadCommands();
      emit(CommandPaletteLoaded(commands: commands, isVisible: true));
    } catch (e) {
      emit(const CommandPaletteError('Failed to load commands'));
    }
  }
}
