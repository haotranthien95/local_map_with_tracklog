# Data Model: Show Current Location or Default

## Entities

### UserLocation
- latitude: double
- longitude: double
- accuracy: double (optional)
- timestamp: DateTime (optional)

### LastKnownLocation
- latitude: double
- longitude: double
- timestamp: DateTime
- isCached: boolean = true

### DefaultLocation
- latitude: double = 10.7769
- longitude: double = 106.7009
- label: String = "Ho Chi Minh City"

### PermissionStatus
- status: enum { granted, denied, notDetermined }

## Relationships
- Map screen always displays one of: UserLocation, LastKnownLocation, or DefaultLocation
- PermissionStatus and device availability determine which location is shown

## Validation Rules
- If PermissionStatus == granted and UserLocation available, show UserLocation with blue marker and "Your location" banner
- If PermissionStatus == granted but UserLocation unavailable, show LastKnownLocation (if exists) with blue marker and "Last known location" banner
- If LastKnownLocation unavailable, show DefaultLocation with red marker and "Default location: Ho Chi Minh City" banner
- If PermissionStatus != granted, show DefaultLocation with red marker and "Default location: Ho Chi Minh City" banner
- Always display a marker at the shown location
- Always display a banner indicating which location type is shown

## Visual Indicators
- Blue marker: User location (current or last known)
- Red marker: Default location (Ho Chi Minh City)
- Banner at bottom: Text message indicating location type
