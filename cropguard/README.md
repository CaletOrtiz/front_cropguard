# CropGuard

Aplicación móvil desarrollada con Flutter para ofrecer una interfaz de apoyo al diagnóstico de cultivos mediante imágenes de hojas.

## Descripción

CropGuard permite explorar información sobre cultivos, consultar el historial de diagnósticos y acceder a una sección de análisis de imágenes. El proyecto incluye una estructura preparada para conectar la interfaz con un servicio backend encargado del análisis.

> La disponibilidad real de cada funcionalidad depende de la implementación del frontend y de la conexión con el backend.

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
