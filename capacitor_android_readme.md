# README – Django + Bootstrap → App Android con Capacitor (Linux CLI)

```bash
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
```
## 1️⃣ Prerequisiti

- Node.js e npm
- Capacitor CLI
```bash
npm install --save @capacitor/core @capacitor/cli
```
- Java JDK ≥ 17
- Android SDK installato (`~/Android/Sdk`)
- Gradle (incluso in Capacitor)
- ADB (per test su dispositivo)

---

## 2️⃣ Preparare l'app Django

1. Configura i file statici in `settings.py`:
```python
STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / "staticfiles"
```

2. Raccogli i file statici:
```bash
python manage.py collectstatic
```

3. Verifica il server Django:
```bash
python manage.py runserver 0.0.0.0:8000
```

---

## 3️⃣ Creare l'app Capacitor

1. Inizializza Capacitor:
```bash
npx cap init nomeApp com.tuo.dominio.app
```

2. Crea la cartella `www` e inserisci i file web (HTML, CSS, JS) o usa redirect al server Django:
```html
<script>
  window.location.href = "https://tuo-dominio.com";
</script>
```

3. Configura `capacitor.config.json`:
```json
{
  "appId": "com.tuo.dominio.app",
  "appName": "NomeApp",
  "webDir": "www",
  "bundledWebRuntime": false
}
```

---

## 4️⃣ Aggiungere piattaforma Android
```bash
npx cap add android
```

---

## 5️⃣ Copiare il build web
```bash
npx cap copy android
npx cap sync
```

---

## 6️⃣ Build APK Release con Gradle
```bash
cd ~/arciguardia_app/android
./gradlew assembleRelease
```
APK non firmato:
```
android/app/build/outputs/apk/release/app-release-unsigned.apk
```

---

## 7️⃣ Generare Keystore
```bash
keytool -genkey -v -keystore ~/ArciGuardiaApp/android/my-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias
```

---

## 8️⃣ Firmare l'APK con apksigner
```bash
BUILD_TOOLS=$(ls ~/Android/Sdk/build-tools/ | sort -V | tail -n 1)

~/Android/Sdk/build-tools/$BUILD_TOOLS/apksigner sign \
  --ks ~/ArciGuardiaApp/android/my-release-key.jks \
  --ks-key-alias my-key-Arci \
  --v1-signing-enabled true \
  --v2-signing-enabled true \
  ~/ArciGuardiaApp/android/app/build/outputs/apk/release/app-release-unsigned.apk
```
Rinomina l'APK finale:
```bash
mv ~/ArciGuardiaApp/android/app/build/outputs/apk/release/app-release-unsigned.apk \
   ~/ArciGuardiaApp/android/app/build/outputs/apk/release/app-release.apk
```

---

## 9️⃣ Verifica APK
```bash
~/Android/Sdk/build-tools/$BUILD_TOOLS/apksigner verify \
~/ArciGuardiaApp/android/app/build/outputs/apk/release/app-release.apk
```
> I warning sui file META-INF sono normali e non bloccano l'installazione.

---

## 🔟 Installazione APK su dispositivo
```bash
adb install -r ~/arciguardia_app/android/app/build/outputs/apk/release/app-release.apk
```

---

## Extra: Gestione Status Bar su Capacitor
```javascript
import { StatusBar, Style } from '@capacitor/status-bar';

StatusBar.setOverlaysWebView({ overlay: false });
StatusBar.setStyle({ style: Style.Dark });
```

---

## Script Bash “One-shot”
Salva come `build_release.sh`:
```bash
#!/bin/bash
set -e

PROJECT_DIR=~/arciguardia_app
APK_UNSIGNED=$PROJECT_DIR/android/app/build/outputs/apk/release/app-release-unsigned.apk
APK_RELEASE=$PROJECT_DIR/android/app/build/outputs/apk/release/app-release.apk
KEYSTORE=$PROJECT_DIR/android/my-release-key.jks
ALIAS=my-key-alias
BUILD_TOOLS=$(ls ~/Android/Sdk/build-tools/ | sort -V | tail -n 1)

# 1. Build release
cd $PROJECT_DIR/android
./gradlew assembleRelease

# 2. Firma APK
~/Android/Sdk/build-tools/$BUILD_TOOLS/apksigner sign \
  --ks $KEYSTORE \
  --ks-key-alias $ALIAS \
  --v1-signing-enabled true \
  --v2-signing-enabled true \
  $APK_UNSIGNED

# 3. Rinominare APK finale
mv $APK_UNSIGNED $APK_RELEASE

# 4. Verifica APK
~/Android/Sdk/build-tools/$BUILD_TOOLS/apksigner verify $APK_RELEASE

echo "APK finale pronto: $APK_RELEASE"
```
Rendi eseguibile e lancia:
```bash
chmod +x build_release.sh
./build_release.sh
```

