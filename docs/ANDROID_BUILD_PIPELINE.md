# Android Build Pipeline Dokümantasyonu

## Genel Bakış

Bu doküman, `.github/workflows/android_build.yml` dosyasındaki Android CI/CD pipeline yapılandırmasını açıklar. Pipeline, Android uygulamasının farklı ortamlardaki (dev, staging, prod) build, test ve dağıtım süreçlerini otomatikleştirir.

## Pipeline Tetikleyicileri

Pipeline şu durumlarda tetiklenir:

- `develop` branch'ine push
- `staging` branch'ine push
- `main` branch'ine push
- Bu branch'lere yapılan pull request'ler

## Ortam Kurulumu

Pipeline Ubuntu latest üzerinde çalışır ve şunları kullanır:

- JDK 17
- Flutter (son kararlı sürüm)
- Ruby (Fastlane için)

## Pipeline Aşamaları

### 1. Kurulum

```yaml
kurulum:
  - Flutter kurulumu
  - Java kurulumu
  - Ruby kurulumu
  - Bundler ve Fastlane kurulumu
```

### 2. Test ve Kalite

```yaml
test:
  - Flutter analizi
  - Unit testlerin çalıştırılması
  - Kod kalite kontrolleri (lint)
```

### 3. Versiyon Yönetimi

```yaml
versiyon:
  - Branch'e göre otomatik versiyon artırımı
  - pubspec.yaml'da versiyon güncelleme
  - Versiyon değişikliklerini commit'leme
```

### 4. Build ve Dağıtım

```yaml
build_deploy:
  - İlgili ortam için APK build'i
  - Firebase App Distribution'a dağıtım
  - Sürüm etiketleme (prod için)
```

## Ortam Değişkenleri

GitHub'da gerekli gizli değişkenler:

- `FIREBASE_APP_ID_DEV`: Dev ortamı için Firebase App ID
- `FIREBASE_APP_ID_STAGING`: Staging ortamı için Firebase App ID
- `FIREBASE_APP_ID_PROD`: Prod ortamı için Firebase App ID
- `FIREBASE_TOKEN`: Firebase CLI token'ı
- `FASTLANE_FIREBASE_CLI_TOKEN`: Fastlane Firebase token'ı

## Branch Stratejisi

- `develop` -> Dev APK build'i
- `staging` -> Staging APK build'i
- `main` -> Production APK build'i

## Fastlane Entegrasyonu

Pipeline Fastlane'i şunlar için kullanır:

- Versiyon yönetimi (`bump_version` lane'i)
- APK build'leri (`dev`, `staging`, `prod` lane'leri)
- Firebase dağıtımı
- Kod imzalama

## Başarı Kriterleri

Pipeline başarısı için gerekenler:

- Tüm testlerin geçmesi
- Kod kalite kontrollerinin geçmesi
- Başarılı APK build'i
- Başarılı Firebase dağıtımı

## Hata Yönetimi

- Başarısız testler pipeline'ı durdurur
- Build hataları raporlanır
- Dağıtım hataları bildirim tetikler

## Manuel Müdahale Gereken Durumlar

Şunlar için gereklidir:

- PR onayları
- Prod dağıtım onayları
- Merge conflict çözümleri

## Bakım

- Flutter sürüm güncellemeleri
- Firebase kotalarının takibi
- Test kullanıcı listelerinin güncellenmesi
- İmzalama sertifikalarının yönetimi

## İlgili Dokümanlar

- [Flutter Proje Kurulum Rehberi](FLUTTER_PROJECT_SETUP_GUIDE.md)
- [CI/CD Platform Karşılaştırması](CI_CD_COMPARISON.md)
- [Branch Pipeline Stratejisi](BRANCH_PIPELINE_STRATEGY.md)
- [GitHub Workflow Detayları](GITHUB_WORKFLOW.md)
- [GitLab Workflow Detayları](GITLAB_WORKFLOW.md)
- [iOS Build Pipeline](IOS_BUILD_PIPELINE.md)
