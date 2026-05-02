# Referencia completa de `manifest.json` para mazos `.flashjp`

Este documento describe el comportamiento real del importador actual de la app.
La fuente de verdad es el codigo de `lib/features/importer/importer_service.dart`,
no una especificacion teorica.

## Alcance

Este documento cubre:

- todas las claves que el importador lee desde `manifest.json`
- donde debe ir cada clave
- que tipos acepta realmente el parser
- que valor por defecto se usa si una clave falta o no se puede parsear
- que configuraciones del mazo existen en la app pero no se pueden definir
  desde `manifest.json`
- como se aplican estas configuraciones al importar un mazo nuevo o al
  actualizar uno existente

## Estructura minima del paquete

El importador acepta dos layouts:

1. Archivos en la raiz del ZIP.
2. Un unico directorio contenedor con todo el paquete dentro.

Ejemplos validos:

```text
manifest.json
flashcards.db
audio/cat.mp3
images/cover.png
```

```text
starter_pack/
  manifest.json
  flashcards.db
  audio/cat.mp3
  images/cover.png
```

Si hay varios archivos llamados `manifest.json`, el importador usa el que quede
mas cerca de la raiz del paquete.

## Regla general de parseo

- `manifest.json` debe ser un objeto JSON.
- Las claves desconocidas no provocan error, pero se ignoran.
- Si una clave conocida viene con un tipo invalido, normalmente se usa el
  valor por defecto o el valor de respaldo de esa propiedad.
- Los `String` obligatorios se leen con `toString().trim()`.
- El importador no valida que `language_id` sea un ISO real. Solo exige que no
  quede vacio tras `trim()`.

## Resumen rapido: claves admisibles

### Claves validas en la raiz de `manifest.json`

Estas son las unicas claves que el importador lee directamente en el nivel raiz:

| Clave | Obligatoria | Tipo esperado | Uso |
| --- | --- | --- | --- |
| `language_id` | Si | `String` | Codigo de idioma del mazo. |
| `pack_name` | Si | `String` | Nombre importado del mazo. |
| `db_filename` | Si | `String` | Nombre o ruta del archivo SQLite. |
| `settings` | No | `Object` | Bloque de configuraciones del mazo. |
| `new_card_min_correct_reps` | No | `int`/`num`/`String` entero | Minimo de aciertos para tarjetas nuevas. |
| `new_card_intra_day_minutes` | No | `int`/`num`/`String` entero | Espera intra-dia para nuevas. |
| `deck_icon` | No | `String` | Referencia a icono del mazo. |
| `deckIcon` | No | `String` | Alias camelCase de `deck_icon`. |
| `deck_icon_path` | No | `String` | Alias de icono. |
| `deckIconPath` | No | `String` | Alias camelCase de `deck_icon_path`. |
| `icon` | No | `String` | Alias corto de icono. |
| `icon_path` | No | `String` | Alias corto de icono. |
| `iconPath` | No | `String` | Alias camelCase de `icon_path`. |

### Claves validas dentro de `settings`

Estas claves solo se leen dentro de `manifest.json.settings`:

| Clave | Tipo esperado | Uso |
| --- | --- | --- |
| `new_cards_per_day` | `int`/`num`/`String` entero | Limite diario de nuevas. |
| `max_reviews_per_day` | `int`/`num`/`String` entero | Limite diario de repasos. |
| `lapse_tolerance` | `int`/`num`/`String` entero | Cuantos fallos seguidos tolerar antes de relearning. |
| `use_fixed_interval_on_lapse` | `bool`/`num`/`String` | Si el lapse usa intervalo fijo. |
| `lapse_fixed_interval` | `double`/`num`/`String` numerico | Intervalo fijo tras lapse, en dias. |
| `p_min` | `double`/`num`/`String` numerico | Probabilidad minima usada en el calculo de intervalo. |
| `alpha` | `double`/`num`/`String` numerico | Ajuste por respuesta correcta. |
| `beta` | `double`/`num`/`String` numerico | Ajuste por respuesta incorrecta. |
| `offset` | `double`/`num`/`String` numerico | Valor restado al intervalo final. |
| `initial_nt` | `double`/`num`/`String` numerico | Decaimiento inicial de las tarjetas importadas. |
| `learning_steps` | `List` de numeros o strings numericos | Pasos fijos de aprendizaje, en dias. |
| `enable_write_mode` | `bool`/`num`/`String` | Activa escritura en tarjetas de produccion. |
| `write_mode_threshold` | `int`/`num`/`String` entero | Exactitud minima para habilitar "Bien". |
| `write_mode_max_reps` | `int`/`num`/`String` entero | Numero maximo de aciertos antes de apagar write mode. |
| `deck_icon` | `String` | Alias de icono dentro de `settings`. |
| `deck_icon_path` | `String` | Alias de icono dentro de `settings`. |
| `icon` | `String` | Alias de icono dentro de `settings`. |
| `icon_path` | `String` | Alias de icono dentro de `settings`. |

## Aviso importante sobre ubicacion de claves

Hay dos detalles faciles de pasar por alto:

1. `new_card_min_correct_reps` y `new_card_intra_day_minutes` se leen en la
   raiz del `manifest.json`, no dentro de `settings`.
2. Dentro de `settings`, los alias camelCase del icono (`deckIcon`,
   `deckIconPath`, `iconPath`) no se leen. Dentro de `settings` solo se
   reconocen las variantes snake_case listadas arriba.

En otras palabras:

- `manifest.json.new_card_min_correct_reps` funciona.
- `manifest.json.settings.new_card_min_correct_reps` hoy no tiene efecto.
- `manifest.json.deckIconPath` funciona.
- `manifest.json.settings.deckIconPath` hoy no tiene efecto.

## Ejemplo completo recomendado

```json
{
  "language_id": "ja",
  "pack_name": "Japones Basico",
  "db_filename": "flashcards.db",
  "new_card_min_correct_reps": 2,
  "new_card_intra_day_minutes": 10,
  "deck_icon": "images/cover.png",
  "settings": {
    "new_cards_per_day": 20,
    "max_reviews_per_day": 200,
    "lapse_tolerance": 0,
    "use_fixed_interval_on_lapse": true,
    "lapse_fixed_interval": 1.0,
    "p_min": 0.9,
    "alpha": 0.1,
    "beta": 0.5,
    "offset": 0.0,
    "initial_nt": 0.015,
    "learning_steps": [1.0, 4.0],
    "enable_write_mode": false,
    "write_mode_threshold": 80,
    "write_mode_max_reps": 0
  }
}
```

## Detalle de cada parametro

### `language_id`

- Obligatorio.
- Se convierte a `String` y se le aplica `trim()`.
- Si queda vacio, la importacion falla.
- Se usa como `isoCode` del mazo.
- Tambien se usa para construir los tipos de tarjeta:
  - `{language_id}_recog`
  - `{language_id}_prod`
- No hay validacion de longitud, formato ni lista blanca.

### `pack_name`

- Obligatorio.
- Se convierte a `String` y se le aplica `trim()`.
- Si queda vacio, la importacion falla.
- Es el nombre logico del mazo importado.
- Si ya existe un mazo con ese nombre, la UI actual ofrece actualizar el mazo
  existente o crear uno nuevo con otro nombre.
- Si el usuario elige otro nombre al importar, el nombre final del mazo puede
  no coincidir con `pack_name`.

### `db_filename`

- Obligatorio.
- Se convierte a `String` y se le aplica `trim()`.
- Si queda vacio, la importacion falla.
- Puede ser solo un nombre (`flashcards.db`) o una ruta relativa
  (`data/flashcards.db`).
- El importador intenta encontrarlo en este orden:
  1. Ruta exacta relativa a la carpeta del `manifest.json`.
  2. Coincidencia exacta de la ruta relativa al recorrer el paquete.
  3. Coincidencia por basename del archivo.
- Recomendacion: usa la ruta exacta y evita depender de la busqueda por nombre.

### `settings`

- Opcional.
- Solo se usa si es un objeto JSON.
- Si no existe, o si existe pero no es un objeto, se ignora y se usan defaults.
- Solo se leen las claves listadas en este documento. Lo demas se ignora.

### `new_card_min_correct_reps`

- Opcional.
- Va en la raiz, no dentro de `settings`.
- Default del importador: `2`.
- Define cuantas respuestas correctas necesita una tarjeta nueva antes de salir
  del tramo inicial intra-dia y pasar a los `learning_steps`.
- En runtime la cola de aprendizaje para nuevas usa `max(1, valor)`, asi que
  valores `<= 0` terminan comportandose como `1`.

### `new_card_intra_day_minutes`

- Opcional.
- Va en la raiz, no dentro de `settings`.
- Default del importador: `10`.
- Define cuantos minutos dura cada repeticion intra-dia extra de una tarjeta
  nueva antes de entrar a `learning_steps`.
- En runtime se usa `max(1, valor)`, asi que valores `<= 0` terminan como `1`.

### Alias de icono (`deck_icon`, `deckIcon`, `deck_icon_path`, etc.)

- Opcionales.
- Permiten asignar un icono al mazo desde un archivo incluido en el paquete.
- En la raiz se revisan en este orden:
  1. `deck_icon`
  2. `deckIcon`
  3. `deck_icon_path`
  4. `deckIconPath`
  5. `icon`
  6. `icon_path`
  7. `iconPath`
- Si ninguno existe en raiz, el importador revisa dentro de `settings` solo:
  1. `deck_icon`
  2. `deck_icon_path`
  3. `icon`
  4. `icon_path`
- La referencia puede ser un path relativo, un basename e incluso un `file://`.
- La busqueda del archivo multimedia se hace con esta estrategia:
  1. coincidencia exacta
  2. coincidencia exacta tras `Uri.decodeFull`
  3. coincidencia exacta en minusculas
  4. coincidencia en minusculas tras `Uri.decodeFull`
  5. coincidencia por nombre sin extension
- El archivo de icono debe existir dentro del paquete y tener extension.
- Si hay varias colisiones por basename o por stem, la primera coincidencia
  encontrada gana. Conviene evitar nombres ambiguos.

## Configuraciones soportadas dentro de `settings`

### `settings.new_cards_per_day`

- Default del importador: `20`.
- Controla el cupo diario de tarjetas nuevas del mazo.
- La UI valida `0..10000`, pero el importador no impone ese rango.

### `settings.max_reviews_per_day`

- Default del importador: `200`.
- Controla el limite diario de repasos.
- La UI valida `0..100000`, pero el importador no impone ese rango.

### `settings.lapse_tolerance`

- Default del importador: `0`.
- Si es `0`, la tolerancia por lapses queda desactivada.
- Si es `> 0`, al llegar a ese numero de fallos consecutivos la tarjeta pasa a
  `relearning`.
- La UI valida `0..1000`.

### `settings.use_fixed_interval_on_lapse`

- Default del importador: `true`.
- Si es `true`, un fallo en review programa `lapse_fixed_interval`.
- Si es `false`, el fallo recalcula el siguiente intervalo con la formula del
  algoritmo en vez de usar un intervalo fijo.

### `settings.lapse_fixed_interval`

- Default del importador: `1.0`.
- Se interpreta en dias.
- Solo entra en juego si `use_fixed_interval_on_lapse` es `true`.
- Si el intervalo es menor que `1.0`, la tarjeta puede repetirse el mismo dia.
- La UI recomienda un valor `>= 0.000001`.

### `settings.p_min`

- Default del importador: `0.90`.
- Se usa en la formula del intervalo:
  `tStar = (-ln(P_min) / nt) - offset`
- En runtime se clamp a `0.000001..0.999999` antes de calcular el logaritmo.
- La UI valida precisamente ese mismo rango.

### `settings.alpha`

- Default del importador: `0.10`.
- En una respuesta correcta de review:
  `nt = nt * (1 - alpha)`
- Cuanto mayor sea `alpha`, mas baja `nt` tras acertar y mas lento se vuelve el
  olvido.
- La UI exige `>= 0`, pero el importador no lo impone.

### `settings.beta`

- Default del importador: `0.50`.
- En una respuesta incorrecta de review:
  `nt = nt * (1 + beta)`
- Cuanto mayor sea `beta`, mas sube `nt` tras fallar y mas rapido se vuelve el
  olvido.
- La UI exige `>= 0`, pero el importador no lo impone.

### `settings.offset`

- Default del importador: `0.0`.
- Se resta al intervalo final calculado.
- La UI no impone minimo ni maximo.
- En review, el intervalo final siempre se fuerza a por lo menos `1` dia.

### `settings.initial_nt`

- Default del importador: `0.015`.
- Es el `decayRate` inicial con el que se crean las tarjetas importadas.
- Influye en el primer intervalo real cuando la tarjeta entra a review.
- La UI recomienda `>= 0.000001`.

### `settings.learning_steps`

- Default del importador: `[1.0, 4.0]`.
- Se interpreta como lista de dias y admite fracciones.
- Ejemplo: `0.00694` equivale aproximadamente a `10` minutos.
- Reglas reales del parser:
  - debe ser un `List`
  - cada elemento se intenta parsear a `double`
  - los elementos `<= 0` se descartan
  - los elementos invalidos se descartan
  - si no queda ningun valor valido, se vuelve al default o al fallback
- El orden de los valores validos se conserva.

### `settings.enable_write_mode`

- Default del importador: `false`.
- Si es `true`, el modo escritura se activa solo en tarjetas de produccion
  (`*_prod`).
- No afecta a tarjetas de reconocimiento (`*_recog`).

### `settings.write_mode_threshold`

- Default del importador: `80`.
- Es el porcentaje minimo requerido para habilitar el boton "Bien" en write
  mode.
- La UI valida `0..100`, pero el importador no impone ese rango.

### `settings.write_mode_max_reps`

- Default del importador: `0`.
- Si es `0`, el write mode no tiene limite de uso por tarjeta.
- Si es `> 0`, el write mode deja de activarse para una tarjeta de produccion
  cuando `repetitionCount >= write_mode_max_reps`.
- La UI valida `0..1000000`.

## Reglas reales de conversion de tipos

### Enteros

Las claves enteras usan esta logica:

- Si el valor ya es `int`, se usa tal cual.
- Si es cualquier `num`, se convierte con `toInt()`.
- Si es `String`, se hace `int.tryParse(trimmed)`.
- Si falla, se usa el fallback.

Consecuencia importante:

- `12.9` como numero JSON puede terminar en `12`.
- `"12.9"` como string no se parsea como entero y cae al fallback.

### Decimales

Las claves decimales usan esta logica:

- Si el valor es `double`, se usa tal cual.
- Si es cualquier `num`, se convierte con `toDouble()`.
- Si es `String`, se hace `trim()` y luego se reemplaza `,` por `.` antes de
  `double.tryParse`.
- Si falla, se usa el fallback.

Esto permite usar tanto `"1.5"` como `"1,5"`.

### Booleanos

Las claves booleanas aceptan:

- `true` / `false`
- numeros: `0` es `false`, cualquier otro numero es `true`
- strings:
  - `true`
  - `false`
  - `1`
  - `0`
  - `yes`
  - `no`
  - `si`
  - `si` con tilde

Si el valor no encaja, se usa el fallback.

## Defaults exactos del importador

Si falta una clave o no se puede convertir, el importador parte de este bloque:

```json
{
  "new_card_min_correct_reps": 2,
  "new_card_intra_day_minutes": 10,
  "settings": {
    "new_cards_per_day": 20,
    "max_reviews_per_day": 200,
    "lapse_tolerance": 0,
    "use_fixed_interval_on_lapse": true,
    "lapse_fixed_interval": 1.0,
    "p_min": 0.9,
    "alpha": 0.1,
    "beta": 0.5,
    "offset": 0.0,
    "initial_nt": 0.015,
    "learning_steps": [1.0, 4.0],
    "enable_write_mode": false,
    "write_mode_threshold": 80,
    "write_mode_max_reps": 0
  }
}
```

Importante: estos defaults del importador no coinciden en todos los casos con
los defaults declarados en el modelo `DeckSettings`. Para documentar
`manifest.json`, los defaults correctos son los de esta seccion.

## Configuraciones del mazo que existen en la app pero NO se pueden fijar desde `manifest.json`

El modelo `DeckSettings` contiene mas campos, pero el importador no los lee
desde el manifiesto. Entre ellos:

- `dayCutoffHour`
- `dayCutoffMinute`
- `enableUndo`
- `studyMixMode`
- `interleaveReviewsCount`
- `interleaveNewCardsCount`
- `newCardsSeenToday`
- `lastNewCardStudyDate`
- `deckIconUri` como URI directa persistida

Si pones esas claves en `manifest.json`, hoy se ignoraran.

## Como se aplican estas configuraciones al importar

### Al crear un mazo nuevo

- Se crean `DeckSettings` nuevos usando el manifiesto.
- Si hay icono y se encuentra el archivo, se guarda como `deckIconUri`.
- Cada fila SQLite genera dos tarjetas:
  - reconocimiento: `{language_id}_recog`
  - produccion: `{language_id}_prod`
- El `initial_nt` importado se usa como `decayRate` inicial de ambas tarjetas.

### Al actualizar un mazo existente

La UI actual importa con `updateDeckSettingsFromManifest: false`. Eso implica:

- se preservan las configuraciones ya existentes del usuario
- tambien se preservan progreso y estadisticas
- el icono si puede actualizarse si el nuevo paquete trae uno valido

Solo si una importacion se ejecuta con `updateDeckSettingsFromManifest: true`,
las configuraciones del manifiesto sobreescriben las del mazo existente. Aun en
ese caso, el importador preserva:

- `newCardsSeenToday`
- `lastNewCardStudyDate`
- el icono previo si el manifiesto nuevo no resuelve un icono valido

## Recomendaciones practicas

- Pon siempre `new_card_min_correct_reps` y `new_card_intra_day_minutes` en la
  raiz.
- Usa `settings` solo para las claves realmente soportadas.
- Usa nombres exactos y consistentes para multimedia; no dependas de colisiones
  por basename o stem.
- Da extension real a todos los assets multimedia.
- Usa valores dentro de los rangos que valida la UI, aunque el importador no
  siempre los fuerce.
- No asumas que cualquier propiedad de `DeckSettings` puede venir del
  manifiesto: hoy solo se importa el subconjunto documentado aqui.

