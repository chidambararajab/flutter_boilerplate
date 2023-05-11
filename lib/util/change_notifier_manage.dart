import 'package:flutter/widgets.dart';

/// @weilu https://github.com/simplezhli/flutter_deer
///
/// It is easy to manage ChangeNotifier without repeating template code.
/// Before:
/// ```dart
/// class TestPageState extends State<TestPage> {
///   final TextEditingController _controller = TextEditingController();
///   final FocusNode _nodeText = FocusNode();
///
///   @override
///   void initState() {
///     _controller.addListener(callback);
///     super.initState();
///   }
///
///   @override
///   void dispose() {
///     _controller.removeListener(callback);
///     _controller.dispose();
///     _nodeText.dispose();
///     super.dispose();
///   }
/// }
/// ```
/// Example usage:
/// ```dart
/// class TestPageState extends State<TestPage> with ChangeNotifierMixin<TestPage> {
///   final TextEditingController _controller = TextEditingController();
///   final FocusNode _nodeText = FocusNode();
///
///   @override
///   Map<ChangeNotifier, List<VoidCallback>?>? changeNotifier() {
///     return {
///       _controller: [callback],
///       _nodeText: null,
///     };
///   }
/// }
/// ```
mixin ChangeNotifierMixin<T extends StatefulWidget> on State<T> {
  Map<ChangeNotifier?, List<VoidCallback>?>? _map;

  Map<ChangeNotifier?, List<VoidCallback>?>? changeNotifier();

  @override
  void initState() {
    _map = changeNotifier();

    /// Traverse the data, if the callbacks are not empty, add a listener
    _map?.forEach((changeNotifier, callbacks) {
      if (callbacks != null && callbacks.isNotEmpty) {
        void addListener(VoidCallback callback) {
          changeNotifier?.addListener(callback);
        }

        callbacks.forEach(addListener);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _map?.forEach((changeNotifier, callbacks) {
      if (callbacks != null && callbacks.isNotEmpty) {
        void removeListener(VoidCallback callback) {
          changeNotifier?.removeListener(callback);
        }

        callbacks.forEach(removeListener);
      }
      changeNotifier?.dispose();
    });
    super.dispose();
  }
}
