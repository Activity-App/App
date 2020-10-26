//
//  CompetitorCell.swift
//  Project SF
//
//  Created by Christian Privitelli on 16/7/20.
//

import SwiftUI

struct CompetitorCell: View {
    
    let competition: Competition
    let person: CompetingUser

    @ViewBuilder
    var body: some View {
        NavigationLink(destination: CompetitorDetail(competition: competition, person: person)) {
            cellBody()
        }
    }
    
    func cellBody() -> some View {
        HStack {
            Text("0")
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
                Text(person.user.name)
                    .fontWeight(.bold)
                Text("\(person.points) points")
                    .font(.caption)
                    .foregroundColor(Color(.secondaryLabel))
            }
        }
    }
}

//struct CompetitorCell_Previews: PreviewProvider {
//    static var previews: some View {
//        CompetitorCell(
//            competition: Competition(
//                title: "CompetitionName",
//                startDate: Date() - 100000,
//                endDate: Date() + 100000
//            ),
//            person: CompetingUser(name: "Me", points: 150)
//        )
//    }
//}
