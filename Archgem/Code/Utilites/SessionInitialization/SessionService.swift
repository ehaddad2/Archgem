import Foundation

class SessionService {
    static let shared = SessionService()
    private var csrfToken: String?
    private var sessionID: Int?
    public var initialized = false
    
    /*
     Fetches initialization tokens from the backend
     */
    func initializeService(){
        let api = API(to:"")
        do {
            let data = try api.makeSyncRequest("GET")
            let response = try JSONDecoder().decode(SessionResponseData.self, from: data)
            print(response.SID)
            csrfToken = response.CSRF
            sessionID = response.SID
            initialized = true
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    static func getCSRF() -> String? {
        return shared.csrfToken
    }
    
    static func getSID() -> Int? {
        return shared.sessionID
    }
}
