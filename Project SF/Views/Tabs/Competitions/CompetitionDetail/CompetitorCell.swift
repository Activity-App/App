//
//  CompetitorCell.swift
//  Project SF
//
//  Created by Christian Privitelli on 16/7/20.
//

import SwiftUI

struct CompetitorCell: View {
    
    let competition: Competition
    let person: CompetingPerson
    
    var body: some View {
        if competition.creatingUser == person {
            cellBody()
        } else {
            NavigationLink(destination: CompetitorDetail(competition: competition, person: person)) {
                cellBody()
            }
        }
    }
    
    func cellBody() -> some View {
        HStack {
            Text("\(competition.people.sorted { $0.points > $1.points }.firstIndex(of: person)! + 1)")
                .font(.caption)
                .foregroundColor(Color(.tertiaryLabel))
            Image(systemName: "circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.init(
                                    red: Double.random(in: 0...1),
                                    green: Double.random(in: 0...1),
                                    blue: Double.random(in: 0...1)
                                )
                )
                .padding(.leading, 4)
            VStack(alignment: .leading) {
                Text(person.name)
                    .fontWeight(.bold)
                Text("\(person.points) points")
                    .font(.caption)
                    .foregroundColor(Color(.secondaryLabel))
            }
        }
    }
}

struct CompetitorCell_Previews: PreviewProvider {
    static var previews: some View {
        CompetitorCell(
            competition: Competition(
                name: "CompetitionName",
                startDate: Date() - 100000,
                endDate: Date() + 100000,
                creatingUser: CompetingPerson(name: "Me", points: 150),
                people: [
                    CompetingPerson(name: "Person1", points: 100),
                    CompetingPerson(name: "Person2", points: 200),
                    CompetingPerson(name: "Person3", points: 0),
                    CompetingPerson(name: "Me", points: 150)
                ]
            ),
            person: CompetingPerson(name: "Me", points: 150)
        )
    }
}
