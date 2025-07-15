import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'flavors.dart';
import 'init_firebase.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  F.appFlavor = Flavor.values.firstWhere(
    (element) => element.name == appFlavor,
  );

  await initFirebaseApp();
  runApp(const App());
}
