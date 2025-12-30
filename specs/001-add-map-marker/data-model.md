# Data Model: Add Map Marker

## Entities

### Marker
- **Fields**: id (string), lat (double), lng (double), name (string), iconKey (string), colorHex (string), createdAt (int epoch ms), updatedAt (int epoch ms)
- **Validation**: name required (non-empty), lat/lng within valid ranges, iconKey/colorHex must be from allowed sets, id unique per user.
- **Behavior**: persists locally; render on map with icon/color; user-scoped.

### MarkerStyle
- **Fields**: iconKey (string), assetPath (string), label (string), colorHex (string optional when tied to color choices)
- **Validation**: iconKey must exist in predefined catalog; color choices limited to predefined palette ensuring sufficient contrast against map.
- **Behavior**: provides selectable options during the flow.

## Relationships
- Marker references a chosen MarkerStyle via iconKey and colorHex; no relational storage beyond simple lookups.

## Serialization
- Storage format: JSON array under a shared_preferences key, e.g., `user_{uid}_markers` or `session_markers` if anonymous.
- Example entry:
```json
{
  "id": "marker_1735526400000",
  "lat": 37.4220,
  "lng": -122.0841,
  "name": "Trailhead",
  "iconKey": "pin-default",
  "colorHex": "#FF6F00",
  "createdAt": 1735526400000,
  "updatedAt": 1735526400000
}
```

## State Transitions (per marker)
- **Draft (in-sheet)**: user selects icon/color/name; not persisted.
- **Created**: user taps Create; marker saved and rendered.
- **Updated**: future edits update fields and timestamps (not in current scope but keep timestamp for compatibility).
- **Cancelled**: user cancels flow; marker not created and no data persisted.
