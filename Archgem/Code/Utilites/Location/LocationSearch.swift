import MapKit

struct SearchResult: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subTitle: String
    let loc: CLLocationCoordinate2D
    
    static func == (lhs:SearchResult, rhs:SearchResult) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@Observable
class LocationSearch: NSObject, MKLocalSearchCompleterDelegate {
    
    private let completer: MKLocalSearchCompleter
    var completions = [SearchResult]()

    init(completer: MKLocalSearchCompleter) {
        self.completer = completer
        super.init()
        self.completer.delegate = self
    }

    func update(queryFragment: String) {
        completer.resultTypes = .pointOfInterest
        completer.queryFragment = queryFragment
    }

    /*
     Run through the natural lang search results and add them along w location to newCompletions as a search result
     */
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let group = DispatchGroup()
        var newCompletions = [SearchResult]()
        
        for result in completer.results {
            group.enter()
            let searchRequest = MKLocalSearch.Request()
            searchRequest.naturalLanguageQuery = result.title
            let search = MKLocalSearch(request: searchRequest)
            search.start { response, error in
                if let response = response, let mapItem = response.mapItems.first {
                    let coordinate = mapItem.placemark.coordinate
                    let searchResult = SearchResult(title: result.title, subTitle: result.subtitle, loc: coordinate)
                    newCompletions.append(searchResult)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { //once all locations found, update completion list
            self.completions = newCompletions
        }
    }
    
    func search(with query: String, coordinate: CLLocationCoordinate2D? = nil) async throws -> [SearchResult] {
        let mapKitRequest = MKLocalSearch.Request()
        mapKitRequest.naturalLanguageQuery = query
        mapKitRequest.resultTypes = .pointOfInterest

        // Use coordinate parameter if provided
        if let coordinate {
            let origin = MKMapPoint(coordinate)
            let size = MKMapSize(width: 1, height: 1)
            let mapRect = MKMapRect(origin: origin, size: size)
            mapKitRequest.region = MKCoordinateRegion(mapRect)
        }

        let search = MKLocalSearch(request: mapKitRequest)
        let response = try await search.start()

        return response.mapItems.compactMap { mapItem in
            guard let loc = mapItem.placemark.location?.coordinate else {
                // Return a default value if location is missing (or handle error as needed)
                return SearchResult(title: "", subTitle: "", loc: CLLocationCoordinate2D(latitude: 0, longitude: 0))
            }
            return SearchResult(
                title: mapItem.name ?? "",
                subTitle: mapItem.placemark.title ?? "",
                loc: loc
            )
        }
    }
}
