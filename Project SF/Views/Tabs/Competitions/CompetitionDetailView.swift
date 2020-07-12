//
//  CompetitionDetailView.swift
//  Project SF
//
//  Created by Roman Esin on 12.07.2020.
//

import SwiftUI

struct CompetitionDetailView: View {
    let competition: Competition

    var body: some View {
        Text(competition.name)
            .navigationTitle(competition.name)
    }
}

struct CompetitionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CompetitionDetailView(competition: Competition(name: "Competition Name", startDate: Date(), endDate: Date() + 123))
    }
}
