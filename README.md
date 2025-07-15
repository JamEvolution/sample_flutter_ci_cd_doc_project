# Sample Flutter CI/CD Documentation Project

[![Android Build & Distribution](https://github.com/JamEvolution/sample_flutter_ci_cd_doc_project/actions/workflows/android_build.yml/badge.svg)](https://github.com/JamEvolution/sample_flutter_ci_cd_doc_project/actions/workflows/android_build.yml)
[![Flutter Version](https://img.shields.io/badge/Flutter-3.32.0-blue.svg)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Integrated-orange.svg)](https://firebase.google.com/)

Profesyonel Flutter CI/CD pipeline'ı ve multi-environment deployment sistemine sahip dokümantasyon projesi. GitHub Actions, GitLab CI/CD, Fastlane entegrasyonu ve kapsamlı rehberler ile tam otomatik dağıtım süreçleri.

## Proje Özellikleri

- **Multi-Environment Support**: Dev, Staging ve Production ortamları
- **Automated CI/CD**: GitHub Actions ile otomatik build ve deployment
- **Flutter Flavors**: Ortam bazlı konfigürasyon yönetimi
- **Firebase Integration**: Her ortam için ayrı Firebase projeleri
- **Automated Versioning**: Fastlane ile otomatik versiyon yönetimi
- **Quality Assurance**: Automated testing ve code quality checks
- **Professional Documentation**: Kapsamlı dokümantasyon sistemi

## Hızlı Başlangıç

### Gereksinimler

- Flutter 3.32.0 veya üzeri
- Dart SDK 3.3.1 veya üzeri
- Android Studio / VS Code
- Firebase CLI
- Fastlane
- Ruby 3.2+

### Kurulum

1. **Projeyi klonlayın**

   ```bash
   git clone https://github.com/JamEvolution/sample_flutter_ci_cd_doc_project.git
   cd sample_flutter_ci_cd_doc_project
   ```

2. **Dependencies'leri yükleyin**

   ```bash
   flutter pub get
   cd android && bundle install && cd ..
   ```

3. **Firebase konfigürasyonunu yapın**

   ```bash
   # Firebase CLI ile login olun
   firebase login
   
   # Firebase konfigürasyon dosyalarını oluşturun (güvenlik nedeniyle kaldırılmış)
   flutterfire configure --project=your-dev-project-id --out=lib/firebase_options_dev.dart
   flutterfire configure --project=your-staging-project-id --out=lib/firebase_options_staging.dart
   flutterfire configure --project=your-prod-project-id --out=lib/firebase_options_prod.dart
   
   # Firebase projelerini yapılandırın (her environment için)
   firebase use --add your-dev-project-id
   firebase use --add your-staging-project-id
   firebase use --add your-prod-project-id
   ```

4. **Flavors'ı generate edin**

   ```bash
   flutter packages pub run build_runner build
   ```

5. **Local configuration dosyasını oluşturun**

   ```bash
   # Template'den config dosyasını kopyalayın
   cp scripts/config.sh.template scripts/config.sh
   
   # Firebase App ID'lerini ve token'ınızı config.sh'a ekleyin
   # Bu dosya .gitignore'da olduğu için commit edilmeyecek
   ```

## Ortam Yönetimi

### Mevcut Ortamlar

| Ortam | Açıklama | Branch | APK Build |
|-------|----------|--------|-----------|
| **Development** | Geliştirme ortamı | `develop` | `flutter build apk --flavor dev` |
| **Staging** | Test ortamı | `staging` | `flutter build apk --flavor staging` |
| **Production** | Canlı ortam | `main` | `flutter build apk --flavor prod` |

### Çalıştırma Komutları

```bash
# Development ortamında çalıştır
flutter run --flavor dev --target lib/main.dart

# Staging ortamında çalıştır
flutter run --flavor staging --target lib/main.dart

# Production ortamında çalıştır
flutter run --flavor prod --target lib/main.dart
```

## CI/CD Pipeline

### Branch Stratejisi

```text
develop (Dev Environment)
    ↓ Pull Request
staging (Staging Environment)
    ↓ Pull Request
main (Production Environment)
```

### Automated Processes

1. **Push to develop**: Dev APK build → Firebase App Distribution
2. **Push to staging**: Staging APK build → Firebase App Distribution
3. **Push to main**: Production APK build → Firebase App Distribution

### GitHub Actions Workflow

```yaml
# .github/workflows/android_build.yml
- Automated testing and quality checks
- Multi-environment builds
- Firebase App Distribution deployment
- Automatic version management
```

## Fastlane Integration

### Available Lanes

```bash
# Android Lanes
fastlane android dev        # Dev build ve dağıtım
fastlane android staging    # Staging build ve dağıtım
fastlane android prod       # Production build ve dağıtım
fastlane android test       # Test suite çalıştırma
fastlane android lint       # Code quality checks
fastlane android bump_version # Versiyon artırma
```

### Manuel Deployment

```bash
cd android
bundle exec fastlane android dev
```

## Konfigürasyon

### Fastlane Konfigürasyonu

**Güvenlik Notu**: Firebase App ID'leri ve credentials hassas bilgilerdir.

#### Local Development

```bash
# Fastlane template'ini kopyalayın
cp android/fastlane/Appfile.local.template android/fastlane/Appfile.local

# Kendi Firebase App ID'lerinizi Appfile.local'a ekleyin
# Bu dosya .gitignore'da olduğu için commit edilmeyecek
```

#### CI/CD (GitHub Actions)

GitHub Secrets'da aşağıdaki değişkenleri tanımlayın.

### Environment Variables

GitHub Secrets'da tanımlanması gereken değişkenler:

```bash
FIREBASE_TOKEN=your_firebase_token
DEV_FIREBASE_APP_ID=your_dev_app_id
STAGING_FIREBASE_APP_ID=your_staging_app_id
PROD_FIREBASE_APP_ID=your_prod_app_id
FIREBASE_TESTERS=test@example.com,test2@example.com
```

### Firebase Setup

Her ortam için ayrı Firebase projesi yapılandırması gereklidir:

**Not**: Firebase konfigürasyon dosyaları güvenlik nedeniyle repository'den kaldırılmıştır:

- `lib/firebase_options_dev.dart` (kaldırılmıştır)
- `lib/firebase_options_staging.dart` (kaldırılmıştır)  
- `lib/firebase_options_prod.dart` (kaldırılmıştır)

Bu dosyaları oluşturmak için:

```bash
# Firebase CLI ile projeyi yapılandırın
flutterfire configure

# Her ortam için ayrı konfigürasyon oluşturun
flutterfire configure --project=your-dev-project-id --out=lib/firebase_options_dev.dart
flutterfire configure --project=your-staging-project-id --out=lib/firebase_options_staging.dart
flutterfire configure --project=your-prod-project-id --out=lib/firebase_options_prod.dart
```

## Testing & Quality

### Test Komutları

```bash
# Unit testleri çalıştır
flutter test

# Integration testleri çalıştır
flutter drive --target=test_driver/app.dart

# Code coverage
flutter test --coverage
```

### Code Quality

```bash
# Lint kontrolü
flutter analyze

# Format kontrolü
dart format --set-exit-if-changed .
```

## Scripts ve Otomasyon

Projede manuel işlemler için hazırlanmış utility scriptleri:

### `scripts/appdistribution.sh`

Firebase App Distribution'a manuel APK yükleme script'i:

```bash
# Manuel deployment script'ini çalıştır
./scripts/appdistribution.sh

# Belirli bir ortam için
./scripts/appdistribution.sh dev
./scripts/appdistribution.sh staging
./scripts/appdistribution.sh prod
```

**Özellikler:**

- Multi-environment support (dev, staging, prod)
- Automatic APK build ve upload
- Firebase CLI entegrasyonu
- Error handling ve logging
- Tester notification sistemi

### `scripts/config.sh`

**Güvenlik Notu**: Bu dosya hassas bilgiler içerir ve `.gitignore`'da bulunur.

Ortam konfigürasyonları ve yardımcı fonksiyonlar:

```bash
# Template'den kendi config dosyanızı oluşturun
cp scripts/config.sh.template scripts/config.sh

# Firebase App ID'lerini ve token'ınızı config.sh'a ekleyin
# Ardından script'i source edin
source scripts/config.sh

# Kullanılabilir fonksiyonlar
setup_environment     # Ortam değişkenlerini ayarla
validate_config       # Konfigürasyon kontrolü
clean_builds          # Build cache temizleme
show_usage           # Yardım bilgilerini göster
```

**İçerik:**

- Environment variables tanımları (template olarak)
- Firebase project ID'leri (güvenli placeholder'larla)
- Build path'leri ve konfigürasyonları
- Utility fonksiyonları
- Validation ve error handling

### Manual Deployment Workflow

```bash
# 1. Environment'ı hazırla
source scripts/config.sh
setup_environment

# 2. APK build ve deploy
./scripts/appdistribution.sh dev

# 3. Sonuçları kontrol et
firebase appdistribution:distribute --app $DEV_FIREBASE_APP_ID
```

## Proje Yapısı

```text
lib/
├── main.dart                 # Ana entry point
├── app.dart                 # Ana uygulama widget'ı
├── flavors.dart             # Flavor konfigürasyonları
├── init_firebase.dart       # Firebase başlatma
├── firebase_options_*.dart  # Ortam bazlı Firebase ayarları
└── pages/                   # Uygulama sayfaları

android/
├── fastlane/               # Fastlane konfigürasyonu
│   ├── Fastfile           # Build lane'leri
│   ├── Appfile            # App konfigürasyonu
│   └── Pluginfile         # Plugin'ler
└── app/
    └── src/               # Flavor bazlı Android konfigürasyonu

docs/                      # Dokümantasyon
├── ANDROID_BUILD_PIPELINE.md
├── BRANCH_PIPELINE_STRATEGY.md
├── FLUTTER_PROJECT_SETUP_GUIDE.md
└── GITHUB_WORKFLOW.md

scripts/                   # Utility scriptleri
├── appdistribution.sh     # Manuel Firebase deployment
└── config.sh             # Konfigürasyon yardımcıları
```

## Dokümantasyon

Detaylı dokümantasyon için `docs/` klasörünü inceleyiniz:

- **[Android Build Pipeline](docs/ANDROID_BUILD_PIPELINE.md)**: Fastlane ve Android build süreçleri
- **[iOS Build Pipeline](docs/IOS_BUILD_PIPELINE.md)**: iOS build ve TestFlight dağıtım süreçleri
- **[Branch Strategy](docs/BRANCH_PIPELINE_STRATEGY.md)**: Git workflow ve deployment stratejisi
- **[Flutter Setup Guide](docs/FLUTTER_PROJECT_SETUP_GUIDE.md)**: Detaylı proje kurulum rehberi
- **[GitHub Workflow](docs/GITHUB_WORKFLOW.md)**: GitHub Actions CI/CD pipeline dokümantasyonu
- **[GitLab Workflow](docs/GITLAB_WORKFLOW.md)**: GitLab CI/CD pipeline dokümantasyonu
- **[CI/CD Platform Comparison](docs/CI_CD_COMPARISON.md)**: GitHub Actions vs GitLab CI/CD karşılaştırması

---

**Not**: Bu proje, profesyonel Flutter uygulamaları için modern CI/CD yaklaşımlarını göstermek amacıyla oluşturulmuştur.
