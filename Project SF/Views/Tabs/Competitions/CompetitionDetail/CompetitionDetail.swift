//
//  CompetitionDetail.swift
//  Project SF
//
//  Created by Christian Privitelli on 13/7/20.
//

import SwiftUI

struct CompetitionDetail: View {
    
    @EnvironmentObject var healthKit: HealthKitController
    @Environment(\.colorScheme) var colorScheme
    let competition: Competition
    
    var body: some View {
        List {
            HStack {
                PlaceBadgeView(
                    place: competition.place,
                    flippable: true,
                    activityRings: $healthKit.latestActivityData
                )
                VStack(alignment: .leading) {
                    Text("\(competition.creatingUser.points) points")
                        .font(.title)
                        .fontWeight(.medium)
                    HStack(spacing: 0) {
                        Text(competition.endDate, style: .relative)
                        Text(" to go.")
                    }
                    .font(.title3)
                    .foregroundColor(Color(.tertiaryLabel))
                }
            }
            .padding(.vertical)
            .padding(.horizontal)
            
            Section(header: Text("Leaderboard")) {
                ForEach(competition.people.sorted { $0.points > $1.points }) { person in
                    CompetitorCell(competition: competition, person: person)
                }
            }
            Section(header: Text("Your Points History")) {
                PointsGraph()
                    .frame(height: 220)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(competition.name)
    }
}

struct CompetitionDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CompetitionDetail(
                competition: Competition(
                    name: "CompetitionName",
                    startDate: Date() - 100000,
                    endDate: Date() + 100000,
                    creatingUser: CompetingPerson(name: "Me", points: 150),
                    people: [
                        CompetingPerson(name: "Person1", points: 100),
                        CompetingPerson(name: "Person2", points: 200),
                        CompetingPerson(name: "Person3", points: 0)
                    ]
                )
            )
            .environmentObject(HealthKitController())
        }
    }
}
