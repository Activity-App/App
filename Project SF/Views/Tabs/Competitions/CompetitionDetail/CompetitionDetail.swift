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
                    place: 0,
                    flippable: true,
                    activityRings: $healthKit.latestActivityData
                )
                VStack(alignment: .leading) {
                    Text("0 points")
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
            
            Section(header: Text("Point Summary")) {
                HStack {
                    Spacer()
                    Group {
                        pointsSummary(type: .move, points: 93)
                        Spacer()
                        pointsSummary(type: .exercise, points: 24)
                        Spacer()
                        pointsSummary(type: .stand, points: 5)
                        Spacer()
                        pointsSummary(type: .steps, points: 20)
                        Spacer()
                        pointsSummary(type: .distance, points: 8)
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
            }
            
//            Section(header: Text("Leaderboard")) {
//                ForEach(competition.people.sorted { $0.points > $1.points }) { person in
//                    CompetitorCell(competition: competition, person: person)
//                }
//            }
            Section(header: Text("Your Points History")) {
                PointsGraph()
                    .frame(height: 220)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(competition.title)
    }
    
    func pointsSummary(type: CompetitionType, points: Int) -> some View {
        VStack {
            if type == .move || type == .exercise || type == .stand {
                ActivityRingView(
                    ringType: RingType(rawValue: type.rawValue)!,
                    ringWidth: 4,
                    current: .constant(200),
                    goal: .constant(300)
                )
                .frame(width: 20, height: 20)
            } else {
                Image(systemName: type == .steps ? "figure.walk" : "chevron.right.2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            }
            Text(type.rawValue.capitalized)
                .font(.caption2)
            Text("\(points)")
                .fontWeight(.heavy)
                .padding(.top, 4)
        }
    }
}

//struct CompetitionDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            CompetitionDetail(
//                competition: Competition(
//                    title: "CompetitionName",
//                    startDate: Date() - 100000,
//                    endDate: Date() + 100000
//                )
//            )
//            .environmentObject(HealthKitController())
//        }
//    }
//}
