import Foundation
class LoginService {
    
    var parameters: LoginRequest
    init(_ parameters: LoginRequest) {
        self.parameters = parameters
        /*Task(priority:.high) {
            await SessionService.shared.initializeService()
        }*/
    }
    /*
     login user. if successful, store auth token in keychain and return true, else return false.
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
        let api = API(to: "/Login/")
        do {
            var authToken = try KeychainService.getEntry(id: "AuthToken".localized)
            if (authToken != nil) {
                if let authToken = authToken as? [String: Any],
                   let authToken = authToken[kSecValueData as String] as? Data,
                   let token = String(data: authToken, encoding: .utf8) {
                    return true
                    Task{
                        //let data = try await api.makeAsyncRequest("POST", with: LoginValidation(token:token))
                        return true
                    }
                }
            }
        }
        catch {
            print("Error querying for authentication token, forwarding to login page.")
        }
        return false
    }
    
}
