import Foundation

struct LoginResponse: Decodable {
    let token: String
}

struct LoginValidation: Encodable {
    let token: String
}
