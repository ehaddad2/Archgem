import Foundation
import CoreLocation
/*
 The model for a query for a Gem sent to the backend with Lat and Long as parameters
 */
struct GemQuery: Encodable {
    let centerLat: CLLocationDegrees?
    let centerLong: CLLocationDegrees?
    let spanDeltaLat: CLLocationDegrees?
    let spanDeltaLong: CLLocationDegrees?
    let startsWith: String?
    
    init(centerLat: CLLocationDegrees? = 0, centerLong: CLLocationDegrees? = 0, spanDeltaLat: CLLocationDegrees? = Double.infinity, spanDeltaLong: CLLocationDegrees? = Double.infinity, startsWith: String = "") {
        self.centerLat = centerLat
        self.centerLong = centerLong
        self.spanDeltaLat = spanDeltaLat
        self.spanDeltaLong = spanDeltaLong
        self.startsWith = startsWith
    }
}
