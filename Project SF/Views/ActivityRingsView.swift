//
//  ActivityRings.swift
//  Project SF
//
//  Created by Christian Privitelli on 10/7/20.
//

import SwiftUI

struct ActivityRingsView: View {

    @ObservedObject var healthKit: HealthKitController
    var minimalFrame: CGFloat = 42
    var ringWidth: CGFloat = 12
    var ringPadding: CGFloat = 5

    private var midRingFrame: CGFloat {
        minimalFrame + ringWidth * 2
    }

    private var largeRingFrame: CGFloat {
        midRingFrame + ringWidth * 2
    }

    var body: some View {
        ZStack {
            ActivityRingView(
                ringType: .move,
                ringWidth: ringWidth,
                current: $healthKit.moveCurrent,
                goal: $healthKit.moveGoal
            )
            .frame(width: largeRingFrame + ringPadding * 2, height: largeRingFrame + ringPadding * 2)
            ActivityRingView(
                ringType: .exercise,
                ringWidth: ringWidth,
                current: $healthKit.exerciseCurrent,
                goal: $healthKit.exerciseGoal
            )
            .frame(width: midRingFrame + ringPadding, height: midRingFrame + ringPadding)
            ActivityRingView(
                ringType: .stand,
                ringWidth: ringWidth,
                current: $healthKit.standCurrent,
                goal: $healthKit.standGoal
            )
            .frame(width: minimalFrame, height: minimalFrame)
        }
    }
}

struct ActivityRingsView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityRingsView(healthKit: HealthKitController())
    }
}
