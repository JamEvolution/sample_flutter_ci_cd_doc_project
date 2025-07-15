import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:sample_ci_cd_project/flavors.dart'; // Flavor enum'ını import edin
import 'package:sample_ci_cd_project/firebase_options_staging.dart' as staging;
import 'package:sample_ci_cd_project/firebase_options_prod.dart' as production;
import 'package:sample_ci_cd_project/firebase_options_dev.dart' as development;

bool _isFirebaseInitialized = false;

Future<FirebaseApp> initFirebaseApp() async {
  // Zaten başlatılmışsa, erken dönüş yapalım
  if (_isFirebaseInitialized) {
    return Firebase.app();
  }

  // Firebase uygulamaları listesini kontrol edelim
  if (Firebase.apps.isNotEmpty) {
    _isFirebaseInitialized = true;
    return Firebase.app();
  }

  // appFlavor yerine F.appFlavor kullanımı - bu değişkenin doğru tanımlandığından emin olun
  String flavorName =
      F.appFlavor.toString().split('.').last; // Flavor.dev -> "dev"

  final FirebaseOptions options;

  // Switch yerine if-else kullanımı (daha defensive programming)
  if (flavorName == 'dev') {
    options = development.DefaultFirebaseOptions.currentPlatform;
  } else if (flavorName == 'staging') {
    options = staging.DefaultFirebaseOptions.currentPlatform;
  } else if (flavorName == 'prod') {
    options = production.DefaultFirebaseOptions.currentPlatform;
  } else {
    throw UnsupportedError('Invalid app flavor: $flavorName');
  }

  // İsimlendirilmiş bir Firebase instance kullanımı
  try {
    final app = await Firebase.initializeApp(
      name: 'app-$flavorName', // Flavor adını içeren özel bir isim
      options: options,
    );
    _isFirebaseInitialized = true;
    debugPrint('Firebase initialized with name: ${app.name}.');
    return app;
  } catch (e) {
    // Eğer zaten varsa, mevcut instance'ı alın
    if (e.toString().contains('duplicate-app')) {
      _isFirebaseInitialized = true;
      return Firebase.app('app-$flavorName');
    }
    rethrow; // Başka bir hata varsa, yeniden fırlat
  }
}
