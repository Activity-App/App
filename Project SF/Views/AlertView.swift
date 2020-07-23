//
//  AlertView.swift
//  Project SF
//
//  Created by Christian Privitelli on 23/7/20.
//

import SwiftUI

struct AlertView: View {
    
    @EnvironmentObject var manager: AlertManager
    @State var colorPulse = false
    
    @ViewBuilder
    var body: some View {
        ZStack {
            if manager.isPresented {
                VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                    .transition(AnyTransition.opacity.animation(.linear(duration: 0.4)))
            }
            GeometryReader { geometry in
                if manager.isPresented {
                    ZStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 40, style: .continuous)
                                .foregroundColor(.white)
                                .shadow(radius: 20)
                            VStack {
                                Text("Something went wrong!")
                                    .font(.title2)
                                    .fontWeight(.heavy)
                                    .padding(.top, 24)
                                    .padding(.horizontal, 16)
                                Spacer()
                                Image(systemName: manager.icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geometry.size.height/5, height: geometry.size.height/5)
                                    .foregroundColor(manager.color)
                                    .onAppear {
                                        withAnimation(
                                            Animation
                                                .easeInOut(duration: 1.7)
                                                .repeatForever(autoreverses: true)
                                        ) {
                                            self.colorPulse.toggle()
                                        }
                                    }
                                    .opacity(colorPulse ? 0.65 : 1)
                                Text(manager.message)
                                    .padding(.horizontal, 32)
                                    .font(.footnote)
                                Spacer()
                                RoundedButton(manager.buttonTitle, action: manager.buttonAction)
                                .padding(.horizontal, 32)
                                Spacer()
                            }
                        }
                        .frame(width: min(geometry.size.width - 50, 350), height: min(geometry.size.height - 50, 400))
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                    .transition(AnyTransition.scale.animation(.spring()))
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertView()
            .previewLayout(PreviewLayout.fixed(width: 320, height: 568))
    }
}
