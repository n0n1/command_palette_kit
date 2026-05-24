import 'package:command_palette_kit/command_palette_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(const ExampleApp());

const demoCommands = <CommandModel>[
  CommandModel(
    id: 'navigate:dashboard',
    title: 'Open Dashboard',
    description: 'Show the main dashboard',
    category: 'navigation',
    keywords: ['home', 'main', 'dashboard'],
    shortcut: 'Cmd+D',
    action: CommandActionModel(type: 'navigate', route: '/dashboard'),
  ),
  CommandModel(
    id: 'navigate:settings',
    title: 'Open Settings',
    description: 'Configure the demo app',
    category: 'navigation',
    keywords: ['settings', 'preferences'],
    shortcut: 'Cmd+,',
    action: CommandActionModel(type: 'navigate', route: '/settings'),
  ),
  CommandModel(
    id: 'theme:light',
    title: 'Use Light Theme',
    description: 'Switch the example to the light color scheme',
    category: 'theme',
    keywords: ['light', 'theme'],
    action: CommandActionModel(type: 'theme', params: {'theme': 'light'}),
  ),
  CommandModel(
    id: 'theme:dark',
    title: 'Use Dark Theme',
    description: 'Switch the example to the dark color scheme',
    category: 'theme',
    keywords: ['dark', 'theme'],
    action: CommandActionModel(type: 'theme', params: {'theme': 'dark'}),
  ),
  CommandModel(
    id: 'debug:snackbar',
    title: 'Show Snackbar',
    description: 'Run a custom command handled by the executor',
    category: 'general',
    keywords: ['snackbar', 'message', 'debug'],
    action: CommandActionModel(type: 'custom', params: {'message': 'Hello'}),
  ),
];

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  ThemeMode _themeMode = ThemeMode.system;
  String _lastAction = 'No command executed yet';

  void _setThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  void _setLastAction(String value) {
    setState(() {
      _lastAction = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final repository = CommandRepositoryImpl(
      const InMemoryCommandDataSource(demoCommands),
    );

    return MaterialApp(
      title: 'Command Palette Example',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: BlocProvider(
        create: (_) => CommandPaletteBloc(
          getCommands: GetCommands(repository),
          searchCommands: SearchCommands(repository),
        )..add(const LoadCommandsEvent()),
        child: ExampleHomePage(
          lastAction: _lastAction,
          commandExecutor: DemoCommandExecutor(
            onThemeModeChanged: _setThemeMode,
            onActionExecuted: _setLastAction,
          ),
        ),
      ),
    );
  }
}

class ExampleHomePage extends StatelessWidget {
  const ExampleHomePage({
    required this.lastAction,
    required this.commandExecutor,
    super.key,
  });

  final String lastAction;
  final CommandActionExecutor commandExecutor;

  @override
  Widget build(BuildContext context) {
    return CommandPaletteOverlay(
      commandExecutor: commandExecutor,
      quickActions: [
        QuickAction.search(
          onTap: () {
            context.read<CommandPaletteBloc>().add(
                  const ShowCommandPaletteEvent(),
                );
          },
        ),
        QuickAction.newNote(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('New note quick action')),
            );
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Command Palette Example')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Press Cmd+K or Ctrl+K to open the palette.',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    lastAction,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Align(
                    child: FilledButton.icon(
                      onPressed: () {
                        context.read<CommandPaletteBloc>().add(
                              const ShowCommandPaletteEvent(),
                            );
                      },
                      icon: const Icon(Icons.keyboard_command_key),
                      label: const Text('Open command palette'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DemoCommandExecutor implements CommandActionExecutor {
  const DemoCommandExecutor({
    required this.onThemeModeChanged,
    required this.onActionExecuted,
  });

  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<String> onActionExecuted;

  @override
  Future<void> execute(BuildContext context, CommandEntity command) async {
    final theme = command.action.params?['theme'];
    if (theme == 'light') {
      onThemeModeChanged(ThemeMode.light);
    } else if (theme == 'dark') {
      onThemeModeChanged(ThemeMode.dark);
    }

    final message = 'Executed: ${command.title}';
    onActionExecuted(message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class InMemoryCommandDataSource implements CommandLocalDataSource {
  const InMemoryCommandDataSource(this.commands);

  final List<CommandModel> commands;

  @override
  Future<List<CommandModel>> getCommands() async => commands;
}
