import Foundation

struct SessionResponseData: Decodable {
    let SID: Int
    let CSRF: String
}
