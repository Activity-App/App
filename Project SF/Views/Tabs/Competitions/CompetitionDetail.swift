//
//  CompetitionDetail.swift
//  Project SF
//
//  Created by Christian Privitelli on 13/7/20.
//

import SwiftUI

struct CompetitionDetail: View {
    
    @Binding var activityRings: ActivityRings
    let competition: Competition
    
    var body: some View {
        VStack {
            HStack {
                PlaceBadgeView(
                    place: competition.place,
                    flippable: true,
                    activityRings: $activityRings
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
            .padding()
            Spacer()
        }
        .navigationTitle(competition.name)
    }
}

//struct CompetitionDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        CompetitionDetail(competition: Competition(name: "CompetitionName", startDate: Date(), endDate: Date() + 10000, place: 1))
//    }
//}
