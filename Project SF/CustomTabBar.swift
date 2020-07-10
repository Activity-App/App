//
//  CustomTabBar.swift
//  Project SF
//
//  Created by Christian Privitelli on 10/7/20.
//

import SwiftUI

struct TabBar: View {

    @Binding var page: Int

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()
                ZStack {

                    background()
                        .shadow(radius: 8, y: -8)

                    HStack {
                        button(image: "star.fill", name: "Competitions", page: 1)
                        button(image: "person.3.fill", name: "Teams", page: 2)
                        button(image: "gearshape.fill", name: "Settings", page: 3)
                    }

                }

                background(height: geometry.safeAreaInsets.bottom)

            }
            .edgesIgnoringSafeArea(.bottom)
        }

    }

    func background(height: CGFloat = 50) -> some View {
        Rectangle()
            .frame(height: height)
            .foregroundColor(.clear)
            .background(backgroundEffect())
    }

    func backgroundEffect() -> some View {
        VisualEffectView(
            effect: UIBlurEffect(
                style: .systemUltraThinMaterial
            )
        )
            .brightness(-0.1)
            .saturation(3)
    }

    func button(image: String, name: String, page: Int) -> some View {
        HStack {
            Spacer()
            VStack {
                Image(systemName: image)
                    .frame(height: 20)
                    .foregroundColor(page == self.page ? .init(red: 1, green: 0.4, blue: 0.4) : .secondary)
                Text(name)
                    .font(.caption2)
                    .frame(alignment: .bottom)
                    .foregroundColor(page == self.page ? .init(red: 1, green: 0.4, blue: 0.4) : .secondary)
            }
            .onTapGesture {
                self.page = page
            }
            Spacer()
        }
    }
}

struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        TabBar(page: .constant(1))
    }
}
