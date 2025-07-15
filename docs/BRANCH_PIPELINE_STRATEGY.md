# GitHub ile Flutter Ortamlarında Geliştirme Stratejisi

Bu doküman, dev, staging ve prod ortamları ile Flutter projesinde GitHub Actions üzerinde en iyi geliştirme ve dağıtım stratejisini özetler.

---

## 1. Branch (Dal) Stratejisi

- **main/master:** Sadece prod (canlı) ortam kodları burada olur. Sadece testten geçmiş, release'e hazır kodlar merge edilir.
- **staging:** QA/test ortamı. main'den önce son kontrollerin ve testlerin yapıldığı branch.
- **develop:** Geliştiricilerin günlük işlerini yaptığı, yeni özelliklerin ve bugfixlerin eklendiği ana geliştirme branch'i.
- **feature/xxx, bugfix/xxx:** Her yeni özellik veya hata için develop'tan ayrılan kısa ömürlü branch'ler.

---

## 2. Ortamlar ve Pipeline Akışı

- **Dev:**
  - Geliştiriciler feature branch'lerinde çalışır, pull request ile develop'a merge eder.
  - develop branch'e push olunca otomatik dev flavor build alınır ve Firebase App Distribution'a gönderilir.
- **Staging:**
  - develop'tan staging'e pull request açılır.
  - staging branch'e merge olunca staging flavor build alınır ve QA/test ekibine Firebase üzerinden dağıtılır.
- **Prod:**
  - staging'den main'e pull request açılır.
  - main branch'e merge olunca prod flavor build alınır ve Firebase App Distribution üzerinden dağıtılır.

---

## 3. Pipeline ve Otomasyon

- Her branch için ayrı pipeline adımları tanımlanır:
  - develop → dev flavor build & dağıtım
  - staging → staging flavor build & dağıtım
  - main → prod flavor build & market yükleme
- Versiyon ve build number otomatik artırılır (özellikle prod için).
- Fastlane ve appdistribution.sh gibi scriptler pipeline’da otomatik çalıştırılır.

---

## 4. Firebase ve Config Ayrımı

- Her ortamın kendi Firebase projesi ve config dosyası olur.
- Her flavor kendi GoogleService-Info.plist / google-services.json dosyasını kullanır.
- Ortamlar arası veri ve test karışmaz.

---

## 5. Test ve Onay Süreci

- develop’ta kod review ve otomatik testler zorunlu tutulur.
- staging’de QA ekibi manuel/otomatik test yapar, onay verirse main’e merge edilir.
- main’e sadece staging’den merge request ile kod alınır, doğrudan push engellenir.

---

## 6. Özet Akış

1. **feature/xxx** → develop → (dev build, dağıtım)
2. **develop** → staging → (staging build, QA test, dağıtım)
3. **staging** → main → (prod build, market yükleme)

---

## 7. Neden Bu Strateji?

- Her ortam izole ve güvenli olur.
- Hatalı kodun prod’a çıkması engellenir.
- Test ve onay süreçleri netleşir.
- CI/CD ile otomasyon ve hız kazanılır.
