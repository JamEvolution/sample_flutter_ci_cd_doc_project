# Flutter Flavors Yapılandırması ve Proje Dokümantasyonu

Bu doküman, `sample_ci_cd_project` projesinde kullanılan Flutter flavors yapılanmasını ve temel proje mimarisini açıklar.

---

## İçindekiler

- [Genel Bakış](#genel-bakış)
- [Flavors Nedir?](#flavors-nedir)
- [Projede Flavor Yapısı](#projede-flavor-yapısı)
- [Flavor Tanımları](#flavor-tanımları)
- [Firebase Entegrasyonu](#firebase-entegrasyonu)
- [Firebase Flavor Konfigürasyon Komutları](#firebase-flavor-konfigürasyon-komutları)
- [Versiyonlama (pubspec.yaml)](#versiyonlama-pubspecyaml)
- [Build ve Çalıştırma Komutları](#build-ve-çalıştırma-komutları)
- [App Distribution Script Kullanımı](#app-distribution-script-kullanımı)
- [Ekstra Notlar](#ekstra-notlar)

---

## Genel Bakış

Bu projede CI/CD süreçleri ve çoklu ortam yönetimi için **Flutter Flavors** mimarisi kullanılmaktadır. Her ortam (dev, staging, prod) için ayrı uygulama adı, paket adı ve Firebase konfigürasyonu tanımlanmıştır.

## Flavors Nedir?

Flavors, bir uygulamanın farklı ortamlar (ör. geliştirme, test, üretim) için farklı ayarlarla derlenmesini ve çalıştırılmasını sağlayan bir yapıdır. Her flavor, kendi uygulama adı, paket/bundle ID'si ve backend ayarlarına sahip olabilir.

## Projede Flavor Yapısı

- **Yapılandırma dosyası:** `flavorizr.yaml`
- **Enum ve flavor yönetimi:** `lib/flavors.dart`
- **Ana giriş noktası:** `lib/main.dart`
- **Firebase ortam dosyaları:**
  - `lib/firebase_options_dev.dart`
  - `lib/firebase_options_staging.dart`
  - `lib/firebase_options_prod.dart`
- **Android flavor klasörleri:** `android/app/src/dev`, `android/app/src/staging`, `android/app/src/prod`
- **iOS flavor klasörleri:** `ios/flavors/dev`, `ios/flavors/staging`, `ios/flavors/prod`

## Flavor Tanımları

`flavorizr.yaml` dosyasında tanımlı flavorlar:

```yaml
flavors:
  dev:
    app:
      name: "Dev-Sample-App"
    android:
      applicationId: "com.example.sample.dev"
    ios:
      bundleId: "com.example.sample.dev"
  prod:
    app:
      name: "Prod-Sample-App"
    android:
      applicationId: "com.example.sample.prod"
    ios:
      bundleId: "com.example.sample.prod"
  staging:
    app:
      name: "Staging-Sample-App"
    android:
      applicationId: "com.example.sample.staging"
    ios:
      bundleId: "com.example.sample.staging"
```

## Firebase Entegrasyonu

Her flavor için ayrı Firebase projesi ve konfigürasyonu kullanılır.

**Güvenlik Notu**: Firebase konfigürasyon dosyaları güvenlik nedeniyle repository'den kaldırılmıştır:

- `lib/firebase_options_dev.dart` (kaldırılmış - yeniden oluşturulmalı)
- `lib/firebase_options_staging.dart` (kaldırılmış - yeniden oluşturulmalı)
- `lib/firebase_options_prod.dart` (kaldırılmış - yeniden oluşturulmalı)

`lib/init_firebase.dart` dosyasında flavor'a göre doğru Firebase konfigürasyonu seçilir ve başlatılır.

## Firebase Flavor Konfigürasyon Komutları

Her flavor için FlutterFire CLI ile Firebase konfigürasyon dosyalarını oluşturmak için aşağıdaki komutları kullandım:

### DEV

```bash
flutterfire config \
  --project=dev-sample-app \
  --out=lib/firebase_options_dev.dart \
  --ios-bundle-id=com.example.sample.dev \
  --ios-out=ios/flavors/dev/GoogleService-Info.plist \
  --android-package-name=com.example.sample.dev \
  --android-out=android/app/src/dev/google-services.json
```

### PROD

```bash
flutterfire config \
  --project=prod-sample-app \
  --out=lib/firebase_options_prod.dart \
  --ios-bundle-id=com.example.sample.prod \
  --ios-out=ios/flavors/prod/GoogleService-Info.plist \
  --android-package-name=com.example.sample.prod \
  --android-out=android/app/src/prod/google-services.json
```

### STAGING

```bash
flutterfire config \
  --project=staging-sample-app \
  --out=lib/firebase_options_staging.dart \
  --ios-bundle-id=com.example.sample.staging \
  --ios-out=ios/flavors/staging/GoogleService-Info.plist \
  --android-package-name=com.example.sample.staging \
  --android-out=android/app/src/staging/google-services.json
```

---

## Versiyonlama (pubspec.yaml)

Flutter projelerinde versiyonlama, `pubspec.yaml` dosyasındaki `version` alanı ile yönetilir:

```yaml
version: 1.0.0+5
```

- Soldaki kısım (`1.0.0`) **versiyon numarası**dır (major.minor.patch)
- Sağdaki kısım (`+5`) ise **build number**'dır (her build için artan sayı)

### Versiyon Artırma Kuralları

- **Major (1.x.x):** Büyük, geriye dönük uyumsuz değişiklikler (ana özellik, mimari değişiklik)
- **Minor (x.1.x):** Yeni özellikler, geriye dönük uyumlu eklemeler
- **Patch (x.x.1):** Hata düzeltmeleri, küçük iyileştirmeler
- **Build Number (+X):** Her market/dağıtım build'inde artırılır

### Hangi Ortamda Hangi Alan Artırılır?

- **Dev ve Staging:**
  - Sık sık build alınır, genellikle sadece build number (`+X`) artırılır
  - Versiyon numarası (1.0.0) sabit kalabilir, build number ile ayırt edilir
  - Örnek: `1.0.0+15` → `1.0.0+16`

- **Prod (Canlı/Release):**
  - Her yeni market sürümünde **versiyon numarası** (major/minor/patch) artırılır
  - Build number da artırılır (App Store/Google Play zorunlu kılar)
  - Örnek: `1.0.0+16` → `1.1.0+17` veya `2.0.0+18`

### Dikkat Edilmesi Gerekenler

- **App Store ve Google Play**'e yüklerken build number her zaman bir önceki sürümden büyük olmalı
- Her ortamda (dev, staging, prod) farklı build number kullanmak karışıklığı önler
- Versiyon ve build number'ı artırmayı CI/CD pipeline'ında otomatikleştirmek mümkündür

### Önerilen Akış

- **Dev/Staging build:**
  - Sadece build number artırılır
  - `flutter build ... --build-number=YENI_NUMARA`
- **Prod build (market):**
  - Versiyon ve build number birlikte artırılır
  - `flutter build ... --build-name=YENI_VERSIYON --build-number=YENI_NUMARA`

---

## Build ve Çalıştırma Komutları

### Android

```bash
flutter build apk --flavor dev -t lib/main.dart --release
flutter build apk --flavor staging -t lib/main.dart --release
flutter build apk --flavor prod -t lib/main.dart --release
```

### iOS

```bash
flutter build ipa --flavor dev -t lib/main.dart --release
flutter build ipa --flavor staging -t lib/main.dart --release
flutter build ipa --flavor prod -t lib/main.dart --release
```

### Uygulamayı Çalıştırmak

```bash
flutter run --flavor dev -t lib/main.dart
flutter run --flavor staging -t lib/main.dart
flutter run --flavor prod -t lib/main.dart
```

---

## App Distribution Script Kullanımı

Projenizde CI/CD ve manuel test süreçlerini kolaylaştırmak için `scripts/appdistribution.sh` scripti kullanılır. Bu script ile Android/iOS için istediğiniz flavor'ı seçip, Firebase App Distribution'a kolayca build gönderebilirsiniz.

### Script'in Amacı

- Android/iOS için ayrı ayrı veya birlikte build alıp dağıtım yapmak
- Hangi flavor'a (dev, staging, prod) build göndereceğinizi seçmek
- Release notu girerek build'i test grubuna göndermek
- Tüm işlemleri renkli ve interaktif bir terminal arayüzüyle kolaylaştırmak

### Kullanım Adımları

1. Script'e çalıştırma yetkisi verin:

   ```sh
   chmod +x scripts/appdistribution.sh
   ```

2. Script'i başlatın:

   ```sh
   ./scripts/appdistribution.sh
   ```

3. Açılan menüde:
   - Platform seçin (Android/iOS)
   - Ortam (flavor) seçin (dev, staging, prod)
   - Release notu girin
   - Script otomatik olarak build alır ve Firebase App Distribution'a gönderir

### Script'te Neler Var?

- Seçim menüleri (platform, flavor)
- Release notu girişi
- Otomatik build ve dağıtım
- Hatalı seçimlerde uyarı ve tekrar deneme

### Örnek Kullanım Akışı

```sh
$ ./scripts/appdistribution.sh

1) Android (apk)
2) iOS (ipa)
3) Çıkış :( 
Ortam seçiniz [1-3]: 1

1) dev --> Geliştirici
2) staging --> Test
3) prod --> Canlı
4) Çıkış :( 
Ortam (flavor) seçiniz [1-4]: 2
Release Notu için açıklama giriniz Iwallet ekip üyesi: QA test buildi

APK yolu: build/app/outputs/flutter-apk/appdistribution.apk
Success android (staging)
```

### Notlar

- `scripts/config.sh` dosyasında her flavor için App ID ve tester group tanımlanmalıdır.
- Script, Firebase App Distribution'a gönderim için gerekli tüm adımları otomatikleştirir.
- Renkli terminal desteği ile kullanıcı dostu bir deneyim sunar.

---

## Ekstra Notlar

- Her flavor için ayrı Firebase projesi ve GoogleService-Info.plist / google-services.json dosyası gereklidir.
- iOS için Xcode'da her flavor'ın Bundle ID'si ve provisioning profile'ı doğru ayarlanmalıdır.
- Android için her flavor'ın applicationId'si Firebase ve build ayarlarıyla uyumlu olmalıdır.
- `flavorizr` ile otomatik flavor dosya ve yapılandırma yönetimi sağlanır.

---
