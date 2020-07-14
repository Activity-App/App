//
//  CompetitionCell.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct CompetitionCell: View {
    
    let activity = ActivityRings(
        moveCurrent: 350,
        moveGoal: 300,
        exerciseCurrent: 4,
        exerciseGoal: 30,
        standCurrent: 1,
        standGoal: 12
    )
    let competition: Competition

    var body: some View {
        NavigationLink(
            destination: CompetitionDetail(competition: competition),
            label: {
                HStack {
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
                    VStack {
                        PlaceBadgeView(
                            place: competition.place,
                            flippable: false,
                            activityRings: .constant(activity),
                            font: .body,
                            innerPadding: 10,
                            outerPadding: 4
                        )
                        Text("\(competition.points) points")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                            .frame(minWidth: 50)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(width: 85)
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
                    .frame(width: 100)
//                    .padding(.horizontal, 8)
                }
            })
            .padding(.vertical, 8)
    }

    init(_ competition: Competition) {
        self.competition = competition
    }
}

struct CompetitionCell_Previews: PreviewProvider {
    
    static var previews: some View {

//        let activity = ActivityRings(
//            moveCurrent: 350,
//            moveGoal: 300,
//            exerciseCurrent: 4,
//            exerciseGoal: 30,
//            standCurrent: 1,
//            standGoal: 12
//        )
        
        let competitions: [Competition] = [
            Competition(name: "Competition1",
                        startDate: Date() - 100000, endDate: Date() + 100000,
                        points: 5987, place: 1),
            Competition(name: "Competition2",
                        startDate: Date() - 100000, endDate: Date() + 30000000,
                        place: 2)
        ]

        return VStack(spacing: 32) {
            CompetitionCell(competitions[0])
//                .frame(width: 500, height: 40)
//
//            CompetitionCell(competitions[1])
//                .frame(width: 500, height: 40)
        }
    }
}
