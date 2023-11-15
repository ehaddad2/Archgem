import SwiftUI
import MapKit

struct HomeUIView: View {
    @State private var showingFilterPopup = false
    @State private var showingProfilePopup = false
    @State private var searchText = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060), // Example coordinates for New York
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    var body: some View {
        ZStack(alignment: .top) {
            // Map View
            Map(coordinateRegion: $region)
                .edgesIgnoringSafeArea(.all)
                
            // Top UI Elements
            HStack {
                
                // Filter Button
                Button(action: {
                    self.showingFilterPopup.toggle()
                }) {
                    Image(systemName: "line.horizontal.3.decrease.circle")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white.opacity(1))
                .cornerRadius(8)
                .shadow(radius: 3)
                .sheet(isPresented: $showingFilterPopup) {
                    FilterPopupView()
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
                    ProfilePopupView()
                }
            }
            .padding(.horizontal)
            .padding([.top], 10)
        }
    }
}

struct FilterPopupView: View {
    var body: some View {
        Text("Filter Options")
            // Add your filter options here
    }
}

struct ProfilePopupView: View {
    var body: some View {
        Text("Profile Information")
            // Add your profile information here
    }
}

struct HomeUIView_Previews: PreviewProvider {
    static var previews: some View {
        HomeUIView()
    }
}
