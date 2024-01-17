import Foundation
import CoreLocation
import MapKit

class HomeViewModel: ObservableObject {
    var service:HomeService
    
    init() {
        service = HomeService()
    }
    
    /*
     Summary: retrieve a list of gems
     Params: all optional
     Ret: [Gem]?
     */
    func Search(position: MKCoordinateRegion? = nil, queryText:String = "") async -> [Gem]? {
        guard let pos = position else {
            let params = GemQuery(startsWith: queryText)
            return await service.searchGems(params:params)
        }
        
        let centerLat = pos.center.latitude
        let centerLong = pos.center.longitude
        let spanDeltaLat = pos.span.latitudeDelta
        let spanDeltaLong = pos.span.longitudeDelta
        let params = GemQuery(centerLat: centerLat, centerLong: centerLong, spanDeltaLat: spanDeltaLat, spanDeltaLong: spanDeltaLong, startsWith: queryText)
        
        return await service.searchGems(params: params)
    }
}
    

