//
//  CreateCompetition.swift
//  Project SF
//
//  Created by Roman Esin on 12.07.2020.
//

import SwiftUI

struct CreateCompetition: View {

    @Environment(\.presentationMode) var presentationMode
    @State var competitionName = ""
    @State var competitionEndDate = Date() + 60 * 60 * 24
    @State var pickedDate = 0

    var body: some View {
//        ScrollView {
            VStack {
                GroupBox {
                    TextField("Enter Competition Name", text: $competitionName) { _ in

                    } onCommit: {

                    }
                }

                GroupBox(label: Text("Pick competition end date").foregroundColor(Color(UIColor.tertiaryLabel)),
                         content: {
                    Picker("Pick competition end date", selection: $pickedDate) {
                        Text("1 Day").tag(0)
                        Text("7 Days").tag(1)
                        Text("1 Month").tag(2)
                        Text("Custom").tag(3)
                    }.pickerStyle(SegmentedPickerStyle())

                    // TODO: Add animation to this thing
                    if pickedDate == 3 {
                        DatePicker("", selection: $competitionEndDate)
                            .frame(maxHeight: 70)
                    }
                })

                GroupBox {
                    Button("Invite friends") {
                        // TODO: Hanlde invite friends
                    }
                    .frame(maxWidth: .infinity)
                }

                Spacer()

                RoundedButton("Start the competition") {
                    guard !competitionName.isEmpty else { return }
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(competitionName.isEmpty)
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
