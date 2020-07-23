//
//  RoundedNavigationButton.swift
//  Project SF
//
//  Created by William Taylor on 12/7/20.
//

import Foundation
import SwiftUI

/// A custom NavigationLink with Text inside a rounded rect
/// which spans across the whole width of the screen.
struct RoundedNavigationLink<Destination: View>: View {
    let title: String
    let destination: Destination
    
    @Binding var isLoading: Bool

    var body: some View {
        NavigationLink(
            destination: destination,
            label: {
                if !isLoading {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .modifier(RoundedRectBackground())
                } else {
                    ProgressView()
                        .progressViewStyle(LightProgressViewStyle())
                        .modifier(RoundedRectBackground())
                }
            }
        )
        .disabled(isLoading)
    }

    init(_ title: String,
         destination: Destination,
         isLoading: Binding<Bool> = .constant(false)
    ) {
        self.title = title
        self.destination = destination
        self._isLoading = isLoading
    }
}

/// A custom NavigationLink with Text inside a rounded rect
/// which spans across the whole width of the screen.
struct RoundedNavigationLinkButton<Destination: View>: View {
    let title: String
    let destination: Destination
    let action: () -> Void
    
    @Binding var isLoading: Bool
    @Binding var isActive: Bool

    var body: some View {
        ZStack {
            RoundedButton(isLoading ? "" : title, action: action)
                .disabled(isLoading)
            if isLoading {
                ProgressView()
            }
            NavigationLink(
                destination: destination,
                isActive: $isActive,
                label: {
                    EmptyView()
                }
            )
        }
    }

    init(_ title: String,
         destination: Destination,
         isLoading: Binding<Bool> = .constant(false),
         isActive: Binding<Bool> = .constant(false),
         action: @escaping () -> Void
    ) {
        self.title = title
        self.destination = destination
        self._isLoading = isLoading
        self._isActive = isActive
        self.action = action
    }
}

struct RoundedNavigationButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RoundedNavigationLink("Continue", destination: Text(""))
            RoundedNavigationLink("Continue", destination: Text(""), isLoading: .constant(true))
        }
    }
}

private struct RoundedRectBackground: ViewModifier {

    func body(content: Content) -> some View {
        content
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 55)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(16)
            .padding()
    }
    
}

private struct LightProgressViewStyle: ProgressViewStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration)
            .colorScheme(.dark)
    }
    
}
