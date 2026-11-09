# package_navigator_v1

Flutter navigation examples covering `MaterialPageRoute`, named routes, and a global navigator key.

Add the package to the app's `pubspec.yaml`:

```yaml
dependencies:
  package_navigator_v1:
    path: packages/package_navigator_v1
```

Use the default example:

```dart
import 'package:package_navigator_v1/package_navigator_v1.dart';

void main() => runPackageNavigatorV1App();
```

To run another example, call `runApp(const PushNamed())` or `runApp(const GlobalKeyExampleApp())` after importing Flutter's material library. Each example also has its own `main.dart` under `lib/`.
