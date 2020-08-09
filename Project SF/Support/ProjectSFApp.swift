//
//  ProjectSFApp.swift
//  Project SF
//
//  Created by Christian Privitelli on 10/7/20.
//

import SwiftUI
import Network

struct ProjectSFApp: App {
 
    let cloudKitStore = CloudKitStore.shared

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @AppStorage("showOnboarding") var showOnboarding = true
    
    let network = NetworkManager.shared
    @StateObject var userController = UserController()
    @StateObject var friendController = FriendController()
    @StateObject var healthKit = HealthKitController()
    @StateObject var alert = AlertManager()
    
    let didBecomeActiveNotification = NotificationCenter.default.publisher(
        for: UIApplication.didBecomeActiveNotification
    )
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showOnboarding {
                    OnboardingView(showOnboarding: $showOnboarding)
                } else {
                    ContentView()
                        .transition(AnyTransition.opacity.animation(.linear(duration: 1)))
                }
                AlertView()
            }
            .environmentObject(userController)
            .environmentObject(friendController)
            .environmentObject(healthKit)
            .environmentObject(alert)
            .onAppear(perform: didFinishLaunching)
            .onReceive(didBecomeActiveNotification, perform: { _ in didBecomeActive() } )
        }
    }
    
    /// Add functions to perform when the app first launches here.
    func didFinishLaunching() {
        didBecomeActive()
        
        /// Set the accent colour.
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
            UIApplication.shared.windows[0].tintColor = UserDefaults.standard.uiColor(forKey: "accentColor")
                ?? UIColor(Color.accentColor)
        }
        
        userController.setup { error in
            if error != nil {
                alert.present(message: "A error occured and we don't know what went wrong. Check you have a working internet connection and are signed into iCloud.")
            }
        }
    }
    
    /// Add functions to perform when the app becomes active. Eg. it is closed and reopened to the foreground.
    func didBecomeActive() {
        healthKit.authorizeHealthKit {
            if healthKit.authorizationState == .granted {
                healthKit.updateTodaysActivityData()
            }
        }
        friendController.updateAll()
        checkConnection()
    }
    
    func checkConnection() {
        if network.connected {
            
        } else {
            alert.present(icon: "wifi.slash", message: "We couldn't connect you to the internet. You won't be able to see the latest competition or friend data without a connection.", buttonTitle: "Continue Anyway", buttonAction: { alert.dismiss() })
        }
    }
}
