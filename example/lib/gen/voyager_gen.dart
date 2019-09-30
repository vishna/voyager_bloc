/// Generated file, DO NOT EDIT
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:voyager/voyager.dart';
import 'package:voyager_bloc/voyager_bloc.dart';

const String pathCounter = "/counter";
const String typeCounter = "counter";

class VoyagerData extends Voyager {
  VoyagerData({String path, Voyager parent, Map<String, dynamic> config})
      : super(path: path, parent: parent, config: config);

  BlocRepository get bloc => this["bloc"];
  String get title => this["title"];
}

class VoyagerProvider {
  static VoyagerData of(BuildContext context) => Provider.of<Voyager>(context);
}

VoyagerData voyagerDataFactory(
        AbstractRouteContext abstractContext, Map<String, dynamic> config) =>
    VoyagerData(
        path: abstractContext.url(),
        parent: abstractContext.getExtras().parent,
        config: config);
