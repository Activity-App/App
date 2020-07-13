//
//  ActivityRings.swift
//  Project SF
//
//  Created by Christian Privitelli on 12/7/20.
//

import Foundation

struct ActivityRings {
    var moveCurrent: Double
    var moveGoal: Double
    var exerciseCurrent: Double
    var exerciseGoal: Double
    var standCurrent: Double
    var standGoal: Double

    var moveFraction: String {
        "\(Int(moveCurrent))/\(Int(moveGoal))"
    }

    var exerciseFraction: String {
        "\(Int(exerciseCurrent))/\(Int(exerciseGoal))"
    }

    var standFraction: String {
        "\(Int(standCurrent))/\(Int(standGoal))"
    }
}
