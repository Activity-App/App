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
                        place: 0,
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
                title: "CompetitionName",
                startDate: Date() - 100000,
                endDate: Date() + 100000
            ),
            person: CompetingPerson(name: "Me", points: 150)
        )
        .environmentObject(HealthKitController())
    }
}
