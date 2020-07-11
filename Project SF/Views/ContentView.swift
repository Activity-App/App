//
//  ContentView.swift
//  Project SF
//
//  Created by Christian Privitelli on 10/7/20.
//

import SwiftUI

struct ContentView: View {

    @StateObject var healthKit = HealthKitController()
    @State var page = 1

    var body: some View {
        TabView(selection: $page) {
            NavigationView {
                ZStack {
                    VStack {
                        Text("Competitions")
                            .navigationBarTitle("Competitions")
                        if !healthKit.success {
                            Button("Try HealthKit Auth") {
                                healthKit.authorizeHealthKit()
                            }
                        }
                        Text(healthKit.success ? "Successfully Authorized" :
                             healthKit.processBegan ? "Something went wrong" : "")
                        if healthKit.success {
                            Button("Read data") {
                                healthKit.updateAllActivityData()
                            }
                        }
                        if healthKit.processBegan && healthKit.success {
                            HStack {
                                ActivityRings(healthKit: healthKit)
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("Move: ")
                                            .bold()
                                            .foregroundColor(Color("move"))
                                        Text("\(Int(healthKit.moveCurrent))/\(Int(healthKit.moveGoal))")
                                    }
                                    HStack {
                                        Text("Exercise: ")
                                            .bold()
                                            .foregroundColor(Color("exercise"))
                                        Text("\(Int(healthKit.exerciseCurrent))/\(Int(healthKit.exerciseGoal))")
                                    }
                                    HStack {
                                        Text("Stand: ")
                                            .bold()
                                            .foregroundColor(Color("stand"))
                                        Text("\(Int(healthKit.standCurrent))/\(Int(healthKit.standGoal))")
                                    }
                                }
                            }
                        }
                    }
                    if healthKit.processBegan && !healthKit.success {
                        ProgressView()
                    }
                }

            }
            .tabItem {
                VStack {
                    Image(systemName: "star.fill")
                        .font(.system(size: 18))
                    Text("Competitions")
                }
            }
            .tag(1)

            NavigationView {
                Text("Teams")
                    .navigationBarTitle("Teams")
            }
            .tabItem {
                VStack {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 18))
                    Text("Teams")
                }
            }
            .tag(2)

            NavigationView {
                Text("Settings")
                    .navigationBarTitle("Settings")
            }
            .tabItem {
                VStack {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 18))
                    Text("Settings")
                }
            }
            .tag(3)
        }
        .accentColor(.init(red: 1, green: 0.4, blue: 0.4))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
