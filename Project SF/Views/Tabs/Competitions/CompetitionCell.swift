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
                    VStack(spacing: 8) {
                        PlaceBadgeView(
                            place: competition.place,
                            flippable: false,
                            activityRings: .constant(activity),
                            font: .system(size: 23),
                            innerPadding: 10,
                            outerPadding: 4
                        )
                    }
                    .frame(width: 65)
                    .padding(.trailing, 8)

                    VStack(alignment: .leading) {
                        Text("\(competition.creatingUser.points) points, \(competition.endDate, style: .relative) \(competition.endDate < Date() ? "ago" : "left")")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                        Spacer()
                        Text(competition.name)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(.vertical, 8)
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
        var competitions: [Competition] = [
            Competition(
                name: "Competition1",
                startDate: Date() - 100000,
                endDate: Date() + 100000,
                creatingUser: CompetingPerson(name: "Me", points: 300),
                people: [
                    CompetingPerson(name: "Person1", points: 100),
                    CompetingPerson(name: "Person2", points: 200),
                    CompetingPerson(name: "Person3", points: 6000)
                ]
            ),
            Competition(
                name: "Competition2",
                startDate: Date(),
                endDate: Date() + 1000000,
                creatingUser: CompetingPerson(name: "Me", points: 5500),
                people: [
                    CompetingPerson(name: "Person1", points: 5000),
                    CompetingPerson(name: "Person2", points: 200),
                    CompetingPerson(name: "Person3", points: 500)
                ]
            )
        ]

        return VStack(spacing: 32) {
            CompetitionCell(competitions[0])
                .frame(height: 100)

            CompetitionCell(competitions[1])
                .frame(width: 500, height: 40)
        }
    }
}
