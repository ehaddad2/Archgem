# Archgem (iOS)

![UML Diagram](uml.png)

iOS client for Archgem. Built with SwiftUI + MVVM. Primary features:
- Login (Django session + token persisted in Keychain)
- Map-based discovery of landmarks (“Gems”)
- Location search using MapKit (autocomplete + POI results)

## Architecture (high level)
- **SwiftUI Views**
  - `ContentView`: decides whether to show `LoginScreen` or `HomeUIView`
  - `LoginScreen`: username/password UI
  - `HomeUIView`: Map UI + filter/profile/gem sheets + search sheet
  - `SearchSheet`: MapKit-driven location/POI search

- **ViewModels**
  - `LoginViewModel`: triggers login, tracks `isLoggedIn`
  - `HomeViewModel`: queries backend for nearby gems using map region and/or text prefix

- **Services**
  - `SessionService`: initialization step; fetches CSRF token and session info from backend root (`GET /`)
  - `API`: low-level request builder for GET/POST/PUT/DELETE using `URLSession`
  - `LoginService`: `POST /Login/` (username/password) and token validation
  - `HomeService`: `POST /Home/Search/` for gem discovery

- **Utilities**
  - `KeychainService`: stores `AuthToken` securely
  - `LocationManager`: CoreLocation updates
  - `LocationSearch`: MKLocalSearchCompleter + MKLocalSearch for autocomplete results with coordinates
  - `String.localized`: localization-backed config and UI strings

## Backend connectivity (Host/Port/Protocol)
The app reads backend connection values from localization keys:

`Code/SupportingFiles/Localization/en.lproj/Localizable.strings`
```text
"Protocol" = "HTTP";
"Host" = "127.0.0.1";
"Port" = 8000;
