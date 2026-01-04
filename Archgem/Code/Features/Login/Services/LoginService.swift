import Foundation
class LoginService {
    
    var parameters: LoginRequest
    init(_ parameters: LoginRequest) {
        self.parameters = parameters
    }

    func authenticate() async->Bool {
        
        let api = API(to: "/Login/")
        do {
            let data = try await api.makeAsyncRequest("POST", with: parameters)
            let responseString = String(data: data, encoding: .utf8)
                print("Received data string: \(responseString ?? "Unable to convert data to string.")")

            let response = try? JSONDecoder().decode(LoginResponse.self, from: data)
            if (response != nil) {
                let success = KeychainService.addEntry(id: "AuthToken".localized, data: response!.token)
                return true
            }
        } catch {
            print("FAILED LOGIN")
            return false
        }
        return false
    }
    
    //login if already authenticated
    static func getAuthenticationStatus() async -> Bool {
        let api = API(to: "/Login/")

        do {
            let entry = try KeychainService.getEntry(id: "AuthToken".localized)
            guard
                let dict = entry as? [String: Any],
                let data = dict[kSecValueData as String] as? Data,
                let token = String(data: data, encoding: .utf8),
                !token.isEmpty
            else { return false }

            _ = try await api.makeAsyncRequest("POST", with: LoginValidation(token: token))
            return true
        } catch {
            return false
        }
    }
}
