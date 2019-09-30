import 'package:bloc/bloc.dart';
import 'package:voyager/voyager.dart';

const _KEY_BLOC = "bloc";
const _KEY_DEFAULT = "default";

class BlocPluginBuilder {
  var _blocBuilders = <_RepositoryBlocBuilder>[];
  BlocPluginBuilder
      addBloc<BlocType extends BlocParentType, BlocParentType extends Bloc>(
          BlocBuilder<BlocType> builder) {
    final blocType = _typeOf<BlocType>();
    final blocParentType = _typeOf<BlocParentType>();

    if (blocType.toString() == _typeOf<Bloc>().toString()) {
      throw ArgumentError("BlocType must be a subclass of BlocParentType");
    }

    if (blocParentType.toString() == _typeOf<Bloc>().toString()) {
      throw ArgumentError("BlocParentType must be a subclass of Bloc");
    }

    _blocBuilders
        .add(_RepositoryBlocBuilder(builder, blocType, blocParentType));

    return this;
  }

  BlocPluginBuilder addBaseBloc<BlocType extends Bloc>(
          BlocBuilder<BlocType> builder) =>
      addBloc<BlocType, BlocType>(builder);

  BlocPlugin build() => BlocPlugin(_blocBuilders);
}

/// Specify config
///
class BlocPlugin extends RouterPlugin {
  final Map<String, _RepositoryBlocBuilder> _builders =
      Map<String, _RepositoryBlocBuilder>();

  BlocPlugin(List<_RepositoryBlocBuilder> builders) : super(_KEY_BLOC) {
    builders.forEach((builder) {
      _builders[builder.type.toString()] = builder;
    });
  }

  @override
  void outputFor(RouterContext context, config, Voyager output) {
    if (!(config is List<dynamic>)) return;

    final blocRepository = BlocRepository();
    final blocsToDispose = List<_Lazy<Bloc>>();

    (config as List<dynamic>).forEach((blocNode) {
      dynamic blocConfig;
      String key;
      String name = _KEY_DEFAULT;

      if (VoyagerUtils.isTuple(blocNode)) {
        MapEntry<String, dynamic> tuple = VoyagerUtils.tuple(blocNode);
        key = tuple.key;
        blocConfig = tuple.value;
      } else {
        key = blocNode.toString();
      }

      // MyBloc@myName
      if (key.contains("@")) {
        final keySplit = key.split("@");
        if (keySplit.length == 2) {
          key = keySplit[0];
          name = keySplit[1];
        } else {
          throw ArgumentError("Too many @ sings in the key of the Bloc");
        }
      }

      final builder = _builders[key];
      if (builder == null) {
        throw UnimplementedError("No bloc builder for $key");
      }

      _Lazy<Bloc> bloc = _Lazy<Bloc>(
          () => builder.builder(context, blocConfig, blocRepository));
      blocRepository.add(bloc, name, builder.type, builder.parentType);
      blocsToDispose.add(bloc);
    });

    output[_KEY_BLOC] = blocRepository;
    output.onDispose(() {
      blocsToDispose.forEach((bloc) {
        if (bloc.isInitalized) {
          bloc.value.dispose();
        }
      });
    });
  }
}

typedef BlocBuilder<T extends Bloc> = T Function(
    RouterContext context, dynamic config, BlocRepository blocRepository);

class _RepositoryBlocBuilder {
  final Type type;
  final Type parentType;
  final BlocBuilder builder;

  _RepositoryBlocBuilder(this.builder, this.type, this.parentType);
}

class BlocRepository {
  /// [parentType][name] map of blocs
  final _blocByType = Map<String, List<_Lazy<Bloc>>>();
  final _blocByParentType = Map<String, List<_Lazy<Bloc>>>();
  final _blocByName = Map<String, List<_Lazy<Bloc>>>();

  void add(_Lazy<Bloc> bloc, String name, Type blocType, Type parentType) {
    String typeStr = blocType.toString();
    String parentTypeStr = parentType.toString();

    if (name != _KEY_DEFAULT) {
      _blocByName[name] = (_blocByName[name] ?? [])..add(bloc);
      return;
    }
    _blocByParentType[parentTypeStr] = (_blocByParentType[parentTypeStr] ?? [])
      ..add(bloc);
    _blocByType[typeStr] = (_blocByType[typeStr] ?? [])..add(bloc);
  }

  T find<T extends Bloc>({String name}) {
    if (name != null && name != _KEY_DEFAULT) {
      T foundBloc;
      _blocByName[name]?.forEach((lazyBloc) {
        final bloc = lazyBloc.value;
        if (bloc is T) {
          foundBloc = bloc;
          return;
        }
      });
      return foundBloc;
    }

    String blocType = _typeOf<T>().toString();
    return _firstOrNull(_blocByType[blocType])?.value ??
        _firstOrNull(_blocByParentType[blocType])?.value;
  }
}

/// Necessary to obtain generic [Type]
/// https://github.com/dart-lang/sdk/issues/11923
Type _typeOf<T>() => T;

dynamic _firstOrNull(List list) {
  if (list == null || list.isEmpty) return null;
  return list[0];
}

typedef LazyBuilder<T> = T Function();

class _Lazy<T> {
  _Lazy(this.builder);
  T _value;
  final LazyBuilder<T> builder;

  bool get isInitalized => _value != null;

  T get value {
    if (_value == null) {
      _value = builder();
    }
    return _value;
  }
}
