import 'package:dollar/dollar.dart';
import 'package:flutter/widgets.dart';

mixin $StatelessWidget on StatelessWidget {
  @override
  StatelessElement createElement() {
    // TODO make this composable
    return _$StatelessElementProxy(this);
  }
}

mixin $StatefulWidget on StatefulWidget {
  @override
  StatefulElement createElement() {
    // TODO make this composable
    return _$StatefulElementProxy(this);
  }
}

class $Subtree extends StatelessWidget with $StatelessWidget {
  final Function(BuildContext context) builder;

  const $Subtree({Key key, this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return builder(context);
  }
}

class _$StatefulElementProxy extends StatefulElement with _$ElementContext {
  _$StatefulElementProxy($StatefulWidget widget) : super(widget);

  Widget build() => $unbind(() => buildInContext(super.build));
}

class _$StatelessElementProxy extends StatelessElement with _$ElementContext {
  _$StatelessElementProxy($StatelessWidget widget) : super(widget);

  @override
  Widget build() => $unbind(() => buildInContext(super.build));
}

mixin _$ElementContext on ComponentElement {
  @override
  void mount(Element parent, newSlot) {
    _createContext();
    super.mount(parent, newSlot);
  }

  @override
  void reassemble() {
    super.reassemble();
    _listeners.trigger($End());
    try {
      build();
    } catch (e) {
      _createContext();
    }
  }

  _createContext() {
    _listeners = $Listeners();
    buildInContext = $bind(
      (func) => func(),
      $combineHandlers([
        $onUpdateVar((_) => markNeedsBuild()),
        $listenAt(_listeners),
      ]),
    );
  }

  @override
  void unmount() {
    _listeners.trigger($End());
    super.unmount();
  }

  $Listeners _listeners;
  Widget Function(Widget Function()) buildInContext;
}
