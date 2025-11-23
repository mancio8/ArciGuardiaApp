FROM debian:bullseye

# ------------------------------------------------------------------
# Dependencies
# ------------------------------------------------------------------
RUN apt-get update && apt-get install -y \
    wget curl unzip git ca-certificates \
    && update-ca-certificates

# ------------------------------------------------------------------
# Install Java 21 (Adoptium official API)
# ------------------------------------------------------------------
RUN wget -O /tmp/jdk.tar.gz \
    "https://api.adoptium.net/v3/binary/latest/21/ga/linux/x64/jdk/hotspot/normal/adoptium?project=jdk" \
    && mkdir -p /opt/java \
    && tar -xzf /tmp/jdk.tar.gz -C /opt/java --strip-components=1 \
    && rm /tmp/jdk.tar.gz

ENV JAVA_HOME="/opt/java"
ENV PATH="$JAVA_HOME/bin:$PATH"

# ------------------------------------------------------------------
# Install Node 20
# ------------------------------------------------------------------
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# ------------------------------------------------------------------
# Install Android commandline-tools
# ------------------------------------------------------------------
RUN mkdir -p /opt/android/cmdline-tools && \
    cd /opt/android/cmdline-tools && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O tools.zip && \
    unzip tools.zip && rm tools.zip && \
    mkdir -p /opt/android/cmdline-tools/latest && \
    mv cmdline-tools/* /opt/android/cmdline-tools/latest/

ENV ANDROID_HOME="/opt/android"
ENV PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

# ------------------------------------------------------------------
# Accept all SDK licenses
# ------------------------------------------------------------------
RUN yes | sdkmanager --licenses

# ------------------------------------------------------------------
# Install required Android packages
# ------------------------------------------------------------------
RUN sdkmanager "platform-tools" \
    "platforms;android-35" \
    "build-tools;34.0.0"

# ------------------------------------------------------------------
# Project folder
# ------------------------------------------------------------------
WORKDIR /app
