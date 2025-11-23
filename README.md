ArciGuardiaApp - Build e Firma APK

Questo README descrive tutti i passaggi necessari per configurare, buildare e firmare l'APK di ArciGuardiaApp utilizzando Docker e Capacitor.

1️⃣ Prerequisiti

Docker e Docker Compose installati.

Project ArciGuardiaApp clonato.

File my-release-key.jks per la firma (vedi sezione Firma APK).

2️⃣ Dockerfile e Docker Compose

Assicurati di avere un Dockerfile configurato con:

Ubuntu 24.04

Java JDK 21

Node.js 20 LTS + Corepack

Android SDK Command-line Tools

Build-tools e piattaforme Android necessarie

Esempio Dockerfile (riassunto):

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y openjdk-21-jdk curl unzip git build-essential wget \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs && corepack enable

# Android SDK setup
RUN mkdir -p /opt/android/cmdline-tools && cd /opt/android/cmdline-tools \
    && curl -o commandlinetools.zip https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip \
    && unzip commandlinetools.zip && rm commandlinetools.zip \
    && mkdir -p latest && mv cmdline-tools latest/

ENV ANDROID_HOME=/opt/android
ENV ANDROID_SDK_ROOT=/opt/android
ENV PATH=$ANDROID_HOME/cmdline-tools/latest/cmdline-tools/bin:$ANDROID_HOME/platform-tools:$PATH

RUN yes | sdkmanager --sdk_root=$ANDROID_SDK_ROOT --licenses
RUN sdkmanager --sdk_root=$ANDROID_SDK_ROOT platform-tools build-tools;34.0.0 platforms;android-35 build-tools;36.0.0 platforms;android-36

WORKDIR /app
CMD ["bash"]

Docker Compose deve montare il progetto e costruire il container capacitor-builder.

3️⃣ Installare dipendenze Node e sincronizzare Capacitor

Dentro il container:

cd /app
npm install        # Installa tutte le dipendenze Node
npx cap sync android   # Sincronizza il progetto web con Android

npm install deve essere eseguito ogni volta che package.json o package-lock.json cambiano.

npx cap sync android deve essere eseguito dopo modifiche in www/ o aggiunta/rimozione plugin.

docker run -it --rm -v "$PWD":/app capacitor-android bash


4️⃣ Build APK

cd android
./gradlew assembleRelease

L’APK non firmato sarà in app/build/outputs/apk/release/app-release-unsigned.apk

5️⃣ Firma APK

Genera il keystore (una volta sola, se non ce l’hai):

keytool -genkey -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 9125 -alias arciapp

Firma l’APK:

/opt/android/build-tools/34.0.0/apksigner sign \
  --ks /app/android/app/my-release-key.jks \
  --ks-key-alias arciapp \
  --ks-pass pass:TUA_PASSWORD \
  --key-pass pass:TUA_PASSWORD \
  --out /app/android/app-release-signed.apk \
  /app/android/app/build/outputs/apk/release/app-release-unsigned.apk

Verifica la firma:

/opt/android/build-tools/34.0.0/apksigner verify /app/android/app-release-signed.apk

L’APK firmato si trova in /app/android/app-release-signed.apk

6️⃣ Aggiornare versione dell’app

Apri android/app/build.gradle e modifica:

versionCode 2
versionName "1.0.1"

Ogni aggiornamento dell’app deve incrementare versionCode.

versionName è la versione visibile all’utente.

Poi ricostruisci e firma l’APK.

7️⃣ Riassunto comandi utili

# Dentro container
cd /app
npm install
npx cap sync android
cd android
./gradlew assembleRelease
/opt/android/build-tools/34.0.0/apksigner sign ...
/opt/android/build-tools/34.0.0/apksigner verify ...

Con questi passaggi puoi buildare, firmare e aggiornare l’app senza problemi di licenze SDK.

