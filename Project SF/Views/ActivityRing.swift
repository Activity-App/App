//
//  ActivityRing.swift
//  Project SF
//
//  Created by Christian Privitelli on 10/7/20.
//

import SwiftUI

enum RingType {
    
    case move
    case exercise
    case stand
    
    var color: Color {
        switch self {
        case .move: return Color("move")
        case .exercise: return Color("exercise")
        case .stand: return Color("stand")
        }
    }
    
}

struct ActivityRing: View {

    var ringType: RingType
    @Binding var current: Double
    @Binding var goal: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 10)
                .opacity(0.3)
                .foregroundColor(ringType.color)
            Circle()
                .trim(from: 0, to: CGFloat(
                        current.convert(
                            fromRange: 0...goal,
                            toRange: 0.001...1
                        )
                    )
                )
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .opacity(1)
                .foregroundColor(ringType.color)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.8))
        }
    }
}

struct ActivityRing_Previews: PreviewProvider {
    static var previews: some View {
        ActivityRing(ringType: .move, current: .constant(50), goal: .constant(100))
    }
}
