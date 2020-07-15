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
}

struct CompetitionsView: View {

    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var healthKit: HealthKitController
    @State var showCreateCompetition = false
    
    // Temporary. Get these from CK when thats working.
    var competitions: [Competition] = [
        Competition(name: "Competition1", startDate: Date() - 100000, endDate: Date() + 100000),
        Competition(name: "Competition2", startDate: Date() - 100000, endDate: Date() + 30000000),
        Competition(name: "Competition3", startDate: Date() - 100000, endDate: Date() + 9900000)
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
                    ActivityOverview(activity: healthKit.latestActivityData)
                }

                Section(header: Text("Currently Competing")) {
                    ForEach(competitions.indices) { index in
                        CompetitionCell(
                            competitionName: competitions[index].name,
                            startDate: competitions[index].startDate,
                            endDate: competitions[index].endDate
                        )
                    }
                }

                Section(header: Text("Recent competitions")) {
                    ForEach(recentCompetitions.indices) { index in
                        CompetitionCell(competitionName: recentCompetitions[index].name,
                                        startDate: recentCompetitions[index].startDate,
                                        endDate: recentCompetitions[index].endDate)
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
