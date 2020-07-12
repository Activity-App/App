//
//  ActivityRings.swift
//  Project SF
//
//  Created by Christian Privitelli on 10/7/20.
//

import SwiftUI

/// Creates activity ring with the specified parameters.
/// Use `.large`, `.medium` or `.small` to get default ring sizes.
struct Ring {
    static var large: Ring {
        Ring(minFrame: 55, width: 17, padding: 10)
    }

    static var medium: Ring {
        Ring(minFrame: 46, width: 14, padding: 8)
    }

    static var small: Ring {
        Ring(minFrame: 36, width: 12, padding: 6)
    }

    var minFrame: CGFloat
    var width: CGFloat
    var padding: CGFloat

    /// Creates activity ring with the specified parameters.
    /// - Parameters:
    ///   - minFrame: The frame of the smallest ring.
    ///   - width: Width of each ring.
    ///   - padding: Padding between rings.
    init(minFrame: CGFloat, width: CGFloat, padding: CGFloat) {
        self.minFrame = minFrame
        self.width = width
        self.padding = padding
    }
}

struct ActivityRingsView: View {

    @ObservedObject var healthKit: HealthKitController
    let ring: Ring

    private var midRingFrame: CGFloat {
        ring.minFrame + ring.width * 2 + ring.padding
    }

    private var largeRingFrame: CGFloat {
        midRingFrame + ring.width * 2 + ring.padding
    }

    var body: some View {
        ZStack {
            ActivityRingView(
                ringType: .move,
                ringWidth: ring.width,
                current: $healthKit.moveCurrent,
                goal: $healthKit.moveGoal
            )
            .frame(width: largeRingFrame, height: largeRingFrame)
            ActivityRingView(
                ringType: .exercise,
                ringWidth: ring.width,
                current: $healthKit.exerciseCurrent,
                goal: $healthKit.exerciseGoal
            )
            .frame(width: midRingFrame, height: midRingFrame)
            ActivityRingView(
                ringType: .stand,
                ringWidth: ring.width,
                current: $healthKit.standCurrent,
                goal: $healthKit.standGoal
            )
            .frame(width: ring.minFrame, height: ring.minFrame)
        }
    }
}

struct ActivityRingsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ActivityRingsView(healthKit: HealthKitController(), ring: .large)
            ActivityRingsView(healthKit: HealthKitController(), ring: .medium)
            ActivityRingsView(healthKit: HealthKitController(), ring: .small)
        }
    }
}
