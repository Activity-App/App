//
//  ActivityRings.swift
//  Project SF
//
//  Created by Christian Privitelli on 10/7/20.
//

import SwiftUI

struct ActivityRings: View {
    
    @ObservedObject var hk: HealthKitController
    
    var body: some View {
        ZStack {
            ActivityRing(ringType: .move, current: $hk.moveCurrent, goal: $hk.moveGoal)
                .frame(width: 100, height: 100)
            ActivityRing(ringType: .exercise, current: $hk.exerciseCurrent, goal: $hk.exerciseGoal)
                .frame(width: 75, height: 75)
            ActivityRing(ringType: .stand, current: $hk.standCurrent, goal: $hk.standGoal)
                .frame(width: 50, height: 50)
        }
    }
}

struct ActivityRings_Previews: PreviewProvider {
    static var previews: some View {
        ActivityRings(hk: HealthKitController())
    }
}
