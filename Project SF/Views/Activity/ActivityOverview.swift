//
//  ActivityOverview.swift
//  Project SF
//
//  Created by Roman Esin on 15.07.2020.
//

import SwiftUI

struct ActivityOverview: View {

    var shouldAnimate = true
    @Environment(\.colorScheme) var colorScheme
    @Binding var activity: ActivityRings

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Move: \(activity.moveFraction)")
                    .foregroundColor(colorScheme == .light ?
                                        RingType.move.darkColor : RingType.move.color)
                    .fontWeight(.medium)
                Text("Exercise: \(activity.exerciseFraction)")
                    .foregroundColor(colorScheme == .light ?
                                        RingType.exercise.darkColor : RingType.exercise.color)
                    .fontWeight(.medium)
                Text("Stand: \(activity.standFraction)")
                    .foregroundColor(RingType.stand.darkColor)
                    .fontWeight(.medium)
            }
            Spacer()
            ActivityRingsView(shouldAnimate: shouldAnimate, values: $activity, ringSize: .medium)
                .padding(.vertical, 12)
        }
    }
}

struct ActivityOverview_Previews: PreviewProvider {
    static var previews: some View {
        ActivityOverview(activity: .constant(.init(
            moveCurrent: 0,
            moveGoal: 400,
            exerciseCurrent: 0,
            exerciseGoal: 30,
            standCurrent: 0,
            standGoal: 12
        )))
    }
}