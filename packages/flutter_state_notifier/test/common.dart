import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
// ignore: undefined_hidden_name
import 'package:provider/provider.dart' hide Locator;
import 'package:state_notifier/state_notifier.dart';

InheritedContext<T?> findInheritedContext<T>() {
  return find
      .byElementPredicate((e) => e is InheritedContext<T?>)
      .first
      .evaluate()
      .first as InheritedContext<T?>;
}

class TestNotifier extends StateNotifier<int> with LocatorMixin {
  TestNotifier(int state, {this.onInitState, this.onUpdate, this.onDispose})
      : super(state);

  int get currentState => state;

  void increment() {
    state++;
  }

  final void Function()? onInitState;
  final void Function(Locator watch)? onUpdate;
  final void Function()? onDispose;

  @override
  // ignore: unnecessary_overrides, remvove protected
  Locator get read => super.read;

  @override
  void initState() {
    onInitState?.call();
  }

  @override
  void update(T Function<T>() watch) {
    onUpdate?.call(watch);
  }

  @override
  void dispose() {
    onDispose?.call();
    super.dispose();
  }
}

class Listener extends Mock {
  void call(int value);
}

class UpdateMock extends Mock {
  UpdateMock([void Function(Locator watch)? cb]) {
    if (cb != null) {
      when(call(any)).thenAnswer((realInvocation) {
        final locator = realInvocation.positionalArguments.first as Locator;
        return cb(locator);
      });
    }
  }
  void call(Locator? watch);
}

class InitStateMock extends Mock {
  InitStateMock([void Function()? cb]) {
    if (cb != null) {
      when(call()).thenAnswer((realInvocation) {
        return cb();
      });
    }
  }
  void call();
}

class DisposeMock extends Mock {
  DisposeMock([void Function()? cb]) {
    if (cb != null) {
      when(call()).thenAnswer((realInvocation) {
        return cb();
      });
    }
  }
  void call();
}

class ErrorListenerMock extends Mock {
  void call(dynamic error, StackTrace stackTrace);
}

BuildContext get context => find.byType(Context).evaluate().single;

class Context extends StatelessWidget {
  const Context({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

int buildCountOf<T extends TextConsumer<dynamic>>(T value) {
  final element = find.byWidget(value).evaluate().single as StatefulElement;
  return (element.state as _TextConsumerState).buildCount;
}

class TextConsumer<T> extends StatefulWidget {
  const TextConsumer({Key? key}) : super(key: key);
  @override
  _TextConsumerState<T> createState() => _TextConsumerState<T>();
}

class _TextConsumerState<T> extends State<TextConsumer<T>> {
  int buildCount = 0;
  @override
  Widget build(BuildContext context) {
    buildCount++;
    return Text(
      Provider.of<T>(context).toString(),
      textDirection: TextDirection.ltr,
    );
  }
}

class Controller1 extends StateNotifier<Counter1> {
  Controller1() : super(Counter1(0));

  void increment() => state = Counter1(state.count + 1);
}

class Counter1 {
  Counter1(this.count);

  final int count;
}

class Controller2 extends StateNotifier<Counter2> with LocatorMixin {
  Controller2() : super(Counter2(0));

  void increment() => state = Counter2(state.count + 1);

  @override
  void update(T Function<T>() watch) {
    watch<Counter1>();
    watch<Controller1>();
  }
}

class Counter2 {
  Counter2(this.count);

  final int count;
}

class A with DiagnosticableTreeMixin {}

class B with DiagnosticableTreeMixin {}

class C with DiagnosticableTreeMixin {}

class D with DiagnosticableTreeMixin {}

class E with DiagnosticableTreeMixin {}

class F with DiagnosticableTreeMixin {}

class MockCombinedBuilder extends Mock {
  Widget call(CombinedState? foo) {
    return super.noSuchMethod(
      Invocation.method(#call, [foo]),
      returnValue: Container(),
      returnValueForMissingStub: Container(),
    ) as Widget;
  }
}

class CombinerMock extends Mock {
  CombinedState call(BuildContext? context, A? a, CombinedState? foo) {
    return super.noSuchMethod(
      Invocation.method(#call, [context, a, foo]),
      returnValue: const CombinedState(),
      returnValueForMissingStub: const CombinedState(),
    ) as CombinedState;
  }
}

@immutable
class CombinedState extends DiagnosticableTree {
  const CombinedState([
    this.context,
    this.previous,
    this.a,
    this.b,
    this.c,
    this.d,
    this.e,
    this.f,
  ]);

  final A? a;
  final B? b;
  final C? c;
  final D? d;
  final E? e;
  final F? f;
  final CombinedState? previous;
  final BuildContext? context;

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) =>
      other is CombinedState &&
      other.context == context &&
      other.previous == previous &&
      other.a == a &&
      other.b == b &&
      other.c == c &&
      other.e == e &&
      other.f == f;

  // fancy toString for debug purposes.
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.properties.addAll([
      DiagnosticsProperty('a', a, defaultValue: null),
      DiagnosticsProperty('b', b, defaultValue: null),
      DiagnosticsProperty('c', c, defaultValue: null),
      DiagnosticsProperty('d', d, defaultValue: null),
      DiagnosticsProperty('e', e, defaultValue: null),
      DiagnosticsProperty('f', f, defaultValue: null),
      DiagnosticsProperty('previous', previous, defaultValue: null),
      DiagnosticsProperty('context', context, defaultValue: null),
    ]);
  }
}

class CombinedStateNotifier extends StateNotifier<CombinedState>
    with LocatorMixin {
  CombinedStateNotifier() : super(const CombinedState());
}
