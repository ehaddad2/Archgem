//
//  ArchgemApp.swift
//  Archgem
//
//  Created by Elias Haddad on 6/10/23.
//

import SwiftUI

@main
struct ArchgemApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var locationManager = LocationManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        SessionService.shared.initializeService()
        
        return true
    }
}
