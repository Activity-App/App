//
//  CompetitionCell.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct CompetitionCell: View {
    let competition: Competition

    var body: some View {
        NavigationLink(
            destination: CompetitionDetailView(competition: competition),
            label: {
                HStack {
                    
                    VStack {
                        Text("1st")
                            .font(.largeTitle)
                            .bold()
                        Text("5 points")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 8)
                    
                    VStack(alignment: .leading) {
                        Spacer()
                        Text(competition.endDate, style: .relative)
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                        Spacer()
                        Text(competition.name)
                            .font(.headline)
                        Spacer()
                    }
                }
            })
            .padding(.vertical, 8)
    }
}

struct CompetitionCell_Previews: PreviewProvider {
    static var previews: some View {
        CompetitionCell(competition: .init(name: "name", startDate: Date(), endDate: Date() + 1000))
            .frame(width: 200, height: 40)
    }
}
