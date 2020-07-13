//
//  NavScrollView.swift
//  Project SF
//
//  Created by Christian Privitelli on 13/7/20.
//

import SwiftUI

/// A somewhat fixed scroll view when used with a navview
struct NavScrollView<Content: View>: View {
    
    var content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { outerGeo in
            ScrollView(showsIndicators: false) {
                Spacer(minLength: outerGeo.safeAreaInsets.top)
                content
            }
            .edgesIgnoringSafeArea(.top)
            .frame(height: outerGeo.size.height)
        }
    }
}

struct NavScrollView_Previews: PreviewProvider {
    static var previews: some View {
        NavScrollView {
            Text("hello")
        }
    }
}
