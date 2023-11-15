import Foundation
class LoginService {
    
    var parameters: LoginRequest
    init(_ parameters: LoginRequest) {
        self.parameters = parameters
    }
    /*
     GOAL: need to login user. if successful, store auth token in keychain and return true, else return false.
     */
    func authenticate()async->Bool {
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
    static func getAuthenticationStatus() -> Bool {
        do {
            if try (KeychainService.getEntry(id: "AuthToken".localized) != nil) {
                return true
            }
        }
        catch {
            print("Error querying for authentication token, forwarding to login page.")
        }
        return false
    }
    
}
