# CropGuard

Aplicación Flutter para diagnóstico de cultivos.

## Inicio de sesión con Google

El flujo nativo está conectado mediante `features/auth` y Supabase. Antes de
probarlo:

1. En Google Cloud, configura la pantalla de consentimiento y crea las
   credenciales OAuth para las plataformas que vas a usar. El cliente Android
   debe estar registrado con el nombre de paquete `com.example.cropguard` y la
   huella SHA-1 de firma correspondiente. Ese ID Android se configura en Google
   Cloud; no se pasa como `serverClientId` en Dart. Conserva el ID de cliente
   web como `GOOGLE_WEB_CLIENT_ID`, pues es el que necesita el plugin para
   obtener el ID token destinado a Supabase.
2. Para iOS, registra el ID de cliente de iOS como `GOOGLE_IOS_CLIENT_ID` y
   configura su URL scheme reverso en `ios/Runner/Info.plist` (o mediante el
   archivo `GoogleService-Info.plist`).
3. En Supabase, habilita **Authentication → Sign In / Providers → Google** y
   configura las credenciales OAuth de Google.
4. El ID de cliente web se configura como valor predeterminado en
   `lib/core/network/supabase/supabase_auth_service.dart`. Puedes reemplazarlo
   con un valor de compilación si necesitas distintos proyectos:

   ```bash
   flutter run --dart-define=GOOGLE_WEB_CLIENT_ID=tu-id-web.apps.googleusercontent.com
   ```

   Para iOS también se puede pasar `--dart-define=GOOGLE_IOS_CLIENT_ID=tu-id-ios.apps.googleusercontent.com`.

No incluyas secretos OAuth en el repositorio. El botón de Google autentica con
Supabase y, si la operación termina correctamente, navega a la pantalla de
inicio.

## Tecnologías utilizadas

- **Flutter:** desarrollo de la interfaz móvil.
- **Dart:** lenguaje de programación.
- **flutter_bloc:** gestión del estado de la funcionalidad de diagnóstico.
- **GoRouter:** navegación entre pantallas.
- **Dio:** comunicación HTTP con el backend.
- **image_picker:** selección de imágenes.
- **Google Fonts:** personalización tipográfica.
- **Equatable:** comparación de objetos y estados.

## Estructura del proyecto

El código fuente se encuentra en `cropguard/lib/` y está organizado de la siguiente manera:

- `core/`: constantes, modelos y utilidades compartidas.
- `features/crop_diagnosis/`: funcionalidad de diagnóstico, organizada en datos, dominio y presentación.
- `navigation/`: configuración de rutas y navegación.
- `presentation/common/`: componentes reutilizables de interfaz.
- `presentation/screens/`: pantallas de autenticación, inicio, cultivos, historial, perfil y recomendaciones.
- `presentation/themes/`: configuración del tema visual.

## Arquitectura del diagnóstico

La funcionalidad de diagnóstico utiliza una separación por responsabilidades:

1. **Presentación:** la pantalla permite interactuar con la funcionalidad y el BLoC administra sus estados.
2. **Dominio:** el caso de uso coordina la solicitud de análisis.
3. **Datos:** el repositorio implementa la comunicación con el backend y procesa la respuesta.
4. **Backend:** debe recibir la imagen y devolver los datos del diagnóstico según el contrato de la API.

## Requisitos

- Flutter instalado.
- Dart compatible con la versión especificada en `cropguard/pubspec.yaml`.
- Un editor compatible con Flutter, como Visual Studio Code.
- Un backend accesible y correctamente configurado para probar el análisis de imágenes.

## Instalación y ejecución

Desde la carpeta raíz del repositorio, entra en el proyecto Flutter:

```bash
cd cropguard
flutter pub get
flutter run
```

Para revisar posibles problemas estáticos:

```bash
flutter analyze
```

## Configuración del backend

La URL base del backend se configura en `lib/navigation/app_router.dart`. Antes de probar el diagnóstico, verifica que la dirección corresponda al servidor real y que sus endpoints coincidan con los implementados en el repositorio.

## Estado del proyecto

Esta documentación describe la estructura observada en el código fuente. La conexión con servicios externos y el funcionamiento de cada pantalla deben verificarse durante las pruebas de la aplicación.
