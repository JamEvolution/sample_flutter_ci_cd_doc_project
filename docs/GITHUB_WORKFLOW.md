# GitHub Actions CI/CD Pipeline Dokümantasyonu

## Genel Bakış

Bu dokümantasyon, projemizdeki GitHub Actions CI/CD pipeline yapılandırmasını açıklamaktadır. Pipeline, Flutter projesinin Android build, test ve dağıtım süreçlerini otomatize eder.

## Tetikleyiciler (Triggers)

Pipeline aşağıdaki durumlarda tetiklenir:

- Push yapıldığında:
  - `develop` branch'i
  - `staging` branch'i
  - `main` branch'i
- Pull Request açıldığında:
  - Yukarıdaki branch'lere açılan PR'lar
  - PR güncellemelerinde (synchronize)
  - PR yeniden açıldığında (reopened)

## Çalışma Ortamı

- OS: Ubuntu Latest
- Temel Bileşenler:
  - Ruby 3.2
  - Java 17 (Zulu Distribution)
  - Flutter 3.32.0 (Stable Channel)
  - Firebase CLI
  - FVM (Flutter Version Management)

## Pipeline Aşamaları

### 1. Ortam Hazırlığı

```yaml
- Ruby kurulumu
- Java kurulumu
- Flutter kurulumu
- FVM kurulumu
- Firebase CLI kurulumu
- Dependencies kurulumu
- Gradle cache yapılandırması
```

### 2. Test ve Kalite Kontrol

> Not: Şu anda devre dışı, gerektiğinde aktifleştirilebilir

```yaml
- Flutter testleri
- Lint kontrolleri
```

### 3. Branch-Spesifik İşlemler

#### Develop Branch

- Versiyon yükseltme (bump_version)
- Dev APK build
- Firebase App Distribution'a yükleme (Dev ortamı)

#### Staging Branch

- Versiyon yükseltme (bump_version)
- Staging APK build
- Firebase App Distribution'a yükleme (Staging ortamı)

#### Main Branch (Production)

- Versiyon yükseltme (bump_version)
- Production APK build
- Firebase App Distribution'a yükleme (Prod ortamı)

## Gerekli Secret'lar

GitHub repository secrets'da tanımlanması gereken değişkenler:

- `FIREBASE_TOKEN`: Firebase CLI için authentication token
- `DEV_FIREBASE_APP_ID`: Dev ortamı Firebase App ID
- `STAGING_FIREBASE_APP_ID`: Staging ortamı Firebase App ID
- `PROD_FIREBASE_APP_ID`: Production ortamı Firebase App ID
- `FIREBASE_TESTERS`: Firebase App Distribution test kullanıcıları
- `GITHUB_TOKEN`: GitHub Actions için yetkilendirme token'ı

## Fastlane Entegrasyonu

Pipeline, Fastlane ile entegre çalışır ve şu lane'leri kullanır:

- `bump_version`: Otomatik versiyon artırımı
- `android dev`: Dev ortamı build ve dağıtım
- `android staging`: Staging ortamı build ve dağıtım
- `android prod`: Production ortamı build ve dağıtım
- `android test`: Test suite çalıştırma
- `android lint`: Kod kalite kontrolleri

## Hata Yönetimi

- Test ve Lint işlemleri `continue-on-error: true` ile yapılandırılmıştır
- Build veya deploy hatalarında pipeline durur
- GitHub Actions log'larında hata detayları görüntülenebilir

## Geliştirici Notları

1. Yeni bir feature için:
   - develop branch'inde geliştirme yap
   - PR aç ve CI kontrollerinin geçmesini bekle
   - Review sonrası merge et

2. Staging'e deploy için:
   - develop -> staging PR'ı aç
   - CI kontrollerinin geçmesini bekle
   - Review sonrası merge et

3. Production'a deploy için:
   - staging -> main PR'ı aç
   - CI kontrollerinin geçmesini bekle
   - Review sonrası merge et

## İlgili Dokümanlar

- [Android Build Pipeline](ANDROID_BUILD_PIPELINE.md)
- [iOS Build Pipeline](IOS_BUILD_PIPELINE.md)
- [GitLab Workflow](GITLAB_WORKFLOW.md)
- [CI/CD Platform Karşılaştırması](CI_CD_COMPARISON.md)
- [Branch Pipeline Strategy](BRANCH_PIPELINE_STRATEGY.md)
- [Flutter Proje Kurulum Rehberi](FLUTTER_PROJECT_SETUP_GUIDE.md)
