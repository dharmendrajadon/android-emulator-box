FROM ubuntu:18.04

# Use Bash as Shell
SHELL ["/bin/bash", "-c"]

# Set Android SDK path & build version variables
ENV ANDROID_HOME="${PWD}/android-home" \
    ANDROID_COMPILE_SDK="29" \
    ANDROID_BUILD_TOOLS="29.0.2" \
    ANDROID_SDK_TOOLS="6609375" \
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

ENV PATH="${PATH}:${ANDROID_HOME}/cmdline-tools/tools/bin/:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/emulator:${JAVA_HOME}/bin/"

ENV DEBIAN_FRONTEND="noninteractive" \
    TERM=dumb \
    DEBIAN_FRONTEND=noninteractive

WORKDIR /tmp

# Install Dependencies
RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
    apt-utils \
    wget \
    tar \
    unzip \
    lib32stdc++6 \
    lib32z1 \
    cpu-checker \
    qemu-kvm \
    libvirt-bin \
    ubuntu-vm-builder \
    bridge-utils \
    git \
    openjdk-8-jdk \
    python3.6

# Create Symbolic link for python3 & install pip3
RUN ln -sf /usr/bin/python3.6 /usr/bin/python3 && \
    apt-get install --yes python3-pip && \
    pip3 install requests

# Install & configure Android SDK
RUN install -d ${ANDROID_HOME}  && \
    wget -q --output-document="${ANDROID_HOME}/cmdline-tools.zip" "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS}_latest.zip"  && \
    pushd ${ANDROID_HOME} && \
    unzip -d cmdline-tools cmdline-tools.zip  && \
    popd && \
    sdkmanager --version  && \
    set +o pipefail  && \
    yes | sdkmanager --sdk_root=${ANDROID_HOME} --licenses  && \
    set -o pipefail  && \
    sdkmanager --sdk_root=${ANDROID_HOME} "platforms;android-${ANDROID_COMPILE_SDK}"  && \
    sdkmanager --sdk_root=${ANDROID_HOME} "platform-tools"  && \
    sdkmanager --sdk_root=${ANDROID_HOME} "build-tools;${ANDROID_BUILD_TOOLS}" && \
    sdkmanager --sdk_root=${ANDROID_HOME} "system-images;android-${ANDROID_COMPILE_SDK};google_apis;x86" && \
    sdkmanager --sdk_root=${ANDROID_HOME} "emulator" && \
    avdmanager --verbose create avd --force --name "google_pixel" --device "pixel" --package "system-images;android-${ANDROID_COMPILE_SDK};google_apis;x86" --tag "google_apis" --abi "x86"

COPY start_emulator.sh /

RUN chmod +x /start_emulator.sh

LABEL maintainer="Dharmendra Jadon"
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.name="/dharmendrajadon/android-emulator-box"
LABEL org.label-schema.version="${DOCKER_TAG}"
LABEL org.label-schema.usage="/README.md"
LABEL org.label-schema.build-date="${BUILD_DATE}"
