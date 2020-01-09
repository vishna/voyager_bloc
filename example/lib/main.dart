import 'dart:async';

import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:voyager/voyager.dart';
import 'package:voyager_bloc/voyager_bloc.dart';

import './gen/voyager_gen.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print(error);
  }
}

final paths = loadPathsFromString('''
'/counter' :
  type: counter
  title: Counter
  widget: CounterPage
  blocs:
    - CounterBloc: 42
    - ThemeBloc: dark
''');

final plugins = [
  WidgetPluginBuilder().add<CounterPage>((context) => CounterPage()).build(),
  BlocsPluginBuilder()
      .addBaseBloc<CounterBloc>(
          (context, config, repo) => CounterBloc.fromConfig(config))
      .addBaseBloc<ThemeBloc>(
          (context, config, repo) => ThemeBloc.fromConfig(config))
      .build()
];

void main() async {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(Provider.value(
    value: await loadRouter(paths, plugins),
    child: App(),
  ));
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: VoyagerWidget(path: pathCounter),
    );
  }
}

class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final voyager = context.voyager;
    // ignore: close_sinks
    final counterBloc = voyager.blocs.find<CounterBloc>();
    // ignore: close_sinks
    final themeBloc = voyager.blocs.find<ThemeBloc>();

    return BlocBuilder<ThemeBloc, ThemeData>(
      bloc: themeBloc,
      builder: (context, data) => Theme(
        data: data,
        child: Scaffold(
          appBar: AppBar(title: Text(voyager.title)),
          body: BlocBuilder<CounterBloc, int>(
            bloc: counterBloc,
            builder: (context, count) {
              return Center(
                child: Text(
                  '$count',
                  style: TextStyle(fontSize: 24.0),
                ),
              );
            },
          ),
          floatingActionButton: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5.0),
                child: FloatingActionButton(
                  child: Icon(Icons.add),
                  onPressed: () {
                    counterBloc.add(CounterEvent.increment);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5.0),
                child: FloatingActionButton(
                  child: Icon(Icons.remove),
                  onPressed: () {
                    counterBloc.add(CounterEvent.decrement);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5.0),
                child: FloatingActionButton(
                  child: Icon(Icons.update),
                  onPressed: () {
                    themeBloc.add(ThemeEvent.toggle);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc(this._initalState) : super();

  factory CounterBloc.fromConfig(dynamic config) {
    return CounterBloc(int.parse(config.toString()));
  }

  final int _initalState;

  @override
  int get initialState => _initalState;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield state - 1;
        break;
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }
}

enum ThemeEvent { toggle }

class ThemeBloc extends Bloc<ThemeEvent, ThemeData> {
  ThemeBloc(this._intialState) : super();

  factory ThemeBloc.fromConfig(dynamic config) {
    ThemeData data;
    switch (config.toString()) {
      case "light":
        data = ThemeData.light();
        break;
      default:
        data = ThemeData.dark();
    }

    return ThemeBloc(data);
  }

  final ThemeData _intialState;

  @override
  ThemeData get initialState => _intialState;

  @override
  Stream<ThemeData> mapEventToState(ThemeEvent event) async* {
    switch (event) {
      case ThemeEvent.toggle:
        yield state == ThemeData.dark() ? ThemeData.light() : ThemeData.dark();
        break;
    }
  }
}
