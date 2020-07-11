//
//  TeamsView.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct TodayView: View {
    var body: some View {
        NavigationView {
            Text("Today")
                .navigationBarTitle("Today")
        }
        .tabItem {
            VStack {
                Image(systemName: "calendar.circle.fill")
                    .font(.system(size: 18))
                Text("Today")
            }
        }
        .tag(2)
    }
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView()
    }
}
