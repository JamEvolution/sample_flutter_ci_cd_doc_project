# CI/CD Platform Comparison: GitHub Actions vs GitLab CI/CD

Bu doküman GitHub Actions ve GitLab CI/CD platformlarının Flutter projesi için kullanımını karşılaştırır ve her iki platform için de örnek implementasyonlar sunar.

## Platform Özeti

### GitHub Actions

- **Dosya**: `.github/workflows/android_build.yml`
- **Platform**: GitHub tabanlı CI/CD
- **Avantajlar**: GitHub ekosistemi entegrasyonu, marketplace actions, kolay setup
- **Kullanım Durumu**: GitHub'da host edilen projeler için ideal

### GitLab CI/CD

- **Dosya**: `.gitlab-ci.yml`
- **Platform**: GitLab tabanlı CI/CD
- **Avantajlar**: Self-hosted runner desteği, güçlü cache sistemi, detaylı pipeline görselleştirme
- **Kullanım Durumu**: GitLab'da host edilen projeler veya on-premise çözümler için ideal

## Konfigürasyon Karşılaştırması

### GitHub Actions Yapısı

```yaml
name: Android Build Pipeline
on:
  push:
    branches: [develop, staging, main]
  pull_request:
    branches: [develop, staging, main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
      - uses: subosito/flutter-action@v2
```

### GitLab CI/CD Yapısı

```yaml
variables:
  FLUTTER_VERSION: "3.32.0"

stages:
  - prepare
  - build

.prepare_environment: &prepare_environment
  tags:
    - flutter
  image: cirrusci/flutter:3.32.0
```

## Branch Strategy Karşılaştırması

### GitHub Actions Branch Handling

- **Trigger**: `on.push.branches` ve `on.pull_request.branches`
- **Conditional Jobs**: `if: github.ref == 'refs/heads/main'`
- **Environment Protection**: Repository Settings > Environments

### GitLab CI/CD Branch Handling

- **Trigger**: `only: [develop, staging, main]`
- **Manual Jobs**: `when: manual`
- **Environment Protection**: GitLab CI/CD Settings > Environments

## Environment Variables Yönetimi

### GitHub Actions Secrets

```yaml
env:
  FIREBASE_CLI_TOKEN: ${{ secrets.FIREBASE_CLI_TOKEN }}
  FIREBASE_APP_ID_DEV: ${{ secrets.FIREBASE_APP_ID_DEV }}
  ANDROID_KEYSTORE_BASE64: ${{ secrets.ANDROID_KEYSTORE_BASE64 }}
```

**Ayarlama Yolu**: Repository Settings > Secrets and variables > Actions

### GitLab CI/CD Variables

```yaml
# GitLab CI/CD otomatik olarak CI_* değişkenlerini sağlar
variables:
  FASTLANE_SKIP_UPDATE_CHECK: "true"
```

**Ayarlama Yolu**: Project Settings > CI/CD > Variables

## Cache Stratejileri

### GitHub Actions Cache

```yaml
- name: Cache Flutter dependencies
  uses: actions/cache@v3
  with:
    path: |
      ~/.pub-cache
      build
    key: ${{ runner.os }}-flutter-${{ hashFiles('**/pubspec.lock') }}
```

### GitLab CI/CD Cache

```yaml
cache:
  key: ${CI_COMMIT_REF_SLUG}
  paths:
    - .pub-cache/
    - build/
    - .dart_tool/
    - android/.gradle/
```

## Fastlane Entegrasyonu

Her iki platform da aynı Fastlane konfigürasyonunu kullanır:

### Ortak Fastlane Lanes

```ruby
# android/fastlane/Fastfile
lane :dev do
  validate_environment
  bump_version_if_needed
  build_android_dev
  distribute_to_firebase
end

lane :staging do
  validate_environment
  bump_version_if_needed
  build_android_staging
  distribute_to_firebase
end

lane :prod do
  validate_environment
  bump_version_if_needed
  build_android_prod
  distribute_to_firebase
end
```

## Firebase App Distribution

### GitHub Actions Distribution

```yaml
- name: Distribute to Firebase
  run: |
    cd android
    bundle exec fastlane ${{ matrix.environment }}
```

### GitLab CI/CD Distribution

```yaml
script:
  - cd android
  - bundle exec fastlane $ENVIRONMENT
```

## Platform Seçimi Rehberi

### GitHub Actions Seçin Eğer

- Projeniz GitHub'da host ediliyorsa
- GitHub marketplace actions'larından yararlanmak istiyorsanız
- GitHub ekosistemi (Issues, Projects, etc.) ile tight entegrasyon istiyorsanız
- Basit setup ve hızlı başlangıç istiyorsanız

### GitLab CI/CD Seçin Eğer

- Projeniz GitLab'da host ediliyorsa
- Self-hosted runner'lar kullanmak istiyorsanız
- Daha güçlü cache ve artifact yönetimi istiyorsanız
- On-premise çözüm gerekiyorsa
- Detaylı pipeline visualization istiyorsanız

## Migration Senaryoları

### GitHub Actions'dan GitLab CI/CD'ye Geçiş

1. `.github/workflows/` içeriğini `.gitlab-ci.yml`'ye çevirin
2. Secrets'ları GitLab CI/CD Variables'a taşıyın
3. GitHub Actions specific syntax'ı GitLab CI/CD syntax'ına çevirin
4. Runner requirements'ları kontrol edin

### GitLab CI/CD'den GitHub Actions'a Geçiş

1. `.gitlab-ci.yml` içeriğini `.github/workflows/`'a çevirin
2. Variables'ları GitHub Secrets'a taşıyın
3. GitLab CI/CD specific syntax'ı GitHub Actions syntax'ına çevirin
4. Marketplace actions'larıyla optimize edin

## Hybrid Approach (Her İki Platform)

Bu projedeki gibi her iki platformu da desteklemek istiyorsanız:

1. **Fastlane'i ortak katman olarak kullanın**
2. **Environment variables'ı standardize edin**
3. **Aynı branch strategy'yi uygulayın**
4. **Dokumentasyonu güncel tutun**

## Best Practices

### Her İki Platform İçin

1. **Environment Variables**: Sensitive bilgileri secrets/variables'da saklayın
2. **Cache Strategy**: Dependencies'leri cache'leyerek build süresini azaltın
3. **Fastlane**: Platform-agnostic automation için Fastlane kullanın
4. **Branch Protection**: Production branch'lerini koruyun
5. **Manual Approval**: Production deployment'lar için manual approval kullanın

### GitHub Actions Specific

- Actions marketplace'den mature action'ları kullanın
- Matrix strategy ile multi-environment build yapın
- Reusable workflows oluşturun

### GitLab CI/CD Specific

- YAML anchors (&) ile code reuse yapın
- Include directive ile modular pipeline'lar oluşturun
- Auto DevOps features'larını değerlendirin

## Sonuç

Her iki platform da Flutter projeleri için güçlü CI/CD çözümleri sunar. Platform seçimi genellikle mevcut infrastructure ve team preferences'a bağlıdır. Bu proje her iki platformu da destekleyerek, teams'lere en uygun olanı seçme esnekliği sağlar.

## İlgili Dokümantasyon

- [GitHub Workflow Detayları](GITHUB_WORKFLOW.md)
- [GitLab Workflow Detayları](GITLAB_WORKFLOW.md)
- [Android Build Pipeline](ANDROID_BUILD_PIPELINE.md)
- [iOS Build Pipeline](IOS_BUILD_PIPELINE.md)
- [Branch Pipeline Strategy](BRANCH_PIPELINE_STRATEGY.md)
- [Flutter Project Setup Guide](FLUTTER_PROJECT_SETUP_GUIDE.md)
