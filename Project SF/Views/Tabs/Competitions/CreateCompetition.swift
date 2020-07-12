//
//  CreateCompetition.swift
//  Project SF
//
//  Created by Roman Esin on 12.07.2020.
//

import SwiftUI

struct CreateCompetition: View {

    @State var competitionName = ""
    @State var competitionEndDate = Date() + 60 * 60 * 24

    var body: some View {
        VStack {
            GroupBox {
                TextField("Competition name", text: $competitionName) { _ in

                } onCommit: {

                }
            }

            GroupBox(label: Text("Competition end date").foregroundColor(Color(UIColor.tertiaryLabel)), content: {
                DatePicker("Competition end date", selection: $competitionEndDate, in: Date()...)
                    .datePickerStyle(GraphicalDatePickerStyle())
            })

            RoundedButton("Start the competition") {

            }
        }
        .padding(.horizontal)
        .navigationTitle("Create competition")
    }
}

struct CreateCompetition_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CreateCompetition()
        }
    }
}
