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
