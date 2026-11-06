# Generación de documentación técnica del proyecto

Analiza exhaustivamente el repositorio actual y genera un documento llamado `PROJECT_CONTEXT.md` en la raíz del proyecto.

El objetivo es crear una documentación técnica completa que permita a otro desarrollador o asistente de IA comprender el proyecto, su arquitectura, implementación, funcionamiento y estado actual sin tener que analizar nuevamente todo el código fuente desde cero.

## 1. Información general

- Nombre del proyecto.
- Propósito y objetivos.
- Problema que busca resolver.
- Descripción general de su funcionamiento.
- Alcance actual del desarrollo.

## 2. Stack tecnológico

- Lenguajes de programación.
- Frameworks y librerías.
- Herramientas de desarrollo.
- Gestores de paquetes.
- Versiones identificables.
- Dependencias principales y su propósito.

## 3. Arquitectura del proyecto

- Patrón arquitectónico utilizado.
- Organización de las capas.
- Responsabilidades de cada módulo.
- Comunicación entre componentes.
- Principios de diseño identificables.
- Diagramas Mermaid cuando aporten claridad.

## 4. Estructura del repositorio

- Árbol de directorios.
- Descripción de las carpetas principales.
- Responsabilidad de los archivos importantes.
- Puntos de entrada de la aplicación.
- Archivos de configuración relevantes.

## 5. Funcionamiento interno

- Flujos principales de ejecución.
- Procesamiento de información.
- Comunicación entre módulos.
- Validaciones y manejo de errores.
- Gestión del estado, cuando corresponda.
- Servicios y lógica de negocio.

## 6. Base de datos y persistencia

- Motor de base de datos.
- Modelos y entidades.
- Tablas y campos.
- Relaciones y claves foráneas.
- Migraciones y configuración.
- Operaciones de lectura y escritura.
- Diagramas entidad-relación en Mermaid, si es posible.

## 7. APIs e integraciones

- Endpoints disponibles, si existen.
- Métodos HTTP.
- Parámetros y estructuras de entrada.
- Respuestas esperadas.
- Autenticación y autorización.
- Servicios externos e integraciones.
- Comunicación con otros componentes del sistema.

## 8. Seguridad

- Autenticación.
- Autorización.
- Protección de información.
- Validaciones.
- Manejo de credenciales.
- Variables de entorno relacionadas con seguridad.

## 9. Instalación y ejecución

- Requisitos previos.
- Instalación de dependencias.
- Configuración del entorno.
- Variables de entorno necesarias.
- Comandos para ejecutar.
- Comandos para compilar.
- Comandos para ejecutar pruebas.
- Configuración para desarrollo y producción.

## 10. Pruebas y calidad

- Pruebas existentes.
- Frameworks de testing.
- Cobertura disponible, si está documentada.
- Validaciones automáticas.
- Problemas conocidos.

## 11. Estado actual del proyecto

- Funcionalidades implementadas.
- Funcionalidades parcialmente implementadas.
- Funcionalidades pendientes.
- Limitaciones identificadas.
- Errores o problemas conocidos.
- Deuda técnica identificable.

## 12. Guía para futuros desarrolladores y asistentes de IA

- Cómo comenzar a trabajar en el proyecto.
- Dónde implementar nuevas funcionalidades.
- Convenciones de código existentes.
- Archivos que deben modificarse según cada tipo de tarea.
- Dependencias entre módulos.
- Consideraciones importantes para evitar romper funcionalidades existentes.

## Instrucciones importantes

1. Examina el repositorio completo antes de generar la documentación.
2. Analiza el código fuente real, no te limites a leer el README.
3. No inventes funcionalidades, endpoints, tablas, relaciones ni configuraciones.
4. Si un aspecto no puede verificarse, indícalo explícitamente.
5. Distingue entre funcionalidades implementadas, parciales y pendientes.
6. No modifiques código fuente, configuraciones ni archivos existentes.
7. No expongas contraseñas, tokens, claves API ni valores sensibles. Documenta únicamente los nombres de las variables de entorno.
8. Evita repetir información innecesariamente.
9. Utiliza Markdown con encabezados jerárquicos, tablas, listas y bloques de código.
10. Incluye diagramas Mermaid cuando ayuden a comprender la arquitectura o los flujos.
11. Mantén una documentación técnica clara, organizada y suficientemente detallada.
12. No generes archivos adicionales. El único archivo nuevo debe ser `PROJECT_CONTEXT.md`.

**Resultado esperado:** un documento `PROJECT_CONTEXT.md` completo, preciso y actualizado que permita comprender el estado real del proyecto y utilizarlo como contexto de referencia para continuar su desarrollo con otros asistentes de IA.
