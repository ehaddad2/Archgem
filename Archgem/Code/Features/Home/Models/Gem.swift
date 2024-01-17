import Foundation
import UIKit
/*
 The model for a gem containing its Name,Lat,Long,Architect,etc...
 */

struct GemResponse: Decodable {
    let gems:[Gem]
}
struct Gem: Decodable {
    let id: String
    let name: String
    let lat: Double
    let long: Double
    let address: String?
    let city: String
    let country: String
    let description: String?
    let architect: String?
    let constructionYear: Int?
    let renovationYear: Int?
    let style: String?
    let imageUrl: URL?
    let website: URL?
    let type: String?
}
