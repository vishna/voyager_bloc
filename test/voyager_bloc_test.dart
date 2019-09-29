import 'package:bloc/bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voyager/voyager.dart';

import 'package:voyager_bloc/voyager_bloc.dart';

class ParentBloc extends Bloc {
  @override
  get initialState => null;

  @override
  Stream mapEventToState(event) {
    return null;
  }
}

class StrangerBloc extends Bloc {
  @override
  get initialState => null;

  @override
  Stream mapEventToState(event) {
    return null;
  }
}

class ChildBloc extends ParentBloc {
  @override
  get initialState => null;

  @override
  Stream mapEventToState(event) {
    return null;
  }
}

class CounterBloc extends Bloc {
  final int _initialValue;

  CounterBloc(this._initialValue);

  @override
  get initialState => _initialValue;

  @override
  Stream mapEventToState(event) {
    return null;
  }
}

void main() {
  test('bloc builder basic API', () {
    final builder = BlocPluginBuilder()
        .addBaseBloc<ParentBloc>((context, config, repository) => ParentBloc())
        .addBaseBloc<CounterBloc>((context, config, repository) =>
            CounterBloc(int.parse(config.toString())))
        .addBloc<ChildBloc, ParentBloc>(
            (context, config, repository) => ChildBloc())
        .addBaseBloc<StrangerBloc>(
            (context, config, repository) => StrangerBloc());

    final blocPlugin = builder.build();

    final output = Voyager(config: {});
    blocPlugin.outputFor(
        null,
        [
          "ParentBloc@mom",
          "ParentBloc@dad",
          "ChildBloc",
          "StrangerBloc",
          {"CounterBloc": 5}
        ],
        output);
    output.lock();
    final blocRepository = output["bloc"];

    expect(blocRepository, isInstanceOf<BlocRepository>());
    final parentBloc = blocRepository.find<ParentBloc>();
    expect(parentBloc, isInstanceOf<ParentBloc>());
    expect(parentBloc, isInstanceOf<ChildBloc>());
    expect(blocRepository.find<ChildBloc>(), isInstanceOf<ChildBloc>());
    expect(blocRepository.find<StrangerBloc>(), isInstanceOf<StrangerBloc>());
    expect(blocRepository.find<ParentBloc>(name: "mom"),
        isInstanceOf<ParentBloc>());
    expect(blocRepository.find<ParentBloc>(name: "dad"),
        isInstanceOf<ParentBloc>());
    expect(blocRepository.find<ChildBloc>(name: "dad"), isNull);

    final counterBloc = blocRepository.find<CounterBloc>();
    expect(counterBloc, isInstanceOf<CounterBloc>());
    expect((counterBloc as CounterBloc).currentState, 5);

    output.dispose();
  });
}
