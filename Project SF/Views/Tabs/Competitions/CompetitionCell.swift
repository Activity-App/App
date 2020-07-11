//
//  CompetitionCell.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct CompetitionCell: View {
    let healthKit: HealthKitController

    var body: some View {
        NavigationLink(
            destination: Text("Destination"),
            label: {
                HStack {
                    ActivityRings(healthKit: healthKit)
                        .padding(.trailing)
                    VStack(alignment: .leading) {
                        Text("Ends On 21 August 2020")
                            .foregroundColor(.secondary)
                            .font(.subheadline)

                        Spacer()

                        Text("Competition name")
                            .font(.headline)
                        Spacer()

                        VStack(alignment: .leading) {
                            Text("Move: \(Int(healthKit.moveCurrent))/\(Int(healthKit.moveGoal))")
                                .foregroundColor(RingColor.move.color)
                                .fontWeight(.medium)
                            Text("Exercise: \(Int(healthKit.exerciseCurrent))/\(Int(healthKit.exerciseGoal))")
                                .foregroundColor(RingColor.exercise.darkColor)
                                .fontWeight(.medium)
                            Text("Stand: \(Int(healthKit.standCurrent))/\(Int(healthKit.standGoal))")
                                .foregroundColor(RingColor.stand.color)
                                .fontWeight(.medium)
                        }
                    }
                }
            })
    }

    init(_ healthKit: HealthKitController) {
        self.healthKit = healthKit
    }
}

//struct CompetitionCell_Previews: PreviewProvider {
//    static var previews: some View {
//        CompetitionCell()
//    }
//}
