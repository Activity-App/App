//
//  CompetitionCell.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct CompetitionCell: View {
    
    @Binding var activityRings: ActivityRings
    let competition: Competition

    var body: some View {
        NavigationLink(
            destination: CompetitionDetail(activityRings: $activityRings, competition: competition),
            label: {
                HStack {
                    VStack {
                        PlaceBadgeView(
                            place: competition.place,
                            flippable: false,
                            activityRings: $activityRings,
                            font: .body,
                            innerPadding: 10,
                            outerPadding: 4
                        )
                        Text("\(competition.points) points")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                            .frame(minWidth: 50)
                    }
                    .padding(.horizontal, 8)
                    
                    VStack(alignment: .leading) {
                        Spacer()
                        Text(competition.endDate, style: .relative)
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                        Spacer()
                        Text(competition.name)
                            .font(.headline)
                        Spacer()
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            })
            .padding(.vertical, 8)
    }
}

//struct CompetitionCell_Previews: PreviewProvider {
//    static var previews: some View {
//        CompetitionCell(competition: Competition(name: "Test", startDate: Date(), endDate: Date()))
//            .frame(width: 200, height: 40)
//    }
//}
