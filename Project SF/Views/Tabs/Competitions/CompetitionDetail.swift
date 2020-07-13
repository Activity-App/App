//
//  CompetitionDetail.swift
//  Project SF
//
//  Created by Christian Privitelli on 13/7/20.
//

import SwiftUI

struct CompetitionDetail: View {
    
    let competition: Competition
    
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            Spacer()
        }
        .navigationTitle(competition.name)
    }
}

struct CompetitionDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CompetitionDetail(competition: Competition(name: "CompetitionName", startDate: Date(), endDate: Date() + 10000))
        }
    }
}
