//
//  ActivityRing.swift
//  Project SF
//
//  Created by Christian Privitelli on 10/7/20.
//

import SwiftUI

enum RingColor: String {
    
    case move
    case exercise
    case stand
    
    var color: Color { Color(rawValue) }
    
}

struct ActivityRing: View {

    var ringColor: RingColor
    @Binding var current: Double
    @Binding var goal: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 10)
                .opacity(0.3)
                .foregroundColor(ringColor.color)
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
                .foregroundColor(ringColor.color)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.8))
        }
    }
}

struct ActivityRing_Previews: PreviewProvider {
    static var previews: some View {
        ActivityRing(ringColor: .move, current: .constant(50), goal: .constant(100))
    }
}
