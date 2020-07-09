//
//  ContentView.swift
//  Project SF
//
//  Created by Christian Privitelli on 10/7/20.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var hk = HealthKitController()
    @State var page = 2
    
    var body: some View {
        ZStack {
            TabView(selection: $page) {
                NavigationView {
                    ZStack {
                        VStack {
                            Text("Competitions")
                                .navigationBarTitle("Competitions")
                            Button("Try HealthKit Auth") {
                                hk.authorizeHealthKit()
                            }
                            Text(hk.success ? "Successfully Authorized" : hk.processBegan ? "Something went wrong" : "")
                            
                            Button("Read data") {
                                hk.readHealthData()
                            }
                        }
                        if hk.processBegan && !hk.success {
                            ProgressView()
                        }
                    }
                    
                }
                .tag(1)

                NavigationView {
                    Text("Teams")
                        .navigationBarTitle("Teams")
                }
                .tag(2)
                
                NavigationView {
                    Text("Settings")
                        .navigationBarTitle("Settings")
                }
                .tag(3)
            }
            .accentColor(.init(red: 1, green: 0.4, blue: 0.4))
            
            TabBar(page: $page)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
