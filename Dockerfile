# Sử dụng image Flutter có Android SDK
FROM ghcr.io/cirruslabs/flutter:latest AS build

# Đặt thư mục làm việc
WORKDIR /app

# Sửa lỗi "dubious ownership" của Flutter SDK
RUN git config --global --add safe.directory /sdks/flutter \
    && chown -R root:root /sdks/flutter \
    && chmod -R 777 /sdks/flutter

# Cài đặt OpenJDK 17 và đặt JAVA_HOME
RUN apt-get update && apt-get install -y openjdk-17-jdk && \
    update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java && \
    echo "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64" >> ~/.bashrc

# Kiểm tra phiên bản Java
RUN java -version

# Copy pubspec trước để tối ưu cache
COPY pubspec.yaml pubspec.lock /app/

# Cài đặt dependencies trước khi đổi user
RUN flutter pub get

# Sao chép toàn bộ source code vào container
COPY . /app

# Tạo user developer và thư mục home
RUN useradd -m developer && \
    chown -R developer:developer /app

# Chạy container với user developer
USER developer

# Kiểm tra phiên bản Flutter
RUN flutter --version

# Sửa lỗi git ownership lần nữa (đảm bảo không lỗi khi build)
RUN git config --global --add safe.directory /sdks/flutter

# Cập nhật settings.gradle để thêm Flutter plugin repository
RUN echo "dependencyResolutionManagement { repositories { google(); mavenCentral(); maven { url 'https://storage.googleapis.com/download.flutter.io' } } }" > /app/android/settings.gradle

# Kiểm tra môi trường Flutter
RUN flutter doctor

# Build APK ở chế độ release
RUN flutter build apk --release

# Tạo image chứa APK đã build
FROM alpine:latest
WORKDIR /app
COPY --from=build /app/build/app/outputs/flutter-apk/app-release.apk /app/app-release.apk

# Lệnh chạy mặc định khi container khởi động
CMD ["ls", "-l", "/app"]
