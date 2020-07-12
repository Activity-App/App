//
//  ActivityRings.swift
//  Project SF
//
//  Created by Christian Privitelli on 10/7/20.
//

import SwiftUI

struct ActivityRingsView: View {

    @ObservedObject var healthKit: HealthKitController

    var body: some View {
        ZStack {
            ActivityRingView(
                ringType: .move,
                ringWidth: 14,
                current: $healthKit.moveCurrent,
                goal: $healthKit.moveGoal
            )
            .frame(width: 110, height: 110)
            ActivityRingView(
                ringType: .exercise,
                ringWidth: 14,
                current: $healthKit.exerciseCurrent,
                goal: $healthKit.exerciseGoal
            )
            .frame(width: 78, height: 78)
            ActivityRingView(
                ringType: .stand,
                ringWidth: 14,
                current: $healthKit.standCurrent,
                goal: $healthKit.standGoal
            )
            .frame(width: 46, height: 46)
        }
    }
}

struct ActivityRingsView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityRingsView(healthKit: HealthKitController())
    }
}
