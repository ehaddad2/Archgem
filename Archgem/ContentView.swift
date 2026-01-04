import SwiftUI

struct ContentView: View {
    @State private var isAuthed: Bool? = nil

    var body: some View {
        Group {
            if let isAuthed = isAuthed {
                if isAuthed {
                    HomeUIView()
                } else {
                    LoginScreen()
                }
            } else {
                ProgressView()
            }
        }
        .task {
            isAuthed = await LoginService.getAuthenticationStatus()
        }
    }
}
