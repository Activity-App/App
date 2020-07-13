//
//  CompetitionsView.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct Competition: Identifiable {
    var id = UUID()
    var name: String
    var startDate: Date
    var endDate: Date
    var points: Int = 0
    var place: Int = 1
}

struct CompetitionsView: View {

    @EnvironmentObject var healthKit: HealthKitController
    @State var showCreateCompetition = false
    
    // Temporary. Get these from CK when thats working.
    var competitions: [Competition] = [
        Competition(name: "Competition1", startDate: Date() - 100000, endDate: Date() + 100000, points: 5987, place: 1),
        Competition(name: "Competition2", startDate: Date() - 100000, endDate: Date() + 30000000, place: 2),
        Competition(name: "Competition3", startDate: Date() - 100000, endDate: Date() + 9900000, points: 3091, place: 3),
        Competition(name: "Competition3", startDate: Date() - 100000, endDate: Date() + 9900000, place: 9)
    ]

    var recentCompetitions: [Competition] = [
        Competition(name: "Competition1", startDate: Date() - 100000, endDate: Date() - 1000),
        Competition(name: "Competition2", startDate: Date() - 1000000, endDate: Date() - 10000),
        Competition(name: "Competition3", startDate: Date() - 100000, endDate: Date() - 12345)
    ]

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Current Activity")) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Move: \(healthKit.latestActivityData.moveFraction)")
                                .foregroundColor(RingType.move.color)
                                .fontWeight(.medium)
                            Text("Exercise: \(healthKit.latestActivityData.exerciseFraction)")
                                .foregroundColor(RingType.exercise.color)
                                .fontWeight(.medium)
                            Text("Stand: \(healthKit.latestActivityData.standFraction)")
                                .foregroundColor(RingType.stand.darkColor)
                                .fontWeight(.medium)
                        }
                        Spacer()
                        ActivityRingsView(values: $healthKit.latestActivityData, ringSize: .medium)
                            .padding(.vertical, 12)
                    }
                }

                Section(header: Text("Currently Competing")) {
                    ForEach(competitions.indices) { index in
                        CompetitionCell(competitions[index])
                    }
                }

                Section(header: Text("Recent competitions")) {
                    ForEach(recentCompetitions.indices) { index in
                        CompetitionCell(competitions[index])
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Competitions")
            .navigationBarItems(
                trailing: NavigationButton(
                    systemName: "plus",
                    action: { showCreateCompetition = true }
                )
            )
        }
        .tabItem {
            Label("Competitions", systemImage: "star.fill")
        }
        .sheet(isPresented: $showCreateCompetition) {
            CreateCompetition()
        }

    }
}

struct CompetitionsView_Previews: PreviewProvider {
    static var previews: some View {
        CompetitionsView()
    }
}
