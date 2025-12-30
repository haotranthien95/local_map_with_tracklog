# Research: Add Map Marker

## Decisions

### 1) Local persistence via shared_preferences
- **Decision**: Store markers as a JSON-serialized list under a user-scoped key in shared_preferences.
- **Rationale**: Shared preferences already in use; zero new dependencies; small payload expected (<200 markers) with fast read/write.
- **Alternatives considered**: Hive (richer schema but adds dependency), SQLite/sqflite (overkill for key-value list), file-based JSON (more IO handling without added benefit).

### 2) Marker identity and serialization shape
- **Decision**: Use `marker_{epochMillis}` string ids; serialize fields: id, lat, lng, name, iconKey, colorHex, createdAt, updatedAt.
- **Rationale**: Deterministic and unique enough without extra packages; easy to regenerate/update in place; JSON-friendly.
- **Alternatives considered**: UUID package (avoids collision but adds dependency), composite lat/lng keys (collides on edits), random strings (harder to trace/debug).

### 3) Icon and color selection sets
- **Decision**: Provide a small predefined catalog (e.g., 5–8 icons from assets/icons and a palette of Material colors); default icon/color preselected.
- **Rationale**: Keeps UI simple and fast; avoids user-upload flows; aligns with “minimal viable” scope.
- **Alternatives considered**: Allow arbitrary image uploads (more complexity and permissions), remote icon fetch (needs backend and caching), full color wheel (slower to choose; harder to ensure contrast).

### 4) Bottom sheet flow control
- **Decision**: Single bottom sheet hosting a stepper (icon → color → name → review/create) with Back/Cancel available; maintain in-sheet state and only persist on Create.
- **Rationale**: Minimizes navigation complexity; preserves selections across steps; prevents partial saves.
- **Alternatives considered**: Multiple modal sheets (risk losing state between closes), separate screens (heavier navigation), inline floating controls (less guidance for multi-step input).

### 5) Map gesture handling with flutter_map
- **Decision**: Use `MapOptions.onLongPress` to capture coordinate, then open the bottom sheet; ensure gesture doesn’t conflict with existing tap handlers by checking map’s interaction options.
- **Rationale**: Built-in gesture callback keeps code minimal; consistent UX for long-press placement.
- **Alternatives considered**: Custom gesture detectors over the map (risk interfering with map pan/zoom), two-tap flow (slower and less discoverable).
