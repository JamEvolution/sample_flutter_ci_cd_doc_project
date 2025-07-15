fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Android

### android dev

```sh
[bundle exec] fastlane android dev
```

Dev APK build ve Firebase App Distribution

### android staging

```sh
[bundle exec] fastlane android staging
```

Staging APK build ve Firebase App Distribution

### android prod

```sh
[bundle exec] fastlane android prod
```

Prod APK build ve Firebase App Distribution

### android test

```sh
[bundle exec] fastlane android test
```

Flutter testlerini çalıştır

### android lint

```sh
[bundle exec] fastlane android lint
```

Kod kalite kontrolü

### android clean

```sh
[bundle exec] fastlane android clean
```

Proje temizleme ve yeniden yapılandırma

### android bump_version

```sh
[bundle exec] fastlane android bump_version
```

Version artırma

### android prepare_ci

```sh
[bundle exec] fastlane android prepare_ci
```

CI ortamını hazırla

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
