[![pub package](https://img.shields.io/pub/v/flutter_state_notifier.svg)](https://pub.dartlang.org/packages/flutter_state_notifier)

Welcome to **flutter_state_notifier**~

This repository is a side-package that is destined to be used together with **state_notifier**.

It adds extra Flutter bindings to [StateNotifier], such as [provider] integration.

# The available widgets

## [StateNotifierProvider]

[StateNotifierProvider] is the equivalent of [ChangeNotifierProvider] but for
[StateNotifier].

Its job is to both create a [StateNotifier] and dispose it when the provider
is removed from the widget tree.

If the created [StateNotifier] uses [LocatorMixin], [StateNotifierProvider] will
also do the necessary to make `read`/`update` work with [provider].

It is used like most providers, with a small difference:\
Instead of exposing one value, it exposes two values at the same time:

- The [StateNotifier] instance
- The `state` of the [StateNotifier]

Which means that when you write:

```dart
class MyState {}

class MyStateNotifier extends StateNotifier<MyState> {
  MyStateNotifier(): super(MyState());
}

// ...

MultiProvider(
  providers: [
    StateNotifierProvider<MyStateNotifier, MyState>(create: (_) => MyStateNotifier()).
  ]
)
```

This allows you to both:

- obtain the [StateNotifier] in the widget tree, by writing `context.read<MyStateNotifier>()`
- obtain and observe the current [MyState], through `context.watch<MyState>()`

## [StateNotifierProxyProvider]

[StateNotifierProxyProvider] is the equivalent of [ChangeNotifierProxyProvider] but for
[StateNotifier].

This provider will listen to values coming from other providers and update the [StateNotifier] accordingly.

When possible, it is best practice to only modify the state of the current [StateNotifier] instance during the update operation, and not to return a new instance to avoid loss of the state and unnecessary overhead:

```dart
StateNotifierProxyProvider<MyModel, MyStateNotifier, MyState>(
  create: (_) => MyStateNotifier(),
  update: (_, myModel, myNotifier) => myNotifier
    ..update(myModel),
  child: ...
);
```

However, returning a new [StateNotifier] instance is possible and the provider will update its descendents correctly and only if needed:

```dart
StateNotifierProxyProvider<MyModel, MyStateNotifier, MyState>(
  update: (_, myModel, myNotifier) => MyStateNotifier(myModel),
  child: ...
);
```

[StateNotifierProxyProvider] comes in different variants based on how many values we want to depend on: [StateNotifierProxyProvider0], [StateNotifierProxyProvider], [StateNotifierProxyProvider2], [StateNotifierProxyProvider3], [StateNotifierProxyProvider4], [StateNotifierProxyProvider5], [StateNotifierProxyProvider6].


## [StateNotifierBuilder]

[StateNotifierBuilder] is equivalent to `ValueListenableBuilder` from Flutter.

It allows you to listen to a [StateNotifier] and rebuild your UI accordingly, but
does not create/dispose/provide the object.

As opposed to [StateNotifierProvider], this will **not** make `read`/`update` of
[StateNotifier] work.

It is used as such:

```dart
class MyState {}

class MyStateNotifier extends StateNotifier<MyState> {
  MyStateNotifier(): super(MyState());
}

// ...

MyStateNotifier stateNotifier;

return StateNotifierBuilder<MyState>(
  stateNotifier: stateNotifier,
  builder: (BuildContext context, MyState state, Widget child) {
    return Text('$state');
  },
)
```

[changenotifierprovider]: https://pub.dev/documentation/provider/latest/provider/ChangeNotifierProvider-class.html
[changenotifierproxyprovider]: https://pub.dev/documentation/provider/latest/provider/ChangeNotifierProxyProvider-class.html
[statenotifier]: https://pub.dev/documentation/state_notifier/latest/state_notifier/StateNotifier-class.html
[statenotifierprovider]: https://pub.dev/documentation/flutter_state_notifier/latest/flutter_state_notifier/StateNotifierProvider-class.html
[statenotifierproxyprovider0]: https://pub.dev/documentation/flutter_state_notifier/latest/flutter_state_notifier/StateNotifierProxyProvider0-class.html
[statenotifierproxyprovider]: https://pub.dev/documentation/flutter_state_notifier/latest/flutter_state_notifier/StateNotifierProxyProvider-class.html
[statenotifierproxyprovider2]: https://pub.dev/documentation/flutter_state_notifier/latest/flutter_state_notifier/StateNotifierProxyProvider2-class.html
[statenotifierproxyprovider3]: https://pub.dev/documentation/flutter_state_notifier/latest/flutter_state_notifier/StateNotifierProxyProvider3-class.html
[statenotifierproxyprovider4]: https://pub.dev/documentation/flutter_state_notifier/latest/flutter_state_notifier/StateNotifierProxyProvider4-class.html
[statenotifierproxyprovider5]: https://pub.dev/documentation/flutter_state_notifier/latest/flutter_state_notifier/StateNotifierProxyProvider5-class.html
[statenotifierproxyprovider6]: https://pub.dev/documentation/flutter_state_notifier/latest/flutter_state_notifier/StateNotifierProxyProvider6-class.html
[statenotifierbuilder]: https://pub.dev/documentation/flutter_state_notifier/latest/flutter_state_notifier/StateNotifierBuilder-class.html
[LocatorMixin]: https://pub.dev/documentation/state_notifier/latest/state_notifier/LocatorMixin-class.html
[provider]: https://pub.dev/packages/provider
