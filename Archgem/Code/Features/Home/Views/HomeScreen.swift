import SwiftUI
import MapKit
import CoreLocation

struct HomeUIView: View {
    @ObservedObject var viewModel = HomeViewModel()
    @State private var showingFilterPopup = false
    @State private var showingProfilePopup = false
    @State private var showingGemDialogue = false
    @State var searchText = ""
    @State private var camPosition:MapCameraPosition = .userLocation(fallback:.automatic)
    @State var displayedGems:[Gem]?
    @EnvironmentObject var locationManager:LocationManager
    @Namespace var mainMapScope
    
    private var userLoc: CLLocationCoordinate2D? {
        return locationManager.lastLocation?.coordinate
    }
    
    var body: some View {
        
        ZStack(alignment: .top) {
                        
            Map(initialPosition: camPosition, scope: mainMapScope) {
                UserAnnotation()
                if (displayedGems != nil) {
                    ForEach(displayedGems!, id:\.id) {
                        gem in
                        Annotation(gem.name, coordinate: CLLocationCoordinate2D(latitude: gem.lat, longitude: gem.long)) {
                            Image("GemPin").padding(-40)
                                .onTapGesture {
                                    self.showingGemDialogue.toggle()
                                }
                                .sheet(isPresented: $showingGemDialogue) {
                                    GemPopupView(isPresented: $showingGemDialogue, gem: gem)
                                }
                        }
                    }
                }
            }
            
            .overlay(alignment: .bottomTrailing) {
                //map tools
                VStack {
                    MapUserLocationButton(scope: mainMapScope).mapControlVisibility(.visible)
                    MapPitchToggle(scope: mainMapScope).mapControlVisibility(.visible)
                    MapCompass(scope:mainMapScope).mapControlVisibility(.visible)
                }
                .padding(.trailing, 10)
                .buttonBorderShape(.circle)
            }
            .mapScope(mainMapScope)
            
            .mapStyle(.standard(elevation: .realistic))
            
            .onMapCameraChange {//populate view area with nearby gems
                position in
                Task {
                    if let gems = await viewModel.Search(position: position.region) {
                        displayedGems = gems
                    } else {
                        
                    }
                }
            }
            
            HStack {
                // Filter Button
                Button(action: {
                    self.showingFilterPopup.toggle()
                }) {
                    Image(systemName: "line.horizontal.3.decrease.circle")
                        .foregroundColor(Color.gray).scaledToFit()
                }
                
                .padding()
                .background(Color.white.opacity(1))
                .cornerRadius(8)
                .shadow(radius: 3)
                .sheet(isPresented: $showingFilterPopup) {
                    FilterPopupView(isPresented: $showingFilterPopup)
                }
                
                Spacer()

                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Search Location or Gem", text: $searchText)
                }
                .padding(8)
                .background(Color.white.opacity(1))
                .cornerRadius(10)
                .shadow(radius: 3)
                
                Spacer()

                // Profile Button
                Button(action: {
                    self.showingProfilePopup.toggle()
                }) {
                    Image(systemName: "person.crop.circle")
                        .foregroundColor(.black)
                }
                .padding()
                .background(Color.white.opacity(1))
                .cornerRadius(8)
                .shadow(radius: 3)
                .sheet(isPresented: $showingProfilePopup) {
                    ProfilePopupView(isPresented: $showingProfilePopup)
                }
            }
            .padding(.horizontal)
            .padding([.top], 10)
        }
    }
}

struct FilterPopupView: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            Spacer()
            Text("Filter Options")
            Spacer()
            Button {
                isPresented = false
            }label: {
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
                isPresented = false
            }label: {
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
    @State var gem: Gem
    var body: some View {
        VStack {
            Spacer()
            Text(gem.description!)
            Spacer()
            Button {
                isPresented = false
            }label: {
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

struct HomeUIView_Previews: PreviewProvider {
    static var previews: some View {

        HomeUIView()
    }
}


