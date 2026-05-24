import 'dart:async';
import 'package:command_palette_kit/src/domain/entities/command_entity.dart';
import 'package:command_palette_kit/src/domain/entities/quick_action.dart';
import 'package:command_palette_kit/src/presentation/bloc/command_palette_bloc.dart';
import 'package:command_palette_kit/src/presentation/bloc/command_palette_event.dart';
import 'package:command_palette_kit/src/presentation/bloc/command_palette_state.dart';
import 'package:command_palette_kit/src/presentation/services/command_action_executor.dart';
import 'package:command_palette_kit/src/presentation/widgets/palette_footer.dart';
import 'package:command_palette_kit/src/presentation/widgets/quick_actions_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Command palette widget - Alfred/Zed style
class CommandPaletteWidget extends StatefulWidget {
  final CommandActionExecutor commandExecutor;
  final List<QuickAction> quickActions;
  final String Function(BuildContext context, CommandEntity command)?
      commandTitleBuilder;
  final String? Function(BuildContext context, CommandEntity command)?
      commandDescriptionBuilder;

  const CommandPaletteWidget({
    required this.commandExecutor,
    this.quickActions = const [],
    this.commandTitleBuilder,
    this.commandDescriptionBuilder,
    super.key,
  });

  @override
  State<CommandPaletteWidget> createState() => _CommandPaletteWidgetState();
}

class _CommandPaletteWidgetState extends State<CommandPaletteWidget> {
  String _searchText = '';
  int _selectedIndex = 0;
  Timer? _debounce;
  bool _wasVisible = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode(skipTraversal: true);
  CommandEntity? _pendingCommand;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchControllerChanged);
    _focusNode.addListener(_onFocusChanged);

    // Handle keyboard events for navigation and command execution.
    _focusNode.onKeyEvent = (node, event) {
      if (event is! KeyDownEvent) return KeyEventResult.ignored;

      final state = context.read<CommandPaletteBloc>().state;
      if (state is! CommandPaletteLoaded) return KeyEventResult.ignored;

      final commands = state.commands;

      if (event.logicalKey == LogicalKeyboardKey.arrowDown &&
          commands.isNotEmpty) {
        setState(() {
          _selectedIndex = (_selectedIndex + 1) % commands.length;
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp &&
          commands.isNotEmpty) {
        setState(() {
          _selectedIndex =
              (_selectedIndex - 1 + commands.length) % commands.length;
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter &&
          commands.isNotEmpty) {
        setState(() {
          _pendingCommand = commands[_selectedIndex];
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        context.read<CommandPaletteBloc>().add(const HideCommandPaletteEvent());
        return KeyEventResult.handled;
      }

      return KeyEventResult.ignored;
    };
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchControllerChanged);
    _searchController.dispose();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onSearchControllerChanged() {
    final value = _searchController.text;
    if (value == _searchText) {
      return;
    }

    setState(() {
      _searchText = value;
    });
    _onSearchChanged();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _selectedIndex = 0;

    _debounce = Timer(const Duration(milliseconds: 150), () {
      if (mounted) {
        context.read<CommandPaletteBloc>().add(
              SearchCommandsEvent(_searchText),
            );
      }
    });
  }

  void _executeCommand(BuildContext context, CommandEntity command) {
    _focusNode.unfocus();
    widget.commandExecutor.execute(context, command);
    context.read<CommandPaletteBloc>().add(const HideCommandPaletteEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommandPaletteBloc, CommandPaletteState>(
      listener: (context, state) {
        if (state is CommandPaletteLoaded) {
          if (state.isVisible && !_wasVisible) {
            _wasVisible = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _focusNode.requestFocus();
                setState(() {
                  _selectedIndex = 0;
                  _searchText = '';
                  _searchController.clear();
                  _pendingCommand = null;
                });
                context.read<CommandPaletteBloc>().add(
                      const SearchCommandsEvent(''),
                    );
              }
            });
          } else if (!state.isVisible && _wasVisible) {
            _wasVisible = false;
            _debounce?.cancel();
            _focusNode.unfocus();
            setState(() {
              _searchController.clear();
              _searchText = '';
              _selectedIndex = 0;
            });
          }
        }
      },
      builder: (context, state) {
        if (state is! CommandPaletteLoaded || !state.isVisible) {
          return const SizedBox.shrink();
        }

        if (_pendingCommand != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _pendingCommand != null) {
              final command = _pendingCommand!;
              _pendingCommand = null;
              _executeCommand(context, command);
            }
          });
        }

        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return GestureDetector(
          onTap: () {
            _focusNode.unfocus();
            context.read<CommandPaletteBloc>().add(
                  const HideCommandPaletteEvent(),
                );
          },
          child: Container(
            color: colorScheme.surface.withValues(alpha: 0.6),
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 600,
                    constraints: const BoxConstraints(maxHeight: 500),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSearchBar(colorScheme, textTheme),
                        if (widget.quickActions.isNotEmpty)
                          QuickActionsSection(actions: widget.quickActions),
                        if (state.commands.isNotEmpty)
                          _buildCommandList(state.commands)
                        else
                          _buildEmptyState(),
                        const PaletteFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _focusNode.hasFocus
            ? colorScheme.primary.withValues(alpha: 0.04)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: _focusNode.hasFocus
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              autofocus: false,
              textInputAction: TextInputAction.search,
              minLines: 1,
              maxLines: 1,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: colorScheme.primary,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: 'Type a command or search...',
                hintStyle: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                filled: false,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandList(List<CommandEntity> commands) {
    return Flexible(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: commands.length,
        itemBuilder: (context, index) {
          final command = commands[index];
          final isSelected = index == _selectedIndex;

          return _buildCommandItem(command, isSelected);
        },
      ),
    );
  }

  Widget _buildCommandItem(CommandEntity command, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final categoryColor = _getCategoryColor(colorScheme, command.category);
    final commandTitle =
        widget.commandTitleBuilder?.call(context, command) ?? command.title;
    final commandDescription =
        widget.commandDescriptionBuilder?.call(context, command) ??
            command.description;

    return InkWell(
      onTap: () {
        setState(() {
          _pendingCommand = command;
        });
      },
      onHover: (hovering) {
        if (hovering) {
          setState(() {
            _selectedIndex = context.read<CommandPaletteBloc>().state.let(
                  (state) => state is CommandPaletteLoaded
                      ? state.commands.indexOf(command)
                      : 0,
                );
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? categoryColor : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: categoryColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  _getCategoryIcon(command.category),
                  size: 18,
                  color: categoryColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    commandTitle,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (commandDescription != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      commandDescription,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.9,
                        ),
                        fontSize: 12,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (command.shortcut != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  command.shortcut!,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10,
                    height: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'No commands found',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(ColorScheme colorScheme, String? category) {
    switch (category?.toLowerCase()) {
      case 'orbit':
        return colorScheme.primary;
      case 'navigation':
        return colorScheme.secondary;
      case 'theme':
        return colorScheme.tertiary;
      default:
        return colorScheme.primary;
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'orbit':
        return Icons.blur_circular;
      case 'navigation':
        return Icons.navigation_outlined;
      case 'theme':
        return Icons.palette_outlined;
      case 'general':
        return Icons.settings_outlined;
      default:
        return Icons.flash_on;
    }
  }
}

extension _StateExtension<T> on T {
  R let<R>(R Function(T) block) => block(this);
}
