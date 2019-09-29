# voyager_bloc

A new Flutter package project.

## Class Hierarchy & Bloc Plugin Builder

Flutter Dart has no reflection and `runtimeType` doesn't contain information about parent classes, therefore voyager bloc plugin builder has specific API to address this issue:

If your bloc class (e.g. `ParentBloc`) is extending directly from `Bloc` use:

```dart
addBaseBloc<ParentBloc>((routeContext, config, repository) {
    return ParentBloc();
})
```

If your bloc doesn't extend directly from `Bloc` but e.g. from `ParentBloc` you will want to use:

```dart
addBloc<ChildBloc, ParentBloc>((routeContext, config, repository) {
    return ChildBloc();
})
```