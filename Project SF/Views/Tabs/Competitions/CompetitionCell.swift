//
//  CompetitionCell.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct CompetitionCell: View {
    let competitionName: String
    let startDate: Date
    let endDate: Date
    @ObservedObject var healthKit: HealthKitController

    var body: some View {
        NavigationLink(
            destination: Text("Destination"),
            label: {
                HStack {
                    ActivityRings(healthKit: healthKit)
                        .padding(.trailing)
                    VStack(alignment: .leading) {
                        Text(endDate, style: .relative)
                            .foregroundColor(.secondary)
                            .font(.subheadline)

                        Spacer()

                        Text(competitionName)
                            .font(.headline)
                        Spacer()

                        VStack(alignment: .leading) {
                            Text("Move: \(Int(healthKit.moveCurrent))/\(Int(healthKit.moveGoal))")
                                .foregroundColor(RingType.move.darkColor)
                                .fontWeight(.medium)
                            Text("Exercise: \(Int(healthKit.exerciseCurrent))/\(Int(healthKit.exerciseGoal))")
                                .foregroundColor(RingType.exercise.darkColor)
                                .fontWeight(.medium)
                            Text("Stand: \(Int(healthKit.standCurrent))/\(Int(healthKit.standGoal))")
                                .foregroundColor(RingType.stand.darkColor)
                                .fontWeight(.medium)
                        }
                    }
                }
            })
            .padding(.vertical, 8)
    }
}

//struct CompetitionCell_Previews: PreviewProvider {
//    static var previews: some View {
//        CompetitionCell()
//    }
//}
