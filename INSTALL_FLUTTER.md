# Instalación de Flutter

## 🚀 Paso 1: Descargar Flutter SDK

### Para Linux:
```bash
# Descargar Flutter
cd ~
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.3-stable.tar.xz

# Extraer Flutter
tar xf flutter_linux_3.24.3-stable.tar.xz

# Agregar al PATH
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
source ~/.bashrc
```

### Para Windows:
1. Ve a: https://docs.flutter.dev/get-started/install/windows
2. Descarga: `flutter_windows_3.24.3-stable.zip`
3. Extrae en `C:\flutter`
4. Agrega `C:\flutter\bin` al PATH del sistema

### Para macOS:
```bash
# Con Homebrew
brew install --cask flutter

# O manual:
cd ~
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.24.3-stable.zip
unzip flutter_macos_3.24.3-stable.zip
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.zshrc
source ~/.zshrc
```

## 🔧 Paso 2: Verificar instalación

```bash
flutter doctor
```

Esto te dirá qué falta instalar.

## 📱 Paso 3: Configurar para desarrollo

```bash
# Aceptar licencias de Android
flutter doctor --android-licenses

# Para desarrollo web
flutter config --enable-web

# Para desarrollo de escritorio
flutter config --enable-linux-desktop
flutter config --enable-macos-desktop
flutter config --enable-windows-desktop
```

## 🚀 Paso 4: Ejecutar el proyecto

```bash
cd /home/jido/puente_humano_app

# Obtener dependencias
flutter pub get

# Ejecutar en web (más fácil para empezar)
flutter run -d web-server --web-port 8080

# O ejecutar en dispositivo conectado
flutter run
```

## 📦 Dependencias adicionales

Si usas **VS Code**, instala:
- Flutter extension
- Dart extension

Si usas **Android Studio**:
- Flutter plugin
- Dart plugin

## 🔥 Ejecutar rápidamente

Una vez instalado Flutter:

```bash
cd /home/jido/puente_humano_app
flutter run -d chrome
```

¡Y listo! Tu app se abrirá en el navegador.