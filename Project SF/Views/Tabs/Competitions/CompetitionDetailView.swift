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
        CompetitionDetailView(competition: Competition(
            name: "Competition2",
            startDate: Date(),
            endDate: Date() + 1000000,
            creatingUser: CompetingPerson(name: "Me", points: 5500),
            people: [
                CompetingPerson(name: "Person1", points: 5000),
                CompetingPerson(name: "Person2", points: 200),
                CompetingPerson(name: "Person3", points: 500)
            ]
        ))
    }
}
