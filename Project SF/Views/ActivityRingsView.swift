//
//  ActivityRings.swift
//  Project SF
//
//  Created by Christian Privitelli on 10/7/20.
//

import SwiftUI

/// Creates activity ring with the specified parameters.
/// Use `.large`, `.medium` or `.small` to get default ring sizes.
struct RingSize {
    static var large: RingSize {
        RingSize(minFrame: 55, width: 17, padding: 10)
    }

    static var medium: RingSize {
        RingSize(minFrame: 46, width: 14, padding: 8)
    }

    static var small: RingSize {
        RingSize(minFrame: 36, width: 12, padding: 6)
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

    @EnvironmentObject var healthKit: HealthKitController
    let ringSize: RingSize

    private var midRingFrame: CGFloat {
        ringSize.minFrame + ringSize.width * 2 + ringSize.padding
    }

    private var largeRingFrame: CGFloat {
        midRingFrame + ringSize.width * 2 + ringSize.padding
    }

    var body: some View {
        ZStack {
            ActivityRingView(
                ringType: .move,
                ringWidth: ringSize.width,
                current: $healthKit.moveCurrent,
                goal: $healthKit.moveGoal
            )
            .frame(width: largeRingFrame, height: largeRingFrame)
            ActivityRingView(
                ringType: .exercise,
                ringWidth: ringSize.width,
                current: $healthKit.exerciseCurrent,
                goal: $healthKit.exerciseGoal
            )
            .frame(width: midRingFrame, height: midRingFrame)
            ActivityRingView(
                ringType: .stand,
                ringWidth: ringSize.width,
                current: $healthKit.standCurrent,
                goal: $healthKit.standGoal
            )
            .frame(width: ringSize.minFrame, height: ringSize.minFrame)
        }
    }
}

struct ActivityRingsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ActivityRingsView(ringSize: .large)
            ActivityRingsView(ringSize: .medium)
            ActivityRingsView(ringSize: .small)
        }
    }
}
