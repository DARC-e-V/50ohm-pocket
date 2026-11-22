FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Keep the container SDK in sync with the project's FVM configuration.
COPY .fvmrc /tmp/flutter-fvm.json
RUN FLUTTER_VERSION=$(sed -n 's/^[[:space:]]*"flutter":[[:space:]]*"\([^"]*\)".*/\1/p' /tmp/flutter-fvm.json) \
    && test -n "$FLUTTER_VERSION" \
    && git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git /opt/flutter \
    && chown -R vscode:vscode /opt/flutter \
    && rm /tmp/flutter-fvm.json

ENV PATH="/opt/flutter/bin:${PATH}"

USER vscode
RUN flutter config --no-analytics --enable-web \
    && dart --disable-analytics \
    && flutter precache --web

