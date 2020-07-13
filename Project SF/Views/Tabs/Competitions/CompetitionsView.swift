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

    @EnvironmentObject var healthKit: HealthKitController
    
    // Temporary. Get these from CK when thats working.
    var competitions: [Competition] = [
        Competition(name: "Competition1", startDate: Date() - 100000, endDate: Date() + 100000),
        Competition(name: "Competition2", startDate: Date() - 100000, endDate: Date() + 30000000),
        Competition(name: "Competition3", startDate: Date() - 100000, endDate: Date() + 9900000)
    ]

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Current Activity")) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Move: \(Int(healthKit.latestActivityData.moveCurrent))/\(Int(healthKit.latestActivityData.moveGoal))")
                                .foregroundColor(RingType.move.color)
                                .fontWeight(.medium)
                            Text("Exercise: \(Int(healthKit.latestActivityData.exerciseCurrent))/\(Int(healthKit.latestActivityData.exerciseGoal))")
                                .foregroundColor(RingType.exercise.color)
                                .fontWeight(.medium)
                            Text("Stand: \(Int(healthKit.latestActivityData.standCurrent))/\(Int(healthKit.latestActivityData.standGoal))")
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
                        CompetitionCell(
                            competitionName: competitions[index].name,
                            startDate: competitions[index].startDate,
                            endDate: competitions[index].endDate
                        )
                    }
                }

                Section(header: Text("Rescent competitions")) {
                    // TODO: Rescent competitions
                    Text("Show Rescent competitions here")
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Competitions")
            .navigationBarItems(trailing: NavigationLabel(systemName: "plus", destination: CreateCompetition()))
        }
        .tabItem {
            Label("Competitions", systemImage: "star.fill")
        }

    }
}

struct CompetitionsView_Previews: PreviewProvider {
    static var previews: some View {
        CompetitionsView()
    }
}
