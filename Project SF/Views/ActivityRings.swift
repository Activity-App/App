//
//  ActivityRings.swift
//  Project SF
//
//  Created by Christian Privitelli on 10/7/20.
//

import SwiftUI

struct ActivityRings: View {

    @ObservedObject var healthKit: HealthKitController

    var body: some View {
        ZStack {
            ActivityRing(
                ringType: .move,
                ringWidth: 14,
                current: $healthKit.moveCurrent,
                goal: $healthKit.moveGoal
            )
            .frame(width: 110, height: 110)
            ActivityRing(
                ringType: .exercise,
                ringWidth: 14,
                current: $healthKit.exerciseCurrent,
                goal: $healthKit.exerciseGoal
            )
            .frame(width: 78, height: 78)
            ActivityRing(
                ringType: .stand,
                ringWidth: 14,
                current: $healthKit.standCurrent,
                goal: $healthKit.standGoal
            )
            .frame(width: 46, height: 46)
        }
    }
}

struct ActivityRings_Previews: PreviewProvider {
    static var previews: some View {
        ActivityRings(healthKit: HealthKitController())
    }
}
