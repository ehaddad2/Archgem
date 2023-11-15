import Foundation

class LoginViewModel: ObservableObject {

    //dynamically updated
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoggedIn: Bool = false
/*
 The login() function will have two main tasks: to send an API request to the server via the LoginAction, and to navigate the user to the home screen if the request succeeds.
 */
    func login() async {
        let req = LoginRequest(username:username, password: password)
        
        if await LoginService(req).authenticate() {
            DispatchQueue.main.async {
                self.isLoggedIn = true
                print("Logged In")
            }
            
        }
        else {
            DispatchQueue.main.async {
                print("UNSUCCESSFUL LOGIN")
            }
        }
        
    }
}
