import 'package:dollar/dollar.dart';
import 'package:flutter/widgets.dart';

mixin $State<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    _createContext();
  }

  @override
  void reassemble() {
    super.reassemble();
    _listeners.trigger($ContextTerminated());
    _createContext();
  }

  _createContext() {
    _listeners = $Listeners();
    $isolate(() {
      _build = $bind(
        $build,
        $combineHandlers([
          $onVarUpdated((_) {
            setState(() {});
          }),
          $onListened(_listeners),
        ]),
      );
    });
  }

  @override
  void dispose() {
    _listeners.trigger($ContextTerminated());
    super.dispose();
  }

  $Listeners _listeners;
  Widget build(BuildContext context) => _build(context);

  Widget $build(BuildContext context);

  Widget Function(BuildContext context) _build;
}
