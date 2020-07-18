//
//  RandomPath.swift
//  Project SF
//
//  Created by Roman Esin on 18.07.2020.
//

import SwiftUI

struct RandomPath: View {

    let numberOfEdges = 4
    let mainColor = Color.red
    @State var angle: CGFloat = 0
    @State var isAnimating = false

    var body: some View {
        Path { path in

            var points = [CGPoint.zero]

            for edge in 1..<numberOfEdges {
                let lastX = points.last!.x
                let lastY = points.last!.y

                switch edge {
                case 1:
                    points.append(.init(x: .random(in: 50...300), y: .random(in: 0...300)))
                case 2:
                    points.append(.init(x: .random(in: lastX...lastX + 300), y: .random(in: lastY...lastY + 300)))
                case 3:
                    points.append(.init(x: .random(in: lastX - 300...lastX), y: .random(in: lastY - 300...lastY)))
                default: break
                }
            }
            path.addLines(points)
            path.closeSubpath()
        }
        .fill(mainColor)
        .rotationEffect(Angle(degrees: self.isAnimating ? (Bool.random() ? 360 : -360) : 0.0),
                        anchor: UnitPoint(x: 0.14, y: 0.14))
        .hueRotation(Angle(degrees: self.isAnimating ? 360 : 0.0))
        .animation(self.isAnimating ?
                    Animation.easeInOut(duration: Double.random(in: 20...40)).repeatForever(autoreverses: false) :
                    .default)
        .onAppear { self.isAnimating = true }
        .onDisappear { self.isAnimating = false }
//        .blur(radius: 10)
//        .offset(x: 100, y: 100)
//        .blendMode(.darken)
    }

    init() {

    }
}

struct RandomPath_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            RandomPath()
//            RandomPath()
//            RandomPath()
//            RandomPath()
//            RandomPath()
//            RandomPath()
        }
    }
}
