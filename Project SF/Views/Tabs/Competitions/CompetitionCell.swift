//
//  CompetitionCell.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct CompetitionCell: View {
    let competitionName: String
    let startDate: Date
    let endDate: Date

    var body: some View {
        NavigationLink(
            destination: Text("Destination"),
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
                        Text("\(endDate, style: .relative) \(endDate < Date() ? "ago" : "")")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                        Spacer()
                        Text(competitionName)
                            .font(.headline)
                        Spacer()
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            })
            .padding(.vertical, 8)
    }
}

struct CompetitionCell_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 32) {
            CompetitionCell(competitionName: "test", startDate: Date(), endDate: Date() + 1000)
                .frame(width: 500, height: 40)

            CompetitionCell(competitionName: "test", startDate: Date(), endDate: Date() - 1000)
                .frame(width: 500, height: 40)
        }
    }
}
