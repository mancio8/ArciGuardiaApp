# ArciGuardiaApp - Build e Firma APK

Questo README descrive tutti i passaggi necessari per **configurare, buildare e firmare l’APK** di ArciGuardiaApp utilizzando **Docker** e **Capacitor**.

---

## 1️⃣ Prerequisiti

- Docker e Docker Compose installati.
- Progetto **ArciGuardiaApp** clonato.
- File `my-release-key.jks` per la firma dell’APK (vedi sezione Firma APK).

---

## 2️⃣ Dockerfile e Docker Compose

Assicurati di avere un **Dockerfile** configurato con:

- Ubuntu 24.04
- Java JDK 21
- Node.js 20 LTS + Corepack
- Android SDK Command-line Tools
- Build-tools e piattaforme Android necessarie

### Esempio Dockerfile (riassunto)

```dockerfile
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install Java, Node.js e strumenti base
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk curl unzip git build-essential wget \
    && apt-get clean && rm -rf /var/lib/apt/lists

# Node.js 20 LTS + Corepack
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && corepack enable

# Android SDK setup
RUN mkdir -p /opt/android/cmdline-tools && cd /opt/android/cmdline-tools \
    && curl -o commandlinetools.zip https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip \
    && unzip commandlinetools.zip && rm commandlinetools.zip \
    && mkdir -p latest && mv cmdline-tools latest/

ENV ANDROID_HOME=/opt/android
ENV ANDROID_SDK_ROOT=/opt/android
ENV PATH=$ANDROID_HOME/cmdline-tools/latest/cmdline-tools/bin:$ANDROID_HOME/platform-tools:$PATH

# Accetta licenze SDK
RUN yes | sdkmanager --sdk_root=$ANDROID_SDK_ROOT --licenses

# Installa build-tools e piattaforme Android necessarie
RUN sdkmanager --sdk_root=$ANDROID_SDK_ROOT "platform-tools" "build-tools;34.0.0" "platforms;android-35" "build-tools;36.0.0" "platforms;android-36"

WORKDIR /app
CMD ["bash"]
```
### Aggiornare versione dell’app
Apri android/app/build.gradle e modifica:
```gradle
versionCode 2
versionName "1.0.1"
```

### Costruire l’immagine Docker

```bash
docker build -t capacitor-android .

docker run -it --rm -v "$PWD":/app capacitor-android bash
```
### Riassunto comandi utili (dentro container)

```bash
cd /app
npm install
npx cap sync android
cd android
./gradlew assembleRelease
/opt/android/build-tools/34.0.0/apksigner sign ...
/opt/android/build-tools/34.0.0/apksigner verify ...
```
### Genera il keystore (una volta sola)

```bash
keytool -genkey -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 9125 -alias arciapp
```
### Firma l’APK

```bash
/opt/android/build-tools/34.0.0/apksigner sign \
  --ks /app/android/app/my-release-key.jks \
  --ks-key-alias arciapp \
  --ks-pass pass:TUA_PASSWORD \
  --key-pass pass:TUA_PASSWORD \
  --out /app/android/app-release-signed.apk \
  /app/android/app/build/outputs/apk/release/app-release-unsigned.apk

```

