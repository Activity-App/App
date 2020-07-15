//
//  ActivityRing.swift
//  Project SF
//
//  Created by Christian Privitelli on 10/7/20.
//

import SwiftUI

struct ActivityRingView: View {

    var shouldAnimate = true
    var ringType: RingType
    var ringWidth: CGFloat

    @Environment(\.presentationMode) var presentationMode
    @Binding var current: Double
    @Binding var goal: Double
    
    @State var fill: Double = 0

    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    
                    // Ring outline
                    Circle()
                        .stroke(lineWidth: ringWidth)
                        .opacity(0.3)
                        .foregroundColor(ringType.darkColor)
                    
                    // The activity ring
                    Circle()
                        .trim(from: 0, to: CGFloat(fill))
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [ringType.darkColor.opacity(0.7), ringType.color]),
                                center: .center,
                                startAngle: .degrees(0),
                                endAngle: .degrees(360 * fill)
                            ),
                            style: StrokeStyle(lineWidth: ringWidth, lineCap: .round))
                        .opacity(1)
                        .rotationEffect(.degrees(-90))

                    // Ring shadow
                    Circle()
                        .frame(width: ringWidth, height: ringWidth)
                        .offset(y: -geometry.size.height / 2)
                        .foregroundColor(
                            ringType.color
                        )
                        .shadow(
                            color: Color.black.opacity(0.125),
                            radius: ringWidth / 8,
                            x: ringWidth / 3.5,
                            y: 0
                        )
                        .animation(nil)
                        .rotationEffect(.degrees(360 * fill))

                    if ringWidth > 13 {
                        ringType.icon
                            .resizable()
                            .frame(width: ringWidth - 4, height: ringWidth - 4)
                            .offset(y: -geometry.size.height / 2)
                    }
                }
            }
        }
        .onChange(of: current) { _ in
            guard shouldAnimate else { return }
            withAnimation(.easeInOut(duration: 1.3)) {
                fill = current == 0 ? 0 : current / goal
            }
        }
    }
}

struct ActivityRing_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 32) {
            ActivityRingView(ringType: .move, ringWidth: 18, current: .constant(70), goal: .constant(90))
                .frame(width: 100, height: 100)
            ActivityRingView(ringType: .exercise, ringWidth: 18, current: .constant(10), goal: .constant(90))
                .frame(width: 100, height: 100)
            ActivityRingView(ringType: .stand, ringWidth: 18, current: .constant(120), goal: .constant(90))
                .frame(width: 100, height: 100)
            ActivityRingView(ringType: .stand, ringWidth: 13, current: .constant(120), goal: .constant(90))
                .frame(width: 60, height: 60)
        }
    }
}
