//
//  CompetitionsView.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct CompetitionsView: View {

    @StateObject var healthKit = HealthKitController()

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Text("Competitions")
                        .navigationBarTitle("Competitions")
                    if healthKit.authorizationState != .granted {
                        Button("Try HealthKit Auth") {
                            healthKit.authorizeHealthKit()
                        }
                    }
                    switch healthKit.authorizationState {
                    case .granted:
                        Text("Successfully Authorized")
                    case .notGranted:
                        Text("Something went wrong")
                    default:
                        Text("")
                    }
                    if healthKit.authorizationState == .granted {
                        Button("Read data") {
                            healthKit.updateAllActivityData()
                        }
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
                if healthKit.authorizationState == .processStarted {
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
    }
}

struct CompetitionsView_Previews: PreviewProvider {
    static var previews: some View {
        CompetitionsView()
    }
}
