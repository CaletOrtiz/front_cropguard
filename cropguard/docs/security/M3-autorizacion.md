# M3 Autorización por recurso en FastAPI

Fecha: 2026-11-16. Control obligatorio de autorización del servidor, revisado por separado de la validación del JWT y de H-04. Categoría: **OWASP Mobile M3 Insecure Authentication/Authorization**; referencia adicional **OWASP API1 Broken Object Level Authorization**.

**Resultado: Cumple en las rutas y la política de propiedad revisadas.** No se confirmó un control de autorización faltante. No se abre un nuevo ID de hallazgo ni se cambia la lógica de producción. Se añaden pruebas de regresión y evidencia reproducible.

## Estado inicial y alcance

Frontend limpio, HEAD `2f60038`. Backend en HEAD `0f18414`, con dos cambios previos de H-01: `.gitignore` modificado y `repomix-output.xml` eliminado en el árbol de trabajo. Se preservan ambos y el archivo local de configuración; no se hace commit, push ni modificación del índice.

Se siguieron las 15 operaciones de `app/routers/plots.py`, `samples.py` y `plot_modules.py` hasta los servicios, repositorios y consultas que resuelven la propiedad. También se revisó la entrada compartida de estadísticas y timeline de lote. Los controles de cuidados, cosechas y pérdidas no reciben una auditoría completa nueva en esta entrega; sus tests existentes siguen pasando.

La política implementada permite al **propietario actual de la finca** acceder a sus cultivos, lotes y recursos asociados. En estas rutas no se encontró una concesión adicional por colaborador, administrador o texto de rol del perfil. Ser autor de un muestreo o informe no reemplaza esa comprobación de propiedad.

## Identidad autenticada y autorización separadas

`app/core/security.py:46-54` obtiene la identidad del JWT validado y utiliza su `sub` como usuario; las rutas pasan `usuario.id` al servicio. Los parámetros de propiedad enviados por el cliente no reemplazan esa identidad.

Esto es distinto de decidir si ese usuario puede operar sobre un recurso concreto. La decisión se hace siguiendo:

```text
JWT validado → usuario.id → lote → cultivo → finca.owner_id == usuario.id
```

El cliente de base de datos se crea con una credencial de servidor en `app/db/session.py:13`. Esa credencial puede eludir RLS; por tanto, las comprobaciones explícitas de FastAPI son necesarias. Los tests no implementan RLS en su doble de base de datos: la denegación depende de los controles reales del código.

## Evidencia del código

Todos los localizadores siguientes pertenecen a `back_cropguard/backend-ai-kroppi`.

| Área | Evidencia |
| --- | --- |
| Propiedad compartida | `app/repository/helpers.py:110-119`: busca la finca por su ID y `owner_id=user_id`; si no la encuentra, responde con un error 404. |
| Lotes | `helpers.py:147-155`: resuelve el cultivo del lote con la comprobación anterior. `plot_repository.py:53-54,74-75,88-89,108-109`: creación, listado, lectura y actualización pasan por ese control antes de devolver o cambiar datos. |
| Muestreos por lote | `sample_repository.py:9-10,56-57`: creación/listado verifican la propiedad del lote. El autor se asigna desde el usuario autenticado al crear. |
| Muestreos por ID | `sample_repository.py:71-83`: obtiene el muestreo y verifica el propietario de su lote. Actualización y eliminación usan este helper antes de escribir o borrar diagnósticos/imágenes. |
| Datos y creación de informes | `reports_service.py:38-43,215-219`: comprueba el lote antes de consultar datos relacionados o subir el archivo. El namespace del PDF y `created_by` se construyen en el servidor con la identidad autenticada. |
| Listado de informes | `reports_service.py:264-266`: valida la propiedad antes de listar los informes del lote. |
| Informe por ID / eliminación | `reports_service.py:269-282`: obtiene la relación con el lote y comprueba su propietario **antes** de firmar una URL, borrar el archivo o eliminar el registro. |
| Estadísticas y timeline | `stats_service.obtener` y `timeline_service.obtener` llaman a `repo.lote_propietario` antes de obtener las series del lote. |
| RLS declarada en el repositorio | `migrations/003_modulos_lote.sql:77-90` declara propiedad de informes mediante la misma relación con finca. No se comprobó su aplicación en una instancia remota. |

Las lecturas internas iniciales por ID sirven para resolver la relación con el propietario; no todas incluyen directamente un filtro de usuario. El resultado no se devuelve al solicitante ni se autoriza una modificación o una operación de archivo hasta superar la comprobación de propiedad. La existencia de esas lecturas internas no se presenta como una ruta pública sin autorización.

Los esquemas actuales y las listas de campos de actualización tampoco permiten reasignar un lote a otro cultivo ni mover un muestreo a otro lote mediante campos adicionales. Se verificó que los datos de autoría o rutas de archivo aportados por el cliente no determinan la autorización ni el namespace del informe.

## Pruebas automatizadas

Se añaden en el backend:

- `tests/test_resource_authorization.py`: matriz de decisiones mediante las rutas, servicios, repositorios y helpers de propiedad reales.
- `tests/run_authorization_checks.py`: ejecutor con configuración sintética, sin cargar `.env` y con transportes HTTP externos bloqueados.

Las identidades A y B utilizan **JWT válidos firmados con una clave ficticia de pruebas**, pasando por `usuario_actual` y la verificación real HS256. No se sustituyen las dependencias de autenticación por una autorización prefabricada. Esto acredita que un token válido de B no le da acceso al recurso de A, y viceversa. No prueba la consulta remota de JWKS ni los algoritmos RS256/ES256.

Solo se sustituyen los límites de I/O: respuestas de la base de datos y operaciones de Storage. El doble de consultas respeta los filtros `eq`, `in_` y de rango. **No se mockean `cargar_lote`, `cargar_cultivo` ni la decisión de propietario.

| Operación válida | Propietario | Otro usuario con JWT válido | Sin sesión |
| --- | --- | --- | --- |
| Crear lote, muestreo o informe | 201 | 404 | 401 |
| Listar/obtener lotes y muestreos; estadísticas, timeline y datos/listado/lectura de informes | 200 | 404 | 401 |
| Actualizar lote o muestreo | 200 | 404 | 401 |
| Eliminar muestreo o informe | 204 | 404 | 401 |

Cada una de las 15 operaciones se prueba contra recursos de ambos propietarios: **90 casos**. Se suman **7 casos** sobre reasignación de relaciones/autores, namespace y creador de informes, eliminación ajena de muestreos con diagnósticos, y recursos inexistentes.

En los accesos denegados se comprueba que no cambia ningún registro ni se firma, sube o elimina ningún objeto de Storage. En las peticiones sin sesión tampoco se ejecutan consultas de datos. Las entradas válidas de ambos propietarios siguen funcionando.

### Resultados antes y después

- Suite inicial: **44 pruebas aprobadas**, 1 advertencia, 1,41 s.
- Matriz específica con JWT ficticios verificados: **97 pruebas aprobadas**, 1 advertencia, 12,85 s.
- Suite final desde los archivos instalados en el backend: **141 pruebas aprobadas**, 1 advertencia, 4,02 s.
- `git diff --check` pasa en ambos repositorios.
- No se modifican las dependencias ni el código de producción para obtener estos resultados.

La advertencia de Starlette/TestClient sobre el uso de httpx ya estaba en la suite inicial. No se cambia esa dependencia en esta revisión.

Versiones ejecutadas: FastAPI 0.162.0, pytest 9.2.0, PyJWT 2.15.1, supabase-py 2.33.0 y httpx 0.28.1.

Desde la raíz del backend, reproducción sin credenciales reales:

```powershell
$env:PYTHONDONTWRITEBYTECODE='1'
.venv/Scripts/python.exe tests/run_authorization_checks.py tests/test_resource_authorization.py -q
.venv/Scripts/python.exe tests/run_authorization_checks.py tests -q
```

El ejecutor modifica únicamente su proceso de pruebas. No modifica la configuración del servidor, el contenido de `.env` ni un servidor FastAPI que ya esté en ejecución.

Evidencia estructurada: [evidence/M3-autorizacion.json](evidence/M3-autorizacion.json). Los logs locales `authorization-before.log`, `authorization-tests.log` y `authorization-after.log` no contienen credenciales reales y están ignorados por Git.

## Límites y entrega

No se usaron cuentas reales, Supabase remoto ni un bucket real. La autorización de API se verificó con datos ficticios y consultas simuladas que ejecutan los filtros del código. Queda pendiente acreditar el despliegue de RLS y ejecutar, si se requiere evidencia de producción, el mismo cruce entre dos cuentas de prueba en un entorno autorizado.

Los resultados no acreditan todas las rutas del backend, políticas de colaboración no definidas aquí ni la auditoría incompleta de formularios/carga de imágenes H-04. La revisión se mantiene separada de ese hallazgo.

Cambios de esta entrega: los dos archivos de pruebas del backend, este documento y su JSON de evidencia en el frontend. Se conservan los cambios previos de H-01 del backend. No hay commit ni push.

**No se cuenta como una nueva deficiencia corregida.** El control ya estaba implementado; esta entrega aporta evidencia de Cumple y comprobaciones de regresión. No se declara alcanzado el mínimo global de cinco correcciones por añadir esta revisión.

Commit sugerido para las pruebas: `test(security): M3 verificar autorización por recurso en FastAPI`.

Referencia: [OWASP API1 Broken Object Level Authorization](https://api-security.owasp.org/editions/2023/en/0xa1-broken-object-level-authorization/).

