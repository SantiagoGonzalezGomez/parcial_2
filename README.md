# Parcial Flutter — Accidentes Tuluá + CRUD Establecimientos

**Autor:** Santiago Gonzalez Gomez  
**Repositorio:** [parcial_2](https://github.com/SantiagoGonzalezGomez/parcial_2)  
**Ramas:** `main` · `dev` · `feature/parcial_flutter_final`

---

## Descripción general

Aplicación Flutter con dos módulos integrados:

- **Módulo 1 — Estadísticas de Accidentes:** consume el dataset público de accidentes de tránsito en Tuluá desde Datos Abiertos Colombia, procesa los registros con un `Isolate` y visualiza 4 estadísticas usando `fl_chart`.
- **Módulo 2 — CRUD Establecimientos:** gestión completa de parqueaderos consumiendo la API REST del sistema de parqueadero, incluyendo carga de logo (imagen).

---

## APIs consumidas

### API 1 — Accidentes de Tránsito Tuluá (Datos Abiertos Colombia)

- **Fuente:** [datos.gov.co](https://www.datos.gov.co/resource/ezt8-5wyj.json)
- **Base URL:** `https://www.datos.gov.co/resource/ezt8-5wyj.json`
- **Autenticación:** No requiere
- **Endpoint usado:**
  - `GET /ezt8-5wyj.json?$limit=100000` — descarga masiva de registros para procesamiento con Isolate

**Campos relevantes del JSON:**

| Campo | Descripción |
|-------|-------------|
| `clase_de_accidente` | Tipo de accidente (Choque, Atropello, Volcamiento, etc.) |
| `gravedad_del_accidente` | Gravedad (Con muertos, Con heridos, Solo daños) |
| `barrio_hecho` | Barrio donde ocurrió el accidente |
| `dia` | Día de la semana |
| `hora` | Hora del accidente |
| `area` | Área (urbana/rural) |
| `clase_de_vehiculo` | Tipo de vehículo involucrado |

**Ejemplo de respuesta JSON:**
```json
[
  {
    "clase_de_accidente": "Choque",
    "gravedad_del_accidente": "Con heridos",
    "barrio_hecho": "CENTRO",
    "dia": "Lunes",
    "hora": "08:30",
    "area": "Urbana",
    "clase_de_vehiculo": "Automóvil"
  }
]
```

---

### API 2 — Establecimientos (API Parqueadero)

- **Fuente:** [parking.visiontic.com.co](https://parking.visiontic.com.co/api/documentation)
- **Base URL:** `https://parking.visiontic.com.co/api`
- **Autenticación:** No requiere
- **La API usa method spoofing de Laravel:** el endpoint de edición recibe `POST` con el campo `_method=PUT` en el form-data.

**Endpoints consumidos:**

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/establecimientos` | Listar todos los establecimientos |
| `GET` | `/establecimientos/{id}` | Ver detalle de uno |
| `POST` | `/establecimientos` | Crear nuevo (multipart/form-data) |
| `POST` | `/establecimiento-update/{id}` | Editar (incluye `_method=PUT`) |
| `DELETE` | `/establecimientos/{id}` | Eliminar |

**Campos del establecimiento:**

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `nombre` | String | Nombre del parqueadero |
| `nit` | String | NIT del establecimiento |
| `direccion` | String | Dirección |
| `telefono` | String | Teléfono de contacto |
| `logo` | File | Imagen del logo (multipart) |

**Ejemplo de respuesta JSON:**
```json
{
  "success": true,
  "data": [
    {
      "id": 112,
      "nombre": "otro",
      "nit": "890",
      "direccion": "calle 1",
      "telefono": "3",
      "logo": "sin-imagen.png",
      "estado": "A",
      "created_at": "2026-04-24T00:17:19.000000Z",
      "updated_at": "2026-04-24T00:17:19.000000Z"
    }
  ]
}
```

> **Nota:** La API envuelve la respuesta en `{ "success": true, "data": [...] }`, por lo que se accede al array con `response.data['data']`.

---

## Variables de entorno (.env)

```env
API_BASE_URL=https://parking.visiontic.com.co/api
ACCIDENTS_URL=https://www.datos.gov.co/resource/ezt8-5wyj.json
ACCIDENTS_LIMIT=100000
```

---

## Future/async/await vs Isolate

### ¿Cuándo usar `Future` / `async` / `await`?

Se usa para operaciones asíncronas que **no son intensivas en cómputo**: llamadas a APIs, lectura de archivos, operaciones de base de datos. Estas operaciones pasan la mayor parte del tiempo esperando respuestas externas (I/O), por lo que no bloquean el hilo principal de Flutter aunque se ejecuten en él.

**Ejemplo en este proyecto:** todas las llamadas con `Dio` a las APIs (`fetchAll`, `fetchById`, `create`, `update`, `delete`) usan `async/await` porque son operaciones de red.

### ¿Cuándo usar `Isolate`?

Se usa cuando hay **cómputo pesado** que sí bloquearía el hilo principal (UI thread). En Dart, todo el código corre en un solo hilo por defecto. Si se ejecuta una operación costosa en el hilo principal, la interfaz se congela.

### ¿Por qué se eligió `Isolate` para el procesamiento estadístico?

El endpoint de accidentes descarga hasta **100.000 registros** de JSON. Procesar ese volumen de datos (parsear, clasificar, agrupar, ordenar) en el hilo principal causaría que la app se congele por varios segundos. Por eso se usa `Isolate.run()` que ejecuta el cálculo en un hilo separado y devuelve el resultado sin afectar la fluidez de la UI.

```dart
// El raw list se pasa al Isolate y se obtiene el resultado sin bloquear la UI
final stats = await Isolate.run(() => computeAccidentStats(rawList));
```

Las líneas de consola requeridas confirman la ejecución:
```
[Isolate] Iniciado — 869 registros recibidos
[Isolate] Completado en 12 ms
```

---

## Arquitectura y estructura del proyecto

```
lib/
├── isolates/
│   └── accident_isolate.dart       # Función pura que corre en el Isolate
├── models/
│   ├── accident_model.dart         # Modelo de accidente
│   └── establishment_model.dart    # Modelo de establecimiento
├── providers/
│   ├── accident_provider.dart      # StateNotifier + Provider para accidentes
│   └── establishment_provider.dart # StateNotifier + Provider para establecimientos
├── router/
│   └── app_router.dart             # Configuración de rutas con go_router + AppShell
├── services/
│   ├── accident_service.dart       # Llamadas HTTP a la API de accidentes
│   ├── dio_client.dart             # Instancias de Dio configuradas
│   └── establishment_service.dart  # Llamadas HTTP CRUD a la API de parqueadero
├── views/
│   ├── accidents/
│   │   └── accidents_view.dart     # 4 gráficas con fl_chart
│   ├── dashboard/
│   │   └── dashboard_view.dart     # Pantalla principal con resumen
│   └── establishments/
│       ├── establishment_detail_view.dart  # Detalle + botones editar/eliminar
│       ├── establishment_form_view.dart    # Formulario crear/editar
│       └── establishments_list_view.dart  # Lista con ListView.builder
├── widgets/
│   └── skeleton_loader.dart        # Widgets skeleton animados personalizados
└── main.dart                       # Entry point, tema, ProviderScope
```

### Patrón de arquitectura

Se utiliza **Riverpod** como gestor de estado con el patrón `StateNotifier + StateNotifierProvider`. Cada módulo tiene su propio `Provider` de servicio, `StateNotifier` con la lógica de negocio y estado inmutable con `copyWith`.

---

## Rutas implementadas con go_router

| Nombre | Path | Descripción | Parámetros |
|--------|------|-------------|------------|
| `dashboard` | `/` | Pantalla principal | — |
| `accidents` | `/accidents` | Estadísticas con 4 gráficas | — |
| `establishments` | `/establishments` | Listado de parqueaderos | — |
| `establishment-new` | `/establishments/new` | Formulario crear | — |
| `establishment-detail` | `/establishments/:id` | Detalle del establecimiento | `id` (String) |
| `establishment-edit` | `/establishments/:id/edit` | Formulario editar | `id` (String) |

Todas las rutas están envueltas en un `ShellRoute` con `AppShell` que provee la barra de navegación inferior (`NavigationBar`) con tres destinos: Dashboard, Accidentes y Parkings.

**Navegación entre pantallas:**
- De lista a detalle: `context.push('/establishments/${item.id}')`
- De detalle a editar: `context.push('/establishments/${widget.id}/edit')`
- Tras crear/editar/eliminar: `context.go('/establishments')`

---

## Paquetes implementados

| Paquete | Versión | Uso |
|---------|---------|-----|
| `dio` | ^5.4.3 | Consumo de ambas APIs HTTP |
| `go_router` | ^13.2.0 | Navegación declarativa entre pantallas |
| `flutter_dotenv` | ^5.1.0 | Variables de entorno desde archivo `.env` |
| `fl_chart` | ^0.68.0 | Gráficas PieChart y BarChart |
| `flutter_riverpod` | ^2.5.1 | Gestión de estado con StateNotifier |
| `image_picker` | ^1.1.2 | Selección de logo desde galería |
| `intl` | ^0.19.0 | Internacionalización y formato de datos |
| `Isolate.run()` | SDK Flutter | Procesamiento en segundo plano (built-in) |

---

## Flujo de trabajo Git

```
main
 └── dev
      └── feature/parcial_flutter_final  ← desarrollo aquí
```

1. Se creó `feature/parcial_flutter_final` a partir de `dev`
2. Commits atómicos con prefijos convencionales (`feat:`, `fix:`, `docs:`)
3. Pull Request de `feature` → `dev` con descripción y evidencias
4. Merge a `dev` y luego a `main`
