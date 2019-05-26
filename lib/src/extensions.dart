import 'package:collection/collection.dart';
import 'package:dollar/dollar.dart';

T $memo<T>(T compute(), List deps) {
  return $cache(compute, $diff(deps, _shallowEqual));
}

final _shallowEqual = const IterableEquality().equals;
