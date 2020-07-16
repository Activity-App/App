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
    @State var color = Color.accentColor

    var body: some View {
        NavigationView {
            VStack {
                if let image = image {
                    Image(uiImage: image)
                        .interpolation(.none)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .animation(.spring())

                    // TODO: Dynamically change color of the image
                    ColorPicker("Select foreground color", selection: $color)
                        .padding(.top)
                }
                RoundedButton("Generate image") {
                    withAnimation {
                        image = UIImage(pixelImage: .randomSymmetrical(color: color, width: 7, height: 7))
                    }
                }
                .padding(.top)
            }
            .padding(.horizontal)
            .navigationTitle("Profile Image Creator")
            .navigationBarItems(trailing: NavigationBarButton(systemName: "xmark.circle.fill", action: {
                presentationMode.wrappedValue.dismiss()
            }))
        }
    }

    init(_ image: Binding<UIImage?>) {
        _image = image
    }
}

struct ProfileImageCreator_Previews: PreviewProvider {
    static var previews: some View {
        ProfileImageCreator(.constant(UIImage(pixelImage: .randomSymmetrical(color: .red, width: 10, height: 10))))
    }
}
