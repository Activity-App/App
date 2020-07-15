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
        
        if fill < 0.96 && newFill > 0.96 {
            withAnimation(.easeIn(duration: 1.5)) {
                fill = 0.95
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5 - 0.1) {
                withAnimation(.linear(duration: abs(1 - newFill * 1.5))) {
                    fill = newFill
                }
            }
        } else if fill > 0.96 && newFill < 0.96 {
            withAnimation(.linear(duration: abs(1 - newFill * 1.5))) {
                fill = 1.1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5 - 0.1) {
                withAnimation(.linear(duration: 1)) {
                    fill = newFill
                }
            }
        } else {
            withAnimation(.easeInOut(duration: 1.5)) {
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
