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
    @State var invitedFriends: [String] = []

    var body: some View {
//        ScrollView {
            VStack {
                RoundedTextField("Competition Name", text: $competitionName) { _ in

                } onCommit: {

                }
                .padding(.vertical, 8)

                Group {
                    VStack {
                        Text("End Date")
                            .foregroundColor(Color(.tertiaryLabel))
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Picker("Pick competition end date", selection: $pickedDate) {
                            Text("1 Day").tag(0)
                            Text("7 Days").tag(1)
                            Text("1 Month").tag(2)
                            Text("Custom").tag(3)
                        }.pickerStyle(SegmentedPickerStyle())
                        if pickedDate == 3 {
                            DatePicker("", selection: $competitionEndDate)
                                .frame(maxHeight: 50)
                                .transition(
                                    AnyTransition
                                        .opacity.animation(.easeInOut)
                                        .combined(with: AnyTransition
                                                    .move(edge: .top)
                                                    .animation(.easeInOut)))
                                .padding(.trailing, 8)
                        }
                    }
                    .padding(16)
                }
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .frame(minHeight: 50)
                        .foregroundColor(Color(.secondarySystemBackground))
                )
                .animation(.easeInOut)
                .padding(.bottom, 8)
                
                Group {
                    VStack {
                        Button("Invite friends") {
                            // TODO: Hanlde invite friends
                            invitedFriends.append("nmsdnjosadn\(Int.random(in: 0...100))")
                        }
                        .frame(maxWidth: .infinity)

                        if !invitedFriends.isEmpty {
                            List(invitedFriends.indices) { index in
                                Section {
                                    Text(invitedFriends[index])
                                }
                            }
                            .listStyle(InsetGroupedListStyle())
                        }
                    }
                    .padding(16)
                }
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .frame(minHeight: 50)
                        .foregroundColor(Color(.secondarySystemBackground))
                )
                .animation(.easeInOut)
                .padding(.bottom, 8)

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
