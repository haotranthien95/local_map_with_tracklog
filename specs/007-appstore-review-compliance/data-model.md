# Data Model: App Store Review Compliance

This feature does not introduce a backend data model. It adds a small amount of local state to support compliance UX (privacy link, permission flows) and the profile photo feature.

## Entities

### 1) ProfilePhoto

Represents the user-selected profile picture stored on-device.

**Fields**
- `localPath` (String, required): Absolute/relative path to the stored image file inside app sandbox.
- `updatedAt` (DateTime, required): Last update timestamp.
- `source` (enum, required): `photoLibrary` (MVP scope).

**Validation rules**
- `localPath` must point to a file within app sandbox.
- File must exist when rendering; if missing, fall back to default avatar and clear stored reference.

**Lifecycle/state transitions**
- `unset` → `set` when user successfully selects and saves an image.
- `set` → `unset` when user removes the image (optional; can be a follow-up if not required).
- `set` → `set` when user selects a new image.

---

### 2) AppDisclosureLinks

Represents legal/help links surfaced in Settings.

**Fields**
- `privacyPolicyUrl` (String, required): Must be HTTPS.

**Validation rules**
- Must be a valid HTTPS URL.

---

### 3) PermissionState (derived, not persisted)

Represents current OS permission states used to decide UI and prompts.

**Fields (derived at runtime)**
- `locationStatus` (platform enum): e.g., denied/whileInUse/disabled.
- `photoLibraryStatus` (platform enum): depends on picker implementation.

**Rules**
- Do not block core navigation when denied.
- Provide guidance to re-enable via OS Settings.

## Storage

- `ProfilePhoto.localPath`: stored in `SharedPreferences` (string) and the image file stored under app documents/application support directory.
- `ProfilePhoto.updatedAt`: stored in `SharedPreferences` (string/epoch) or inferred from file metadata.

## Relationships

- Authenticated user → optional `ProfilePhoto` (local-only; not tied to remote user record).
