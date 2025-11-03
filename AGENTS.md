# Flutter rules

- Use StatelessWidget for UI components without internal state.
- Use StatefulWidget for components that need to maintain state:

```dart
class Counter extends StatefulWidget {
  @override
  _CounterState createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int _count = 0;
  
  void _increment() {
    setState(() { _count++; });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: $_count'),
        ElevatedButton(onPressed: _increment, child: Text('Increment')),
      ],
    );
  }
}
```

- Use state management solutions (Provider, Bloc, Riverpod) for complex apps.
- Organize code with proper folder structure (models, screens, widgets, services).
- Use named routes for navigation with Navigator.pushNamed().
- Use async/await for asynchronous operations with proper error handling.
- Use themes for consistent styling across the app.
