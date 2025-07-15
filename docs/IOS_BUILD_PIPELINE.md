# iOS Build Pipeline Dokümantasyonu

## Genel Bakış

Bu doküman iOS CI/CD pipeline yapılandırmasını açıklar. Pipeline, iOS uygulamasının farklı ortamlardaki (dev, staging, prod) build, test ve dağıtım süreçlerini otomatikleştirir. iOS build'leri için GitHub Actions veya GitLab CI/CD kullanılabilir.

## iOS Özellikleri

iOS build pipeline'ı Android'den farklı olarak şu özel gereksinimlere sahiptir:

- **macOS Runner**: iOS build'leri yalnızca macOS üzerinde yapılabilir
- **Xcode**: Apple geliştirme araçları gerekli
- **Code Signing**: Apple Developer hesabı ve sertifikalar
- **Provisioning Profiles**: App Store Connect konfigürasyonu
- **TestFlight**: Apple'ın beta dağıtım platformu

## Pipeline Tetikleyicileri

Pipeline şu durumlarda tetiklenir:

- `develop` branch'ine push (Development build)
- `staging` branch'ine push (Staging build)
- `main` branch'ine push (Production build)
- Bu branch'lere yapılan pull request'ler

## Ortam Kurulumu

### GitHub Actions için

```yaml
runs-on: macos-latest
steps:
  - uses: actions/checkout@v4
  - uses: actions/setup-java@v4
    with:
      java-version: '17'
  - uses: subosito/flutter-action@v2
    with:
      flutter-version: '3.32.0'
  - name: Setup Ruby
    uses: ruby/setup-ruby@v1
    with:
      ruby-version: '3.2'
      bundler-cache: true
```

### GitLab CI/CD için

```yaml
tags:
  - macos
  - xcode
image: macos-monterey-xcode:14.2
before_script:
  - flutter --version
  - xcodebuild -version
  - cd ios && bundle install && cd ..
```

## iOS Fastlane Konfigürasyonu

### ios/fastlane/Fastfile

```ruby
default_platform(:ios)

platform :ios do
  desc "Development build ve TestFlight dağıtım"
  lane :dev do
    setup_ci
    match(type: "development", readonly: true)
    build_ios_app(
      scheme: "dev",
      configuration: "Dev-Release",
      export_method: "development"
    )
    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )
  end

  desc "Staging build ve TestFlight dağıtım"
  lane :staging do
    setup_ci
    match(type: "adhoc", readonly: true)
    build_ios_app(
      scheme: "staging",
      configuration: "Staging-Release",
      export_method: "ad-hoc"
    )
    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )
  end

  desc "Production build ve TestFlight dağıtım"
  lane :prod do
    setup_ci
    match(type: "appstore", readonly: true)
    build_ios_app(
      scheme: "prod",
      configuration: "Prod-Release",
      export_method: "app-store"
    )
    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )
  end

  desc "Sertifikaları güncelle"
  lane :update_certificates do
    match(type: "development", force_for_new_devices: true)
    match(type: "adhoc", force_for_new_devices: true)
    match(type: "appstore")
  end
end
```

## iOS Schemes Konfigürasyonu

### Development Scheme (Runner-dev)

```xml
<!-- ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner-dev.xcscheme -->
<key>CFBundleDisplayName</key>
<string>App Dev</string>
<key>CFBundleIdentifier</key>
<string>com.company.app.dev</string>
```

### Staging Scheme (Runner-staging)

```xml
<!-- ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner-staging.xcscheme -->
<key>CFBundleDisplayName</key>
<string>App Staging</string>
<key>CFBundleIdentifier</key>
<string>com.company.app.staging</string>
```

### Production Scheme (Runner-prod)

```xml
<!-- ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner-prod.xcscheme -->
<key>CFBundleDisplayName</key>
<string>App</string>
<key>CFBundleIdentifier</key>
<string>com.company.app</string>
```

## Sertifika Yönetimi

### Match Setup

```bash
# Match repository kurulumu
fastlane match init

# Sertifikaları oluştur
fastlane match development
fastlane match adhoc
fastlane match appstore
```

### Environment Variables

iOS pipeline için gerekli environment variables:

```bash
# App Store Connect
APPLE_ID=your_apple_id@email.com
APP_STORE_CONNECT_API_KEY_ID=your_key_id
APP_STORE_CONNECT_API_ISSUER_ID=your_issuer_id
APP_STORE_CONNECT_API_KEY_CONTENT=your_private_key_content

# Match (Certificate Management)
MATCH_REPOSITORY_URL=https://github.com/company/certificates
MATCH_PASSWORD=your_match_password
MATCH_GIT_BASIC_AUTHORIZATION=your_git_token

# Keychain (CI Environment)
KEYCHAIN_PASSWORD=your_keychain_password
```

## Pipeline Aşamaları

### 1. Kurulum ve Hazırlık

```yaml
setup:
  - Flutter kurulumu
  - Xcode kurulumu
  - Ruby ve Fastlane kurulumu
  - CocoaPods kurulumu
  - Keychain setup
```

### 2. Sertifika ve Provisioning

```yaml
certificates:
  - Match ile sertifika indirme
  - Provisioning profile setup
  - Keychain'e sertifika import
```

### 3. Build İşlemi

```yaml
build:
  - Flutter pub get
  - Pod install
  - Archive oluşturma
  - IPA export
```

### 4. Test ve Kalite

```yaml
quality:
  - Flutter analyze
  - Unit testler
  - iOS specific testler
  - Code signing validation
```

### 5. Dağıtım

```yaml
distribution:
  - TestFlight upload
  - Beta tester notification
  - Release notes güncelleme
```

## Xcode Proje Konfigürasyonu

### Build Configurations

- **Dev-Debug**: Development ortamı debug build
- **Dev-Release**: Development ortamı release build
- **Staging-Debug**: Staging ortamı debug build
- **Staging-Release**: Staging ortamı release build
- **Prod-Debug**: Production ortamı debug build
- **Prod-Release**: Production ortamı release build

### Info.plist Konfigürasyonu

```xml
<!-- ios/Runner/Info-dev.plist -->
<key>CFBundleDisplayName</key>
<string>$(APP_DISPLAY_NAME)</string>
<key>CFBundleIdentifier</key>
<string>$(BUNDLE_IDENTIFIER)</string>
<key>CFBundleVersion</key>
<string>$(BUILD_NUMBER)</string>
```

## CocoaPods ve Dependencies

### Podfile

```ruby
# ios/Podfile
platform :ios, '12.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end
```

## Troubleshooting

### Yaygın Sorunlar

1. **Code Signing Hatası**
   - Match sertifikalarını kontrol edin
   - Provisioning profile'ın güncel olduğunu doğrulayın
   - Bundle identifier'ların doğru olduğunu kontrol edin

2. **Build Hatası**
   - Xcode version compatibility kontrol edin
   - CocoaPods cache'i temizleyin: `cd ios && pod deintegrate && pod install`
   - Flutter clean: `flutter clean && flutter pub get`

3. **TestFlight Upload Hatası**
   - App Store Connect API key'lerini kontrol edin
   - App version'ın unique olduğunu doğrulayın
   - Build number'ın artan olduğunu kontrol edin

### Debug Komutları

```bash
# iOS build debug
flutter build ios --flavor dev --debug

# Xcode build logs
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner-dev -configuration Dev-Release archive -archivePath build/Runner.xcarchive

# Fastlane verbose
bundle exec fastlane ios dev --verbose
```

## Performans Optimizasyonu

### Cache Stratejisi

```yaml
# GitHub Actions
- name: Cache CocoaPods
  uses: actions/cache@v3
  with:
    path: ios/Pods
    key: ${{ runner.os }}-pods-${{ hashFiles('ios/Podfile.lock') }}

- name: Cache Flutter dependencies
  uses: actions/cache@v3
  with:
    path: |
      ~/.pub-cache
      build
    key: ${{ runner.os }}-flutter-${{ hashFiles('pubspec.lock') }}
```

### Build Time İyileştirmeleri

- **Incremental builds**: Sadece değişen dosyalar build edilir
- **CocoaPods cache**: Pod dependencies cache'lenir
- **Parallel builds**: Xcode parallel build ayarları
- **Derived data optimization**: Xcode derived data yönetimi

## Güvenlik Considerations

### Sensitive Data Yönetimi

- **Keychain**: Sertifikalar güvenli keychain'de saklanır
- **Environment Variables**: API key'ler encrypted secrets'da
- **Match**: Sertifikalar private git repository'de
- **Provisioning**: Profile'lar encrypted olarak saklanır

### Access Control

- **Apple Developer Account**: Team member permissions
- **App Store Connect**: Limited API key permissions
- **Git Repository**: Private certificate repository
- **CI/CD**: Restricted runner access

## İlgili Dokümanlar

- [Flutter Proje Kurulum Rehberi](FLUTTER_PROJECT_SETUP_GUIDE.md)
- [CI/CD Platform Karşılaştırması](CI_CD_COMPARISON.md)
- [Branch Pipeline Stratejisi](BRANCH_PIPELINE_STRATEGY.md)
- [GitHub Workflow Detayları](GITHUB_WORKFLOW.md)
- [GitLab Workflow Detayları](GITLAB_WORKFLOW.md)
- [Android Build Pipeline](ANDROID_BUILD_PIPELINE.md)
