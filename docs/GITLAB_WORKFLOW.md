# GitLab CI/CD Workflow Dokümantasyonu

## Genel Bakış

Bu doküman `.gitlab-ci.yml` dosyasındaki GitLab CI/CD pipeline yapılandırmasını açıklar. Pipeline, Flutter uygulamasının farklı ortamlardaki (dev, staging, prod) build, test ve dağıtım süreçlerini GitLab CI/CD üzerinde otomatikleştirir.

## GitLab CI/CD Özellikleri

GitLab CI/CD platformu şu avantajları sunar:

- **Self-hosted Runner Support**: Kendi runner'larınızı kullanabilirsiniz
- **Powerful Cache System**: Gelişmiş cache yönetimi
- **Docker Integration**: Native Docker container support
- **Pipeline Visualization**: Detaylı pipeline görselleştirmesi
- **Auto DevOps**: Otomatik DevOps özellikleri
- **Built-in Registry**: Container ve package registry

## Pipeline Konfigürasyonu

### .gitlab-ci.yml Yapısı

```yaml
# GitLab CI/CD Pipeline for Flutter Android
variables:
  LANG: "en_US.UTF-8"
  LC_ALL: "en_US.UTF-8"
  FASTLANE_SKIP_UPDATE_CHECK: "true"
  FASTLANE_HIDE_TIMESTAMP: "true"
  FLUTTER_VERSION: "3.32.0"
  ANDROID_COMPILE_SDK: "34"
  ANDROID_TARGET_SDK: "34"

stages:
  - prepare
  - build

# Docker image kullanımı
.prepare_environment: &prepare_environment
  tags:
    - flutter
  image: cirrusci/flutter:3.32.0
  before_script:
    - echo "🔧 Setting up environment..."
    - flutter --version
    - flutter doctor -v
    - flutter pub get
    - cd android && bundle install --retry=3 && cd ..
```

## Pipeline Stages

### Stage 1: Prepare

Environment validation ve versiyon yönetimi aşaması:

```yaml
validate_environment:
  stage: prepare
  <<: *prepare_environment
  script:
    - echo "🔍 Validating CI environment..."
    - cd android
    - bundle exec fastlane validate_environment
    - echo "✅ Environment validation complete"
  only:
    - develop
    - staging
    - main

bump_version:
  stage: prepare
  <<: *prepare_environment
  script:
    - echo "📈 Updating version..."
    - cd android
    - bundle exec fastlane bump_version version:"${CI_COMMIT_TAG:-$(date +%Y.%m.%d.%H%M)}"
  only:
    - develop
    - staging
    - main
```

### Stage 2: Build

Her ortam için build ve deployment aşaması:

```yaml
build_dev:
  stage: build
  <<: *prepare_environment
  script:
    - echo "🚀 Building development version..."
    - cd android
    - bundle exec fastlane dev
  only:
    - develop
  when: on_success

build_staging:
  stage: build
  <<: *prepare_environment
  script:
    - echo "🎯 Building staging version..."
    - cd android
    - bundle exec fastlane staging
  only:
    - staging
  when: on_success

build_prod:
  stage: build
  <<: *prepare_environment
  script:
    - echo "🏆 Building production version..."
    - cd android
    - bundle exec fastlane prod
  only:
    - main
  when: manual # Production requires manual approval
```

## GitLab Runner Konfigürasyonu

### Docker Executor

```yaml
# .gitlab-runner/config.toml
[[runners]]
  name = "flutter-docker-runner"
  url = "https://gitlab.com/"
  token = "your-runner-token"
  executor = "docker"
  [runners.docker]
    image = "cirrusci/flutter:3.32.0"
    privileged = false
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    volumes = ["/cache"]
    shm_size = 0
```

### Self-hosted Runner

```bash
# GitLab Runner kurulumu
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
sudo apt-get install gitlab-runner

# Runner'ı register etme
sudo gitlab-runner register \
  --url "https://gitlab.com/" \
  --registration-token "your-project-token" \
  --description "flutter-runner" \
  --tag-list "flutter,android" \
  --executor "shell"
```

## Environment Variables

GitLab CI/CD Settings > Variables'da tanımlanması gereken değişkenler:

### Firebase Variables

```bash
FIREBASE_CLI_TOKEN=your_firebase_token
FIREBASE_APP_ID_DEV=your_dev_app_id
FIREBASE_APP_ID_STAGING=your_staging_app_id
FIREBASE_APP_ID_PROD=your_prod_app_id
FIREBASE_TESTERS=test@example.com,test2@example.com
```

### Android Signing Variables

```bash
ANDROID_KEYSTORE_BASE64=base64_encoded_keystore
ANDROID_KEYSTORE_PASSWORD=keystore_password
ANDROID_KEY_ALIAS=key_alias
ANDROID_KEY_PASSWORD=key_password
```

### GitLab Built-in Variables

GitLab otomatik olarak sağladığı değişkenler:

```bash
CI=true
CI_COMMIT_SHA=commit_hash
CI_COMMIT_REF_NAME=branch_name
CI_COMMIT_TAG=tag_name
CI_PIPELINE_ID=pipeline_id
CI_JOB_ID=job_id
CI_PROJECT_ID=project_id
```

## Cache Konfigürasyonu

### Optimized Cache Strategy

```yaml
cache:
  key: ${CI_COMMIT_REF_SLUG}
  paths:
    - .pub-cache/
    - build/
    - .dart_tool/
    - android/.gradle/
    - android/app/build/
    - android/fastlane/report.xml
    - ~/.gradle/caches/
    - ~/.android/cache/

# Per-job cache
.cache_template: &cache_template
  cache:
    key: ${CI_COMMIT_REF_SLUG}-${CI_JOB_NAME}
    paths:
      - .pub-cache/
      - android/.gradle/
    policy: pull-push
```

## Artifacts Management

### Build Artifacts

```yaml
build_dev:
  stage: build
  artifacts:
    paths:
      - build/app/outputs/flutter-apk/app-dev-release.apk
    expire_in: 1 week
    reports:
      junit: android/fastlane/report.xml
```

### Test Reports

```yaml
test:
  stage: test
  script:
    - flutter test --reporter=json > test-results.json
  artifacts:
    reports:
      junit: test-results.json
    when: always
```

## Branch Strategy Integration

### GitLab Flow

```yaml
# Sadece belirli branch'lerde çalış
only:
  - develop    # Development builds
  - staging    # Staging builds
  - main       # Production builds

# Pull request'lerde test çalıştır
except:
  - merge_requests
```

### Merge Request Pipeline

```yaml
test_mr:
  stage: test
  script:
    - flutter analyze
    - flutter test
  only:
    - merge_requests
  except:
    - main
    - staging
```

## Parallel Jobs

### Matrix Builds

```yaml
.build_template: &build_template
  stage: build
  parallel:
    matrix:
      - ENVIRONMENT: [dev, staging]
        PLATFORM: [android]
  script:
    - cd android
    - bundle exec fastlane $ENVIRONMENT
```

### Multi-platform Support

```yaml
build_android:
  <<: *build_template
  tags:
    - android
    - linux

build_ios:
  <<: *build_template
  tags:
    - ios
    - macos
  script:
    - cd ios
    - bundle exec fastlane $ENVIRONMENT
```

## Security Best Practices

### Protected Variables

```bash
# GitLab Settings > CI/CD > Variables
# Mark as "Protected" for production secrets
PROD_FIREBASE_APP_ID=protected_variable
ANDROID_KEYSTORE_PASSWORD=masked_variable
```

### Secret Detection

```yaml
secret_detection:
  stage: test
  image: registry.gitlab.com/gitlab-org/security-products/analyzers/secrets:latest
  script:
    - /analyzer run
  artifacts:
    reports:
      secret_detection: gl-secret-detection-report.json
```

## Monitoring ve Notifications

### Pipeline Status

```yaml
notify_success:
  stage: .post
  script:
    - echo "Pipeline completed successfully"
  only:
    - main
  when: on_success

notify_failure:
  stage: .post
  script:
    - echo "Pipeline failed"
  when: on_failure
```

### Slack Integration

```yaml
slack_notification:
  stage: .post
  script:
    - >
      curl -X POST -H 'Content-type: application/json'
      --data '{"text":"Pipeline Status: $CI_PIPELINE_STATUS"}'
      $SLACK_WEBHOOK_URL
  when: always
```

## Performance Optimization

### Build Time Improvements

```yaml
# Docker layer caching
build:
  image: $CI_REGISTRY_IMAGE:latest
  before_script:
    - docker pull $CI_REGISTRY_IMAGE:latest || true
  script:
    - docker build --cache-from $CI_REGISTRY_IMAGE:latest .
```

### Parallel Testing

```yaml
test:
  parallel: 4
  script:
    - flutter test --concurrency=4
```

## Troubleshooting

### Common Issues

1. **Runner Connection Issues**
   ```bash
   # Runner logs kontrol
   sudo gitlab-runner verify
   sudo journalctl -u gitlab-runner
   ```

2. **Cache Problems**
   ```yaml
   # Cache'i temizle
   clean_cache:
     script:
       - rm -rf .pub-cache
       - flutter clean
   ```

3. **Permission Errors**
   ```bash
   # Docker permissions
   sudo usermod -aG docker gitlab-runner
   sudo systemctl restart gitlab-runner
   ```

### Debug Commands

```bash
# Local pipeline test
gitlab-runner exec docker validate_environment

# Verbose pipeline run
gitlab-runner --debug exec docker build_dev

# Cache inspection
gitlab-runner exec docker --cache-dir /tmp/cache build_dev
```

## GitLab Pages Integration

### Documentation Deployment

```yaml
pages:
  stage: deploy
  script:
    - flutter doctor
    - flutter build web
    - mkdir public
    - cp -r build/web/* public/
  artifacts:
    paths:
      - public
  only:
    - main
```

## Multi-Project Pipelines

### Downstream Projects

```yaml
trigger_downstream:
  stage: deploy
  trigger:
    project: company/mobile-tests
    branch: main
  only:
    - main
```

## GitLab vs GitHub Actions Karşılaştırması

### Syntax Farkları

| Özellik | GitLab CI/CD | GitHub Actions |
|---------|--------------|----------------|
| Pipeline File | `.gitlab-ci.yml` | `.github/workflows/name.yml` |
| Stages | `stages: [build, test]` | `jobs: build:, test:` |
| Image | `image: flutter:latest` | `runs-on: ubuntu-latest` |
| Variables | `variables: VAR: value` | `env: VAR: value` |
| Cache | `cache: paths: [build/]` | `uses: actions/cache@v3` |
| Artifacts | `artifacts: paths: [dist/]` | `uses: actions/upload-artifact@v3` |

### Migration Strategy

GitHub Actions'dan GitLab CI/CD'ye geçiş:

1. **Workflow dosyasını dönüştür**:
   - `.github/workflows/` → `.gitlab-ci.yml`
   - `jobs:` → `stages:` ve job definitions
   - `runs-on:` → `image:` veya `tags:`

2. **Secrets'ları taşı**:
   - GitHub Secrets → GitLab Variables
   - Environment protection rules → GitLab protected variables

3. **Actions'ları script'lere çevir**:
   - `uses: actions/setup-*` → Docker image veya script
   - `uses: actions/cache@v3` → GitLab cache configuration

## Best Practices

### Pipeline Design

1. **Stage Organization**: Logical stage separation
2. **Job Dependencies**: Use `needs:` for complex dependencies
3. **Resource Optimization**: Efficient runner usage
4. **Error Handling**: Proper failure management
5. **Security**: Protected variables and environments

### Code Quality

```yaml
code_quality:
  stage: test
  image: docker:stable
  variables:
    DOCKER_DRIVER: overlay2
  services:
    - docker:stable-dind
  script:
    - docker run --rm -v "$PWD":/code codeclimate/codeclimate analyze -f json > codeclimate.json
  artifacts:
    reports:
      codequality: codeclimate.json
```

## İlgili Dokümantasyon

- [GitHub Workflow Detayları](GITHUB_WORKFLOW.md)
- [CI/CD Platform Karşılaştırması](CI_CD_COMPARISON.md)
- [Android Build Pipeline](ANDROID_BUILD_PIPELINE.md)
- [iOS Build Pipeline](IOS_BUILD_PIPELINE.md)
- [Branch Pipeline Strategy](BRANCH_PIPELINE_STRATEGY.md)
- [Flutter Project Setup Guide](FLUTTER_PROJECT_SETUP_GUIDE.md)
