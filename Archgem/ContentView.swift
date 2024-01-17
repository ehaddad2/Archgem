//
//  ContentView.swift
//  Archgem
//
//  Created by Elias Haddad on 6/10/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        if (LoginService.getAuthenticationStatus()) {
            HomeUIView()
        }
        else {
            LoginScreen()
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
