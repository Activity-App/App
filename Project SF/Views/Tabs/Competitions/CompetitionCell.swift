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
                        Text("\(competition.endDate, style: .relative) \(competition.endDate < Date() ? "ago" : "")")
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

    init(_ competition: Competition, activityRings: Binding<ActivityRings>) {
        self.competition = competition
        self._activityRings = activityRings
    }
}

struct CompetitionCell_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let activity = ActivityRings(
            moveCurrent: 350,
            moveGoal: 300,
            exerciseCurrent: 4,
            exerciseGoal: 30,
            standCurrent: 1,
            standGoal: 12
        )
        
        return CompetitionCell(Competition(name: "Test", startDate: Date(), endDate: Date()), activityRings: .constant(activity))
            .frame(width: 200, height: 40)
    }
}
