import SwiftUI

struct LoginScreen: View {
    
    @ObservedObject var viewModel: LoginViewModel = LoginViewModel()
    @State private var loggedIn: Bool = false
    @State private var isLoggingIn: Bool = false // State to track the login process
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                Spacer()
                
                // Username and Password fields
                VStack {
                    TextField(
                        "Username",
                        text: $viewModel.username
                    )
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.top, 20)
                    Divider()
                    
                    SecureField(
                        "Password",
                        text: $viewModel.password
                    )
                    .padding(.top, 20)
                    Divider()
                }
                Spacer()
                
                // Login Button and Loading Indicator
                if isLoggingIn {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(1.5)
                } else {
                    Button("Login") {
                        startLoginProcess()
                    }
                    .buttonStyle(BlueButtonStyle())
                }
            }
            .padding(30)
            .navigationDestination(isPresented: $loggedIn) {
                HomeUIView().navigationBarBackButtonHidden(true)
            }
        }
    }
    
    func startLoginProcess() {
        isLoggingIn = true
        Task {
            await viewModel.login()
            loggedIn = viewModel.isLoggedIn
            isLoggingIn = false
        }
    }
}

struct BlueButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.bottom, 20)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen()
    }
}
