# Icone Android per Capacitor

Questo README spiega passo passo come generare e installare le icone per un'app Android con **Capacitor**, usando `cordova-res`.  
Non include splash screen né supporto iOS.

---

## **1️⃣ Requisiti**

- Node.js installato  
- Capacitor installato nel progetto (`npm install @capacitor/core @capacitor/cli`)  
- Cordova-res installato globalmente:

```bash
npm install -g cordova-res
```

- Immagine icona principale: `resources/icon.png` (consigliata 1024×1024 px, PNG senza trasparenza)

---

## **2️⃣ Aggiornare il file `capacitor.config.json`**

Assicurati che sia così:

```json
{
  "appId": "com.arciguardia.online",
  "appName": "arciguardia",
  "webDir": "www",
  "server": {
    "url": "https://www.arciguardia.online",
    "cleartext": false
  },
  "plugins": {
    "StatusBar": {
      "overlaysWebView": false,
      "style": "LIGHT",
      "backgroundColor": "#008c45"
    },
    "Android": {
      "adjustMarginsForEdgeToEdge": "always"
    }
  },
  "android": {
    "icon": "resources/icon.png"
  }
}
```

> Nota: nessun splash, nessun iOS.

---

## **3️⃣ Creare cartelle per le icone (solo se non esistono)**

```bash
mkdir -p android/app/src/main/res/mipmap-mdpi
mkdir -p android/app/src/main/res/mipmap-hdpi
mkdir -p android/app/src/main/res/mipmap-xhdpi
mkdir -p android/app/src/main/res/mipmap-xxhdpi
mkdir -p android/app/src/main/res/mipmap-xxxhdpi
```

---

## **4️⃣ Generare le icone Android**

```bash
cordova-res android --skip-config --copy --skip-splash
```

- `--skip-config` → non modifica `config.xml`  
- `--copy` → copia direttamente le icone nelle cartelle native  
- `--skip-splash` → ignora splash screen (utile se è piccolo o non serve)

---

## **5️⃣ Copiare manualmente le icone (opzionale)**

Se ci sono stati WARN durante la copia automatica:

```bash
cp resources/android/icon/mdpi/* android/app/src/main/res/mipmap-mdpi/
cp resources/android/icon/hdpi/* android/app/src/main/res/mipmap-hdpi/
cp resources/android/icon/xhdpi/* android/app/src/main/res/mipmap-xhdpi/
cp resources/android/icon/xxhdpi/* android/app/src/main/res/mipmap-xxhdpi/
cp resources/android/icon/xxxhdpi/* android/app/src/main/res/mipmap-xxxhdpi/
```

---

## **6️⃣ Sincronizzare Capacitor**

```bash
npx cap sync android
```

---

## **7️⃣ Pulire e buildare Android**

```bash
npx cap clean android
npx cap open android
```

- In Android Studio: **Build → Clean Project → Rebuild Project**  
- Verifica che ci siano i file:

```
android/app/src/main/res/mipmap-*/ic_launcher.png
android/app/src/main/res/mipmap-*/ic_launcher_round.png
```

---

✅ Ora l’app Android userà le tue icone personalizzate.

