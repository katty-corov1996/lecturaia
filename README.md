# LecturaIA

Aplicación móvil desarrollada con Flutter para gestionar una biblioteca personal inteligente. LecturaIA permite consultar un catálogo de libros, guardar favoritos de forma local, crear reseñas asociadas a usuarios autenticados y obtener recomendaciones de lectura mediante inteligencia artificial.

El proyecto fue desarrollado como Proyecto Final utilizando Flutter, GetX y un backend propio construido con FastAPI.

## Funcionalidades principales

- Registro de usuarios.
- Inicio y cierre de sesión.
- Autenticación mediante JWT.
- Almacenamiento seguro del token de sesión.
- Catálogo de 20 libros proporcionado por el backend.
- Estados de carga, contenido vacío y error.
- Libros favoritos con persistencia local mediante Hive.
- Creación, consulta y eliminación de reseñas.
- Reseñas protegidas por autenticación.
- Recomendaciones personalizadas de libros mediante Gemini.
- Manejo de errores de conexión y respuestas HTTP.
- Administración centralizada del estado mediante GetX.

## Tecnologías utilizadas

### Aplicación móvil

- Flutter
- Dart
- GetX
- Dio
- Hive
- Hive Flutter
- Flutter Secure Storage

### Backend

- Python
- FastAPI
- SQLAlchemy
- SQLite
- JWT
- Passlib
- bcrypt
- HTTPX
- python-dotenv

### Inteligencia artificial

- Gemini API.
- La clave del proveedor se almacena únicamente en el backend.
- Flutter nunca contiene ni envía directamente la clave de Gemini.

## Arquitectura

La aplicación utiliza una arquitectura por capas:

```text
Flutter
│
├── Screens
│   │
│   ▼
├── GetX Controllers
│   │
│   ▼
├── Services
│   │
│   ▼
└── FastAPI Backend
    │
    ├── SQLite
    ├── JWT
    └── Gemini API
