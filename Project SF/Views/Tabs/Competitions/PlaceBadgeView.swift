//
//  PlaceBadgeView.swift
//  Project SF
//
//  Created by Christian Privitelli on 13/7/20.
//

import SwiftUI

struct PlaceBadgeView: View {
    let place: Int
    let flippable: Bool
    
    @Binding var activityRings: ActivityRings
    
    let font: Font
    let innerPadding: CGFloat
    let outerPadding: CGFloat
    
    @State var flipped = false
    
    init(place: Int, flippable: Bool,
         activityRings: Binding<ActivityRings>, font: Font = .title,
         innerPadding: CGFloat = 24, outerPadding: CGFloat = 4) {
        self.place = place
        self.flippable = flippable
        self._activityRings = activityRings
        self.font = font
        self.innerPadding = innerPadding
        self.outerPadding = outerPadding
    }
    
    var body: some View {
        Text("\(place)\(place == 1 ? "st" : place == 2 ? "nd" : place == 3 ? "rd" : "th")")
            .font(font)
            .fontWeight(.black)
            .padding(innerPadding)
            .opacity(flipped ? 0 : 1)
            .background(
                Circle()
                    .foreground(
                        Group {
                            if !flipped {
                                place == 1 ? Color.yellow :
                                    place == 2 ? Color(.lightGray) :
                                    place == 3 ? Color.init(red: 0.6, green: 0.4, blue: 0.3) :
                                    Color.accentColor
                            } else {
                                GeometryReader { geometry in
                                    ZStack {
                                        Color(.systemBackground)
                                        ActivityRingsView(
                                            values: $activityRings,
                                            ringSize: RingSize(
                                                size: geometry.size.height-20,
                                                width: (geometry.size.height-20)*0.13,
                                                padding: 2
                                            )
                                        )
                                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                                    }
                                }
                            }
                        }
                    )
                    .padding(-4)
            )
            .rotation3DEffect(
                flipped ? .degrees(180) : .degrees(0),
                axis: (x: 0, y: 1, z: 0),
                anchor: .center
            )
            .modifier(OptionalTapGesture(condition: flippable, action: {
                withAnimation(.spring()) {
                    flipped.toggle()
                }
            }))
            .shadow(color: Color.black.opacity(0.1), radius: 10)
    }
}

struct OptionalTapGesture: ViewModifier {
    var condition: Bool
    var action: () -> Void

    @ViewBuilder
    func body(content: Content) -> some View {
        if condition {
            content.onTapGesture(perform: action)
        } else {
            content
        }
    }
}
