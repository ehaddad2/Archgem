/*
 API service supporting GET, POST, PUT, DELETE
 */

import Foundation

class API {
    var baseURLComp:URLComponents = URLComponents()
    var encoder = JSONEncoder()
    
    init (to path: String) {
        //configure url
        self.baseURLComp.path = path
        self.baseURLComp.port = Int("Port".localized) ?? 80
        self.baseURLComp.host = "Host".localized
        self.baseURLComp.scheme = "Protocol".localized
    }
    
    func makeSyncRequest(_ method: String, endpoint: String = "", queryParams: [String: String] = [:], with parameters: Encodable? = nil) throws -> Data{
        guard let url = baseURLComp.url else {
            throw NSError()
        }
        let urlFinal = url.appendingPathComponent(endpoint)
        var request = URLRequest(url: urlFinal)
        
        if let parameters = parameters {
            do {
                request.httpBody = try encoder.encode(parameters)
            }
            catch {
                //can't encode request parameters
            }
        }
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        switch method {
        case "GET":
            // Handle GET request
            print("Handling GET request")
        case "POST":
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            // Handle POST request
            print("Handling POST request")
        case "PUT":
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            // Handle PUT request
            print("Handling PUT request")
        case "DELETE":
            // Handle DELETE request
            print("Handling DELETE request")
        default:
            // Handle unsupported or unknown methods
            print("Unsupported HTTP method")
        }
        
        //TODO: error handling
        let data = try Data(contentsOf: url)

        return data
    }
    
    func makeAsyncRequest(_ method: String, endpoint: String = "", queryParams: [String: String] = [:], with parameters: Encodable? = nil) async throws -> Data{
        guard let url = baseURLComp.url else {
            throw NSError()
        }
        let urlFinal = url.appendingPathComponent(endpoint)
        var request = URLRequest(url: urlFinal)
        
        if let parameters = parameters {
            do {
                request.httpBody = try encoder.encode(parameters)
            }
            catch {
                //can't encode request parameters
            }
        }
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        switch method {
        case "GET":
            // Handle GET request
            print("Handling GET request")
        case "POST":
            if (!SessionService.shared.initialized) {
                NSException(name:NSExceptionName(rawValue:"uninitialized session"), reason:"The current session has not been initialized, no CSRF token present", userInfo: nil).raise()
            }
            else {
                request.addValue(SessionService.getCSRF()!, forHTTPHeaderField: "X-CSRFToken")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            // Handle POST request
            print("Handling POST request")
        case "PUT":
            if (!SessionService.shared.initialized) {
                NSException(name:NSExceptionName(rawValue:"uninitialized session"), reason:"The current session has not been initialized, no CSRF token present", userInfo: nil).raise()
            }
            else {
                request.addValue(SessionService.getCSRF()!, forHTTPHeaderField: "X-CSRFToken")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            // Handle PUT request
            print("Handling PUT request")
        case "DELETE":
            // Handle DELETE request
            print("Handling DELETE request")
        default:
            // Handle unsupported or unknown methods
            print("Unsupported HTTP method")
        }
        
        let (data,response) = try await URLSession.shared.data(for:request)
        
        guard let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200 else {
            print("ERROR")
            throw NSError()
        }
        return data
    }
}


