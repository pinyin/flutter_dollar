# flutter_dollar

Keep state in your `build()` function.

## Getting Started

Add corresponding mixin to your `StatefulWidget` or `StatelessWidget`:

```dart

import 'package:flutter_dollar/flutter_dollar.dart';

class Stateful extends StatefulWidget with $StatefulWidget {
    // logic
}

class Stateless extends StatelessWidget with $StatelessWidget {
    // logic
}

```

You can now keep state inside your `build()` method: 

```dart

Widget build(BuildContext context) {
  final a = $var(()=> 1);
  
  return Button(onClick: ()=> a.value ++); // widget will be automatically updated after click
}

```

There's many other dollar functions.
