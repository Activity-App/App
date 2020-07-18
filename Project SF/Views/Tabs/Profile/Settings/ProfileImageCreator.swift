//
//  ProfileImageCreator.swift
//  Project SF
//
//  Created by Roman Esin on 16.07.2020.
//

import SwiftUI

struct ProfileImageCreator: View {

    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    @Binding var color: Color

    var body: some View {
        NavigationView {
            VStack {
                if let image = image {
                    Image(uiImage: image)
                        .interpolation(.none)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .foregroundColor(color)

                    GroupBox {
                        ColorPicker("Select foreground color", selection: $color, supportsOpacity: false)
                    }
                    .padding(.top)
                }
                RoundedButton("Generate image") {
                    withAnimation {
                        image = UIImage(pixelImage: .randomSymmetrical(color: .white, width: 7, height: 7))
                    }
                }
                .padding(.top)
            }
            .padding(.horizontal)
            .navigationTitle("Profile Image Creator")
        }
        .onDisappear {
            if image == nil {
                color = .clear
            }
        }
    }

    init(_ image: Binding<UIImage?>, color: Binding<Color>) {
        DispatchQueue.main.async {
            var shouldRemoveImage = false
            if color.wrappedValue == .clear {
                color.wrappedValue = .black
                shouldRemoveImage = true
            }
            if image.wrappedValue != nil && shouldRemoveImage {
                image.wrappedValue = nil
            }
        }
        _image = image
        _color = color
    }
}

struct ProfileImageCreator_Previews: PreviewProvider {
    static var previews: some View {
        ProfileImageCreator(.constant(UIImage(pixelImage: .randomSymmetrical(color: .red, width: 10, height: 10))),
                            color: .constant(Color.red))
    }
}
