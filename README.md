# voyager_bloc

[![pub package](https://img.shields.io/pub/v/voyager_bloc.svg)](https://pub.dartlang.org/packages/voyager_bloc) [![Codemagic build astatus](https://api.codemagic.io/apps/5d9486dd9af71d0008d63359/5d9486dd9af71d0008d63358/status_badge.svg)](https://codemagic.io/apps/5d9486dd9af71d0008d63359/5d9486dd9af71d0008d63358/latest_build) [![codecov](https://codecov.io/gh/vishna/voyager_bloc/branch/master/graph/badge.svg)](https://codecov.io/gh/vishna/voyager_bloc)

Adds ability to specify used BLoCs on the widget level.

## Usage

Specify wanted blocs per screen in YAML file, like so:

```yaml
'/my/fancy/path':
  widget: FancyWidget
  bloc:
    - BlocA : 12 # provide config for bloc after :
    - BlocB :
        - field1: "hello"
        - field2: "world"
    - BlocC@foo : "enemy" # use @ to provide named blocs
    - BlocC@bar : "friend"
```

Use `BlocPluginBuilder` to provide mappings for your blocs:

```dart
BlocPluginBuilder()
  .addBaseBloc<BlocA>((routeContext, config, repository) => /* return BlocA here */)
  .build()
```

where repository gives you access to other blocs from your the scope of your page.

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

## Schema Validator

If you're using schema validation with `voyager:codegen` you can add the following to cover basics

```yaml
bloc:
  output: BlocRepository
  import: 'package:voyager_bloc/voyager_bloc.dart'
  input:
    type: array
```

## Accessing Blocs

Once you are working in the buildContext of Widget you can obtain `BlocRepository`

```dart
final repo = Provider.of<Voyager>(context)["bloc"];
```

or if you use generated strong types:

```dart
final repo = VoyagerProvider.of(context).bloc;
```

From there you can find blocs by type, e.g.:

```dart
final blocA = repo.find<BlocA>();
```

...and if your bloc was given a specific name, then supply name parameter:

```dart
final fooBlocC = repo.find<BlocC>(name: "foo");
```