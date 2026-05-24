import 'package:command_palette_kit/src/presentation/bloc/command_palette_bloc.dart';
import 'package:command_palette_kit/src/presentation/bloc/command_palette_event.dart';
import 'package:command_palette_kit/src/presentation/bloc/command_palette_state.dart';
import 'package:command_palette_kit/src/presentation/services/command_action_executor.dart';
import 'package:command_palette_kit/src/presentation/widgets/command_palette_widget.dart';
import 'package:command_palette_kit/src/domain/entities/quick_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Overlay wrapper for command palette with keyboard shortcuts
class CommandPaletteOverlay extends StatefulWidget {
  final Widget child;
  final CommandActionExecutor commandExecutor;
  final List<QuickAction> quickActions;

  const CommandPaletteOverlay({
    required this.child,
    required this.commandExecutor,
    this.quickActions = const [],
    super.key,
  });

  @override
  State<CommandPaletteOverlay> createState() => _CommandPaletteOverlayState();
}

class _CommandPaletteOverlayState extends State<CommandPaletteOverlay> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<CommandPaletteBloc, CommandPaletteState>(
      listener: (context, state) {},
      child: FocusScope(
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () {
              context.read<CommandPaletteBloc>().add(
                    const ToggleCommandPaletteEvent(),
                  );
            },
            const SingleActivator(LogicalKeyboardKey.keyK, control: true): () {
              context.read<CommandPaletteBloc>().add(
                    const ToggleCommandPaletteEvent(),
                  );
            },
          },
          child: Builder(
            builder: (context) {
              return Stack(
                children: [
                  widget.child,
                  CommandPaletteWidget(
                    commandExecutor: widget.commandExecutor,
                    quickActions: widget.quickActions,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
