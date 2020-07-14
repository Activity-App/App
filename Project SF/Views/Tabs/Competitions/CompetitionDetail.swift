//
//  CompetitionDetail.swift
//  Project SF
//
//  Created by Christian Privitelli on 13/7/20.
//

import SwiftUI

struct CompetitionDetail: View {
    
    @EnvironmentObject var healthKit: HealthKitController
    let competition: Competition
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color(.secondarySystemBackground))
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    PlaceBadgeView(
                        place: competition.place,
                        flippable: true,
                        activityRings: $healthKit.latestActivityData
                    )
                    VStack(alignment: .leading) {
                        Text("\(competition.points) points")
                            .font(.title)
                            .fontWeight(.medium)
                        HStack(spacing: 0) {
                            Text(competition.endDate, style: .relative)
                            Text(" to go.")
                        }
                        .font(.title3)
                        .foregroundColor(Color(.tertiaryLabel))
                    }
                    Spacer()
                }
                .padding(.top)
                .padding(.horizontal)
                List {
                    ForEach(competition.people.sorted { $0.points > $1.points }) { person in
                        HStack {
                            Text("\(competition.people.sorted { $0.points > $1.points }.firstIndex(of: person)! + 1)")
                            Text(person.name)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                Spacer()
            }
            .navigationTitle(competition.name)
        }
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
                    points: 5987,
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
