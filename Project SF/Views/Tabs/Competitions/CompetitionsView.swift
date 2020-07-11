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
            Text("Currently Competing")
        } else {
            EmptyView()
        }
    }
}

struct CompetitionsView: View {

    @StateObject var healthKit = HealthKitController()
    
    // Temporary. Get these from CK when thats working.
    var competitions: [Competition] = [
        Competition(name: "Competition1", startDate: Date() - 100000, endDate: Date() + 100000),
        Competition(name: "Competition2", startDate: Date() - 100000, endDate: Date() + 30000000),
        Competition(name: "Competition3", startDate: Date() - 100000, endDate: Date() + 9900000)
    ]

    var body: some View {
        NavigationView {
            List {
                ForEach(competitions.indices) { index in
                    Section(header: CurrentlyCompetingHeader(index: index)) {
                        CompetitionCell(
                            competitionName: competitions[index].name,
                            startDate: competitions[index].startDate,
                            endDate: competitions[index].endDate,
                            healthKit: healthKit
                        )
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Competitions")
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
