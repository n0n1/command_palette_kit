import 'package:command_palette_kit/command_palette_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  final commands = <CommandModel>[
    const CommandModel(
      id: 'navigate:home',
      title: 'Go to Home',
      description: 'Open the home page',
      category: 'navigation',
      keywords: ['home', 'main'],
      shortcut: 'Cmd+H',
      action: CommandActionModel(type: 'navigate', route: '/'),
    ),
    const CommandModel(
      id: 'theme:dark',
      title: 'Switch to Dark Theme',
      description: 'Use the dark color scheme',
      category: 'theme',
      keywords: ['dark', 'theme'],
      action: CommandActionModel(type: 'theme', params: {'theme': 'dark'}),
    ),
  ];

  runApp(ExampleApp(commands: commands));
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({required this.commands, super.key});

  final List<CommandModel> commands;

  @override
  Widget build(BuildContext context) {
    final repository = CommandRepositoryImpl(
      InMemoryCommandDataSource(commands),
    );

    return MaterialApp(
      title: 'Command Palette Example',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: BlocProvider(
        create: (_) => CommandPaletteBloc(
          getCommands: GetCommands(repository),
          searchCommands: SearchCommands(repository),
        )..add(const LoadCommandsEvent()),
        child: const ExampleHomePage(),
      ),
    );
  }
}

class ExampleHomePage extends StatelessWidget {
  const ExampleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandPaletteOverlay(
      commandExecutor: LoggingCommandExecutor(),
      quickActions: [
        QuickAction.search(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Search quick action')),
            );
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Command Palette Example')),
        body: Center(
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
      ),
    );
  }
}

class LoggingCommandExecutor implements CommandActionExecutor {
  @override
  Future<void> execute(BuildContext context, CommandEntity command) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Executed: ${command.title}')));
  }
}

class InMemoryCommandDataSource implements CommandLocalDataSource {
  const InMemoryCommandDataSource(this.commands);

  final List<CommandModel> commands;

  @override
  Future<List<CommandModel>> getCommands() async => commands;
}
