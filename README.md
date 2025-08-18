# PuenteHumano 📚

> Un puente humano para que los libros lleguen a donde más se necesitan.

## 🎯 Objetivo

Conectar donantes de libros con bibliotecas comunitarias, usando personas viajeras como canal humano para transportar los libros.

## 🚀 Tecnologías

- **Frontend**: Flutter
- **Backend**: Supabase (PostgreSQL + Auth + Real-time)
- **Mapas**: Google Maps
- **QR/Scanner**: Mobile Scanner
- **Estado**: Provider

## 📱 Funcionalidades Principales

### 🔐 Autenticación
- Registro con roles: Donante, Transportista, Biblioteca
- Login seguro con Supabase Auth
- Perfiles de usuario con ubicación

### 📖 Para Donantes
- Publicar libros disponibles para donación
- Ver viajes disponibles hacia bibliotecas
- Seguimiento de envíos
- Sistema de calificaciones

### 🚛 Para Transportistas
- Publicar viajes con destinos y capacidad
- Ver donaciones pendientes en ruta
- Chat directo con donantes
- Confirmación de entrega con QR/PIN

### 🏛️ Para Bibliotecas
- Recibir libros con confirmación QR/PIN
- Estadísticas de libros recibidos
- Comunicación con transportistas

### 🗺️ Funciones Generales
- Mapa interactivo con rutas y bibliotecas
- Chat en tiempo real por envío
- Notificaciones automáticas
- Sistema de confianza con ratings

## 🛠️ Configuración del Proyecto

### 1. Clonar repositorio
\`\`\`bash
git clone <repository-url>
cd puente_humano_app
\`\`\`

### 2. Instalar dependencias
\`\`\`bash
flutter pub get
\`\`\`

### 3. Configurar Supabase
1. Crear proyecto en [supabase.com](https://supabase.com)
2. Ejecutar el schema SQL: \`supabase_schema.sql\`
3. Configurar las credenciales en \`lib/core/config/app_config.dart\`

### 4. Configurar Google Maps
1. Obtener API Key en Google Cloud Console
2. Configurar en \`android/app/src/main/AndroidManifest.xml\`
3. Configurar en \`ios/Runner/AppDelegate.swift\`

### 5. Ejecutar aplicación
\`\`\`bash
flutter run
\`\`\`

## 📂 Estructura del Proyecto

\`\`\`
lib/
├── core/
│   ├── config/          # Configuración (Supabase, constantes)
│   ├── models/          # Modelos de datos
│   ├── services/        # Servicios (Auth, Database, etc.)
│   ├── theme/           # Tema y estilos
│   └── routes/          # Navegación
├── providers/           # Estado global (Provider)
├── screens/            # Pantallas de la app
├── widgets/            # Widgets reutilizables
└── main.dart           # Punto de entrada
\`\`\`

## 🔒 Seguridad

- **Row Level Security (RLS)** activado en Supabase
- **Políticas de acceso** por rol de usuario
- **Validación** de permisos en frontend y backend
- **Tokens JWT** para autenticación segura

## 🌟 Flujo de Uso

1. **Donante** registra libro → estado "Pendiente"
2. **Transportista** acepta transportar → estado "En camino"
3. **Biblioteca** confirma recepción con QR/PIN → estado "Entregado"
4. Todos pueden **calificarse mutuamente** para generar confianza
5. **Estadísticas** y **mapa** muestran el impacto

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama: \`git checkout -b feature/nueva-funcionalidad\`
3. Commit: \`git commit -m 'Agregar nueva funcionalidad'\`
4. Push: \`git push origin feature/nueva-funcionalidad\`
5. Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver [LICENSE.md](LICENSE.md)

---

**Hecho con ❤️ para conectar libros con comunidades que los necesitan**