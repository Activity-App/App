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

struct CurrentlyCompetingHeader: View {
    var index: Int
    var body: some View {
        if index == 0 {
            return AnyView(Text("Currently Competing"))
        } else {
            return AnyView(EmptyView())
        }
    }
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
                            Text("Move: \(Int(healthKit.moveCurrent))/\(Int(healthKit.moveGoal))")
                                .foregroundColor(RingType.move.color)
                                .fontWeight(.medium)
                            Text("Exercise: \(Int(healthKit.exerciseCurrent))/\(Int(healthKit.exerciseGoal))")
                                .foregroundColor(RingType.exercise.color)
                                .fontWeight(.medium)
                            Text("Stand: \(Int(healthKit.standCurrent))/\(Int(healthKit.standGoal))")
                                .foregroundColor(RingType.stand.darkColor)
                                .fontWeight(.medium)
                        }
                        Spacer()
                        ActivityRingsView(ringSize: .small)
                            .padding(.vertical, 12)
                    }
                }
                ForEach(competitions.indices) { index in
                    Section(header: CurrentlyCompetingHeader(index: index)) {
                        CompetitionCell(
                            competitionName: competitions[index].name,
                            startDate: competitions[index].startDate,
                            endDate: competitions[index].endDate
                        )
                    }
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
