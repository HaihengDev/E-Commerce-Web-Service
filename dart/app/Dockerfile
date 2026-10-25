FROM dart:stable

ARG SERVICE_DIR
WORKDIR /app

RUN dart pub global activate dart_frog_cli
ENV PATH="/root/.pub-cache/bin:${PATH}"

COPY ${SERVICE_DIR}/pubspec.yaml ./pubspec.yaml
COPY ${SERVICE_DIR}/pubspec.lock ./pubspec.lock
RUN dart pub get

COPY ${SERVICE_DIR}/ ./
RUN dart_frog build

ARG PORT
ENV PORT=${PORT}
EXPOSE ${PORT}

CMD ["dart", "build/bin/server.dart"]
