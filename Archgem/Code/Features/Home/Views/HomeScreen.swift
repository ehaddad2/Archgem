import SwiftUI
import MapKit
import CoreLocation

// 1. Define the ActiveSheet enum and conform it to Equatable
enum ActiveSheet: Identifiable, Equatable {
    case filter
    case profile
    case gem(Gem)
    case search

    var id: String {
        switch self {
        case .filter:
            return "filter"
        case .profile:
            return "profile"
        case .gem(let gem):
            return "gem-\(gem.id)"
        case .search:
            return "search"
        }
    }

    // 2. Implement Equatable conformance
    static func ==(lhs: ActiveSheet, rhs: ActiveSheet) -> Bool {
        switch (lhs, rhs) {
        case (.filter, .filter):
            return true
        case (.profile, .profile):
            return true
        case (.search, .search):
            return true
        case (.gem(let gem1), .gem(let gem2)):
            return gem1.id == gem2.id
        default:
            return false
        }
    }
}

// Ensure that Gem conforms to Equatable
extension Gem: Equatable {
    static func ==(lhs: Gem, rhs: Gem) -> Bool {
        return lhs.id == rhs.id
    }
}

struct HomeUIView: View {
    @ObservedObject var viewModel = HomeViewModel()
    @State private var searchRes: [SearchResult]?
    @State private var camPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var submittedGemQuery: String = ""
    @State var displayedGems: [Gem]?
    @EnvironmentObject var locationManager: LocationManager
    @Namespace var mainMapScope
    @State private var activeSheet: ActiveSheet? = .search // Present the search sheet by default
    @State private var currentRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090),
        span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.4)
    )

    private func performSearch(region: MKCoordinateRegion) {
        Task {
            let q = submittedGemQuery.trimmingCharacters(in: .whitespacesAndNewlines)

            if q.isEmpty {
                if let gems = await viewModel.Search(position: region) {
                    displayedGems = gems
                }
            } else {
                if let gems = await viewModel.Search(position: region, queryText: q) {
                    displayedGems = gems
                }
            }
        }
    }

    private var userLoc: CLLocationCoordinate2D? {
        return locationManager.lastLocation?.coordinate
    }
    
    private func animateCameraToLocation(coordinate: CLLocationCoordinate2D, camPosition: Binding<MapCameraPosition>) {
        // First, zoom out to give the panning effect
        withAnimation(.easeInOut(duration: 1.0)) {
            camPosition.wrappedValue = .camera(
                MapCamera(
                    centerCoordinate: coordinate,
                    distance: 5000 // Zoomed out
                )
            )
        }

        // Then, zoom back in after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 1.0)) {
                camPosition.wrappedValue = .camera(
                    MapCamera(
                        centerCoordinate: coordinate,
                        distance: 1000 // Zoomed in
                    )
                )
            }
        }
    }
    var body: some View {

        ZStack(alignment: .top) {

            Map(position: $camPosition, scope: mainMapScope) {
                UserAnnotation()
                if let gems = displayedGems {
                    ForEach(gems, id: \.id) { gem in
                        Annotation(gem.name, coordinate: CLLocationCoordinate2D(latitude: gem.lat, longitude: gem.long)) {
                            Image("GemPin")
                                .padding(-40)
                                .onTapGesture {
                                    // 4. Set activeSheet to .gem when a gem is tapped
                                    self.activeSheet = .gem(gem)
                                }
                        }
                    }
                }
            }
            .ignoresSafeArea()
            .overlay(alignment: .topTrailing) {
                // Map tools
                VStack {
                    MapUserLocationButton(scope: mainMapScope)
                    MapPitchToggle(scope: mainMapScope).mapControlVisibility(.visible)
                    MapCompass(scope: mainMapScope).mapControlVisibility(.visible)
                }
                .padding(.horizontal, 17)
                .padding(.top, 80)
                .buttonBorderShape(.circle)
            }
            .mapScope(mainMapScope)
            .mapStyle(.standard(elevation: .realistic))
            
            .onAppear {
                if let loc = userLoc {
                    let region = MKCoordinateRegion(
                        center: loc,
                        span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.4)
                    )
                    currentRegion = region
                    camPosition = .region(region)
                }

                performSearch(region: currentRegion)
            }
            .onMapCameraChange { position in
                currentRegion = position.region
                performSearch(region: position.region)
            }
            .onChange(of: submittedGemQuery) { _, _ in
                performSearch(region: currentRegion)
            }

            HStack(alignment: .top) {
                // Filter Button
                Button(action: {
                    // 5. Set activeSheet to .filter when filter button is tapped
                    self.activeSheet = .filter
                }) {
                    Image(systemName: "line.horizontal.3.decrease.circle")
                        .foregroundColor(Color.gray)
                }
                .padding()
                .background(Color.white.opacity(1))
                .cornerRadius(8)
                .shadow(radius: 3)

                Spacer()

                // Profile Button
                Button(action: {
                    // 6. Set activeSheet to .profile when profile button is tapped
                    self.activeSheet = .profile
                }) {
                    Image(systemName: "person.crop.circle")
                        .foregroundColor(.black)
                }
                .padding()
                .background(Color.white.opacity(1))
                .cornerRadius(8)
                .shadow(radius: 3)
            }
            .padding(.horizontal)
        }
        // 7. Attach a single .sheet modifier to present sheets based on activeSheet
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .filter:
                FilterPopupView(isPresented: Binding(
                    get: { self.activeSheet == .filter },
                    set: { _ in self.activeSheet = .search }
                ))
            case .profile:
                ProfilePopupView(isPresented: Binding(
                    get: { self.activeSheet == .profile },
                    set: { _ in self.activeSheet = .search }
                ))
            case .gem(let gem):
                GemPopupView(isPresented: Binding(
                    get: { self.activeSheet == .gem(gem) },
                    set: { _ in self.activeSheet = .search }
                ), gem: gem)
            case .search:
                
                SearchSheet(
                    searchResults: $searchRes,
                    onLocationSelected: { coordinate in
                        animateCameraToLocation(coordinate: coordinate.loc, camPosition: $camPosition)
                    },
                    onGemQueryChanged: { q in
                        submittedGemQuery = q
                    }
                )

                
                }
                    
            }
        }
    }

// 8. Modify your popup views to work with the new presentation logic
struct FilterPopupView: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            Spacer()
            Text("Filter Options")
            Spacer()
            Button {
                isPresented = false // This will dismiss the sheet
            } label: {
                Text("Cancel")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct ProfilePopupView: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            Spacer()
            Text("Profile Options")
            Spacer()
            Button {
                isPresented = false // This will dismiss the sheet
            } label: {
                Text("Cancel")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct GemPopupView: View {
    @Binding var isPresented: Bool
    var gem: Gem

    var body: some View {
        VStack {
            Spacer()
            Text(gem.description ?? "")
            Spacer()
            Button {
                isPresented = false // This will dismiss the sheet
            } label: {
                Text("Cancel")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

// Your existing SearchSheet remains unchanged and is in a separate file

struct HomeUIView_Previews: PreviewProvider {
    static var previews: some View {
        HomeUIView()
    }
}
