//
//  ContentView.swift
//  Project SF
//
//  Created by Christian Privitelli on 10/7/20.
//

import SwiftUI

struct ContentView: View {

    @StateObject var hk = HealthKitController()
    @State var page = 1
    
    var body: some View {
        ZStack {
            TabView(selection: $page) {
                NavigationView {
                    ZStack {
                        VStack {
                            Text("Competitions")
                                .navigationBarTitle("Competitions")
                            if !hk.success {
                                Button("Try HealthKit Auth") {
                                    hk.authorizeHealthKit()
                                }
                            }
                            Text(hk.success ? "Successfully Authorized" : hk.processBegan ? "Something went wrong" : "")
                            if hk.success {
                                Button("Read data") {
                                    hk.updateAllActivityData()
                                }
                            }
                            if hk.processBegan && hk.success {
                                HStack {
                                    ActivityRings(hk: hk)
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text("Move: ")
                                                .bold()
                                                .foregroundColor(Color("move"))
                                            Text("\(Int(hk.moveCurrent))/\(Int(hk.moveGoal))")
                                        }
                                        HStack {
                                            Text("Exercise: ")
                                                .bold()
                                                .foregroundColor(Color("exercise"))
                                            Text("\(Int(hk.exerciseCurrent))/\(Int(hk.exerciseGoal))")
                                        }
                                        HStack {
                                            Text("Stand: ")
                                                .bold()
                                                .foregroundColor(Color("stand"))
                                            Text("\(Int(hk.standCurrent))/\(Int(hk.standGoal))")
                                        }
                                    }
                                }
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
