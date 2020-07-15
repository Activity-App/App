//
//  ActivityRing.swift
//  Project SF
//
//  Created by Christian Privitelli on 10/7/20.
//

import SwiftUI

struct ActivityRingView: View {

    var ringType: RingType
    var ringWidth: CGFloat
    
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
                            fill > 0.96 ? ringType.color : .clear
                        )
                        .shadow(
                            color: Color.black.opacity(0.125),
                            radius: ringWidth / 8,
                            x: ringWidth / 3.5,
                            y: 0
                        )
                        .animation(nil)
                        .rotationEffect(.degrees(360 * fill))
                    
                    ringType.icon
                        .resizable()
                        .frame(width: ringWidth - 4, height: ringWidth - 4)
                        .offset(y: -geometry.size.height / 2)
                }
            }
        }
        .onAppear {
            updateRingFill()
        }
        .onChange(of: current) { newCurrent in
            updateRingFill(newCurrent: newCurrent)
        }
        .onChange(of: goal) { newGoal in
            updateRingFill(newGoal: newGoal)
        }
    }
    
    func updateRingFill(newCurrent: Double? = nil, newGoal: Double? = nil) {
        let currentIn = newCurrent == nil ? current : newCurrent!
        let goalIn = newGoal == nil ? goal : newGoal!
        
        let newFill = currentIn / goalIn + 0.001
        
        let animationTime = abs(fill - newFill) * 2
        let over100AnimationTime = abs(1 - newFill) * 2
        
        if fill < 0.96 && newFill > 0.96 {
            withAnimation(.easeIn(duration: animationTime - over100AnimationTime)) {
                fill = 0.96
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + animationTime - over100AnimationTime - 0.15) {
                withAnimation(.easeOut(duration: over100AnimationTime)) {
                    fill = newFill
                }
            }
        } else if fill > 0.96 && newFill < 0.96 {
            withAnimation(.easeIn(duration: animationTime - over100AnimationTime)) {
                fill = 1.1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + animationTime - over100AnimationTime - 0.1) {
                withAnimation(.easeOut(duration: over100AnimationTime)) {
                    fill = newFill
                }
            }
        } else {
            withAnimation(.spring()) {
                fill = newFill
            }
        }
    }
}

struct ActivityRing_Previews: PreviewProvider {
    static var previews: some View {
        ActivityRingView(ringType: .move, ringWidth: 18, current: .constant(150), goal: .constant(100))
            .frame(width: 100, height: 100)
    }
}
