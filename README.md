# Command Palette

Command palette (Alfred/Zed style) for Flutter apps.

## Features

- Searchable command list.
- Keyboard navigation with arrow keys, Enter, and Escape.
- Cmd+K and Ctrl+K shortcuts through `CommandPaletteOverlay`.
- Optional quick actions.
- JSON-backed command loading.
- App-defined command execution through `CommandActionExecutor`.

## Installation

```yaml
dependencies:
  command_palette_kit: ^0.1.0
```

## Basic Usage

```dart
import 'package:command_palette_kit/command_palette_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCommandExecutor implements CommandActionExecutor {
  @override
  Future<void> execute(BuildContext context, CommandEntity command) async {
    // Execute navigation, theme changes, or any other app-specific action.
  }
}

BlocProvider(
  create: (_) => CommandPaletteBloc(
    getCommands: GetCommands(repository),
    searchCommands: SearchCommands(repository),
  )..add(const LoadCommandsEvent()),
  child: CommandPaletteOverlay(
    commandExecutor: MyCommandExecutor(),
    quickActions: [
      QuickAction.search(onTap: () {}),
    ],
    child: const MyAppHome(),
  ),
);
```

You can also render the palette widget directly when you already manage the
`CommandPaletteBloc` and visibility state yourself:

```dart
CommandPaletteWidget(
  commandExecutor: executor,
  quickActions: quickActions,
)
```

## Loading Commands From JSON

Add a JSON file to your app assets:

```json
{
  "commands": [
    {
      "id": "navigate:home",
      "title": "Go to Home",
      "description": "Open the home page",
      "category": "navigation",
      "keywords": ["home", "main"],
      "shortcut": "Cmd+H",
      "action": {
        "type": "navigate",
        "route": "/"
      }
    }
  ]
}
```

Then wire the data source, repository, and BLoC:

```dart
final dataSource = CommandLocalDataSourceImpl(
  isDevelopment: true,
  commandsPath: 'assets/data/commands.json',
);
final repository = CommandRepositoryImpl(dataSource);
final bloc = CommandPaletteBloc(
  getCommands: GetCommands(repository),
  searchCommands: SearchCommands(repository),
);
```

## Opening The Palette

`CommandPaletteOverlay` registers Cmd+K and Ctrl+K shortcuts. You can also show
the palette manually:

```dart
context.read<CommandPaletteBloc>().add(const ShowCommandPaletteEvent());
```

## Example

See the `example/` directory for a minimal Flutter app.
