//
//  ActivityRings.swift
//  Project SF
//
//  Created by Christian Privitelli on 10/7/20.
//

import SwiftUI

///// Creates activity ring with the specified parameters.
///// Use `.large`, `.medium` or `.small` to get default ring sizes.
struct RingSize {
    static var large: RingSize {
        RingSize(size: 150, width: 20, padding: 4)
    }

    static var medium: RingSize {
        RingSize(size: 100, width: 13, padding: 2)
    }

    static var small: RingSize {
        RingSize(size: 70, width: 10, padding: 1)
    }

    var size: CGFloat
    var width: CGFloat
    var padding: CGFloat
    
    var move: CGFloat
    var exercise: CGFloat
    var stand: CGFloat

    /// Creates activity ring with the specified parameters.
    /// - Parameters:
    ///   - minFrame: The frame of the smallest ring.
    ///   - width: Width of each ring.
    ///   - padding: Padding between rings.
    init(size: CGFloat, width: CGFloat, padding: CGFloat) {
        self.size = size
        self.width = width
        self.padding = padding
        
        move = size
        exercise = size - width*2 - padding
        stand = exercise - width*2 - padding
    }
}

struct ActivityRingsView: View {

    @Binding var values: ActivityRings
    let ringSize: RingSize

    var body: some View {
        ZStack {
            ActivityRingView(
                ringType: .move,
                ringWidth: ringSize.width,
                current: $values.moveCurrent,
                goal: $values.moveGoal
            )
            .frame(width: ringSize.move, height: ringSize.move)
            ActivityRingView(
                ringType: .exercise,
                ringWidth: ringSize.width,
                current: $values.exerciseCurrent,
                goal: $values.exerciseGoal
            )
            .frame(width: ringSize.exercise, height: ringSize.exercise)
            ActivityRingView(
                ringType: .stand,
                ringWidth: ringSize.width,
                current: $values.standCurrent,
                goal: $values.standGoal
            )
            .frame(width: ringSize.stand, height: ringSize.stand)
        }
    }
}

struct ActivityRingsView_Previews: PreviewProvider {
    static var previews: some View {
        let activity = ActivityRings(
            moveCurrent: 350,
            moveGoal: 300,
            exerciseCurrent: 4,
            exerciseGoal: 30,
            standCurrent: 1,
            standGoal: 12
        )
        return VStack(spacing: 20) {
            ActivityRingsView(values: .constant(activity), ringSize: .large)
            ActivityRingsView(values: .constant(activity), ringSize: .medium)
            ActivityRingsView(values: .constant(activity), ringSize: .small)
        }
    }
}
