# QU Bus Tracker

A Flutter app for Qatar University students to track campus buses in real-time and find the best routes to their destinations.

## Features

🗺️ **Campus Map Integration**
- Google Maps focused on QU campus
- Real-time location display
- Interactive campus landmarks

🚌 **Bus Tracking**
- Live bus locations on map
- Multiple bus routes (Academic Loop, Student Life, Campus Express)
- Real-time arrival predictions
- Bus status indicators (Running, Delayed, Stopped)

📍 **Destination Selection**
- Easy-to-use destination picker
- Categorized campus locations
- Search functionality
- Route recommendations

## Setup Instructions

### 1. Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable the following APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Places API (optional, for future features)
4. Create credentials (API Key)
5. Restrict the API key to your app's package name

### 2. Configure API Key

Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` in these files:

**Android:**
- `android/app/src/main/AndroidManifest.xml` (line 46)

**iOS:**
- `ios/Runner/Info.plist` (line 57)

**Web:**
- set `GOOGLE_MAPS_API_KEY` at deploy time (see step 5); the fallback used when
  it is unset lives in `lib/google_maps_web_loader.dart`

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run the App

```bash
flutter run
```

### 5. Deploy the Web App

The web build needs two things the native builds get for free:

- `CONVEX_URL` (baked in with `--dart-define`, defaults to the shared
  deployment in `lib/convex_config.dart`)
- a **browser** Google Maps JavaScript API key

**Vercel** — set the project root directory to `qu_bus_tracker` and add these
project environment variables:

- `CONVEX_URL`: the Convex deployment URL
- `GOOGLE_MAPS_API_KEY`: a browser-restricted Google Maps JavaScript API key
  (Maps JavaScript API enabled, HTTP referrers restricted to the deployed
  domains). If this variable is missing the deployment falls back to the key
  compiled into `lib/google_maps_web_loader.dart`.

`scripts/vercel-build.sh` downloads the pinned Flutter toolchain, runs
`flutter pub get`, builds with both dart-defines, substitutes the Maps key in
`build/web/index.html`, and fails the build if the `__GOOGLE_MAPS_API_KEY__`
placeholder survives.

**Any other host** (GitHub Pages, Netlify drop, static file upload, …) — one
command is enough, no placeholder substitution required:

```bash
flutter build web --release \
  --dart-define=CONVEX_URL=https://your-deployment.convex.cloud \
  --dart-define=GOOGLE_MAPS_API_KEY=your-browser-maps-key
```

Then upload `build/web`. `lib/google_maps_web_loader.dart` injects the Maps
JavaScript API at startup whenever `index.html` did not already load it, so the
map — and therefore every live-bus ETA popup — works on any deploy path. If the
map still cannot start, the map area says why (missing key, key rejected for the
domain, or API unreachable) instead of failing silently.

## App Structure

```
lib/
├── config/
│   └── maps_config.dart          # Maps configuration
├── models/
│   └── bus_models.dart           # Data models for buses, routes, stops
├── screens/
│   ├── home_screen.dart          # Main map screen
│   ├── destination_selection_screen.dart  # Destination picker
│   └── bus_details_screen.dart   # Route details and bus info
└── services/
    ├── bus_service.dart          # Bus data management
    └── location_service.dart     # Location utilities
```

## Campus Locations

The app includes these QU campus locations:

### Academic Buildings
- Library
- Engineering Building
- Business Building
- Science Building
- Medicine Building
- Arts Building

### Student Life
- Student Center
- Sports Complex
- Cafeteria
- Bookstore

### Housing
- Dormitories
- Faculty Housing

### Administrative
- Main Gate
- Administration Building
- Health Center
- Parking Area

## Bus Routes

### Route 1 - Academic Loop
- Main Gate → Engineering → Science → Library
- Color: Orange
- Duration: ~15 minutes

### Route 2 - Student Life
- Main Gate → Student Center → Business → Sports
- Color: Blue
- Duration: ~12 minutes

### Route 3 - Campus Express
- Library → Science → Student Center → Sports → Dormitories
- Color: Green
- Duration: ~18 minutes

## Mock Data

The app currently uses mock data for demonstration purposes. In a real implementation, this would connect to:

- University bus tracking system
- GPS devices on buses
- Real-time transit APIs
- Student information system

## Future Enhancements

- [ ] Real-time GPS tracking integration
- [ ] Push notifications for bus arrivals
- [ ] Favorite routes and locations
- [ ] Offline map support
- [ ] Accessibility features
- [ ] Multi-language support
- [ ] Integration with university systems
- [ ] Crowdsourced bus status updates

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support or questions, please contact the development team or create an issue in the repository.

---

**Note:** This is a demonstration app for Qatar University. For production use, integrate with real bus tracking systems and university APIs.