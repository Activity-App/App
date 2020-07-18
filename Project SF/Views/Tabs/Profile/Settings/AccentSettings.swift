//
//  AccentSettings.swift
//  Project SF
//
//  Created by Roman Esin on 18.07.2020.
//

import SwiftUI

struct AccentSettings: View {
    @State var color = Color.accentColor

    var body: some View {
        VStack {
            GroupBox {
                Text("This is a text with the new accent color")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.accentColor)
                HStack {
                    Circle()
                        .foregroundColor(.accentColor)
                        .frame(width: 100, height: 100)
                    Spacer()
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .foregroundColor(.accentColor)
                        .frame(width: 100, height: 100)
                }
            }
            GroupBox {
                ColorPicker("Select Accent Color", selection: $color, supportsOpacity: false)
            }
            Spacer()
        }
        .padding(.horizontal)
        .onChange(of: color) { color in
            let color = UIColor(color)
            UserDefaults.standard.set(color, forKey: "accentColor")
            UIApplication.shared.windows[0].tintColor = color
        }
        .navigationTitle("Accent Color")
    }
}

struct AccentSettings_Previews: PreviewProvider {
    static var previews: some View {
        AccentSettings()
    }
}
