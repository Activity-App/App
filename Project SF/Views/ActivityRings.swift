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
            ActivityRing(ringColor: .move, current: $healthKit.moveCurrent, goal: $healthKit.moveGoal)
                .frame(width: 100, height: 100)
            ActivityRing(ringColor: .exercise, current: $healthKit.exerciseCurrent, goal: $healthKit.exerciseGoal)
                .frame(width: 75, height: 75)
            ActivityRing(ringColor: .stand, current: $healthKit.standCurrent, goal: $healthKit.standGoal)
                .frame(width: 50, height: 50)
        }
    }
}

struct ActivityRings_Previews: PreviewProvider {
    static var previews: some View {
        ActivityRings(healthKit: HealthKitController())
    }
}
