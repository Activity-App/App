//
//  ProjectSFApp.swift
//  Project SF
//
//  Created by Christian Privitelli on 10/7/20.
//
import SwiftUI

struct ProjectSFApp: App {
 
    let cloudKitStore = CloudKitStore.shared

    @AppStorage("showOnboarding") var showOnboarding = true
    @StateObject var healthKit = HealthKitController()
    @StateObject var alert = AlertManager()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showOnboarding {
                    OnboardingView(showOnboarding: $showOnboarding)
                } else {
                    ContentView()
                        .onAppear {
                            healthKit.authorizeHealthKit {
                                if healthKit.authorizationState == .granted {
                                    healthKit.updateTodaysActivityData()
                                }
                            }
                        }
                        .transition(AnyTransition.opacity.animation(.linear(duration: 1)))
                }
                AlertView()
            }
            .environmentObject(healthKit)
            .environmentObject(alert)
            .onAppear {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    UIApplication.shared.windows[0].tintColor = UserDefaults.standard.uiColor(forKey: "accentColor")
                        ?? UIColor(Color.accentColor)
                }
            }
        }
    }
}
