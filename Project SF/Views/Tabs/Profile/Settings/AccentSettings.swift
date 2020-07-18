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
        ColorPicker("Select Accent Color", selection: $color, supportsOpacity: false)
            .onChange(of: color) { color in
                UIApplication.shared.windows[0].tintColor = UIColor(color)
            }
    }
}

struct AccentSettings_Previews: PreviewProvider {
    static var previews: some View {
        AccentSettings()
    }
}
