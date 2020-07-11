//
//  CompetitionCell.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct CompetitionCell: View {
<<<<<<< HEAD
=======
    let competitionName: String
    let endDate: Date
>>>>>>> development
    let healthKit: HealthKitController

    var body: some View {
        NavigationLink(
            destination: Text("Destination"),
            label: {
                HStack {
                    ActivityRings(healthKit: healthKit)
                        .padding(.trailing)
                    VStack(alignment: .leading) {
<<<<<<< HEAD
                        Text("Ends On 21 August 2020")
=======
                        Text(endDate, style: .relative)
>>>>>>> development
                            .foregroundColor(.secondary)
                            .font(.subheadline)

                        Spacer()

                        Text("Competition name")
                            .font(.headline)
                        Spacer()

                        VStack(alignment: .leading) {
                            Text("Move: \(Int(healthKit.moveCurrent))/\(Int(healthKit.moveGoal))")
<<<<<<< HEAD
                                .foregroundColor(RingColor.move.darkColor)
=======
                                .foregroundColor(RingColor.move.color)
>>>>>>> development
                                .fontWeight(.medium)
                            Text("Exercise: \(Int(healthKit.exerciseCurrent))/\(Int(healthKit.exerciseGoal))")
                                .foregroundColor(RingColor.exercise.darkColor)
                                .fontWeight(.medium)
                            Text("Stand: \(Int(healthKit.standCurrent))/\(Int(healthKit.standGoal))")
<<<<<<< HEAD
                                .foregroundColor(RingColor.stand.darkColor)
=======
                                .foregroundColor(RingColor.stand.color)
>>>>>>> development
                                .fontWeight(.medium)
                        }
                    }
                }
            })
<<<<<<< HEAD
    }

    init(_ healthKit: HealthKitController) {
=======
            .padding(.vertical, 8)
    }

    init(_ competitionName: String, endsOn endDate: Date, _ healthKit: HealthKitController) {
        self.competitionName = competitionName
        self.endDate = endDate
>>>>>>> development
        self.healthKit = healthKit
    }
}

//struct CompetitionCell_Previews: PreviewProvider {
//    static var previews: some View {
//        CompetitionCell()
//    }
//}
