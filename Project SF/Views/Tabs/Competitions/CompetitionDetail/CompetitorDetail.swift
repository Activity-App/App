//
//  CompetitorDetail.swift
//  Project SF
//
//  Created by Christian Privitelli on 16/7/20.
//

import SwiftUI

struct CompetitorDetail: View {
    
    @EnvironmentObject var healthKit: HealthKitController
    let competition: Competition
    let person: CompetingPerson
    
    var body: some View {
        List {
            Section {
                HStack {
                    PlaceBadgeView(
                        place: competition.people.sorted { $0.points > $1.points }.firstIndex(of: person)! + 1,
                        flippable: true,
                        activityRings: $healthKit.latestActivityData // TODO: Add real user activity here
                    )
                    VStack(alignment: .leading) {
                        Text("\(person.points) points")
                            .font(.title)
                            .fontWeight(.medium)
                    }
                }
                .padding(.vertical)
                .padding(.horizontal)
            }
            
            Section(header: Text("\(person.name)s Point History")) {
                PointsGraph()
                    .frame(height: 230)
            }
            
            Section {
                Button("Send friend request.") {
                    // TODO: Send friend request here.
                }
            }
        }
        .navigationTitle(person.name)
        .listStyle(InsetGroupedListStyle())
    }
}

struct CompetitorDetail_Previews: PreviewProvider {
    static var previews: some View {
        CompetitorDetail(
            competition: Competition(
                name: "CompetitionName",
                startDate: Date() - 100000,
                endDate: Date() + 100000,
                creatingUser: CompetingPerson(name: "Me", points: 150),
                people: [
                    CompetingPerson(name: "Person1", points: 100),
                    CompetingPerson(name: "Person2", points: 200),
                    CompetingPerson(name: "Person3", points: 0),
                    CompetingPerson(name: "Me", points: 150)
                ]
            ),
            person: CompetingPerson(name: "Me", points: 150)
        )
        .environmentObject(HealthKitController())
    }
}
