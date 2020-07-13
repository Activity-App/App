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
    
    @State var move = true
    @State var exercise = true
    @State var stand = true
    @State var steps = false
    @State var stepsGoal = 10000
    @State var distance = false
    @State var distanceGoal = 10

    var body: some View {
        NavScrollView {
            RoundedTextField("Competition Name", text: $competitionName)
                .padding(.bottom, 8)

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
                                AnyTransition.asymmetric(
                                    insertion: AnyTransition.opacity.animation(.easeInOut),
                                    removal: AnyTransition.identity
                                )
                            )
                    }
                }
                .padding(16)
            }
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .frame(minHeight: 50)
                    .foregroundColor(Color(.secondarySystemBackground))
            )
            .padding(.bottom, 8)
            
            Group {
                VStack {
                    Text("Compete with:")
                        .foregroundColor(Color(.tertiaryLabel))
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Toggle("Move", isOn: $move)
                    Toggle("Exercise", isOn: $exercise)
                    Toggle("Stand", isOn: $stand)
                    Toggle("Steps", isOn: $steps)
                    if steps {
                        VStack {
                            HStack {
                                Image(systemName: "chevron.down")
                                    .foreground(Color(.tertiaryLabel))
                                Stepper("Goal", value: $stepsGoal, in: 1000...50000, step: 1000)
                            }
                            Text("\(stepsGoal) steps")
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .transition(
                            AnyTransition.asymmetric(insertion: AnyTransition.opacity.animation(.easeInOut), removal: AnyTransition.identity
                            )
                        )
                    }
                    Toggle("Walking/Running Distance", isOn: $distance)
                    if distance {
                        VStack {
                            HStack {
                                Image(systemName: "chevron.down")
                                    .foreground(Color(.tertiaryLabel))
                                Stepper("Goal", value: $distanceGoal, in: 1...100, step: 1)
                            }
                            Text("\(distanceGoal) km")
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .transition(
                            AnyTransition.asymmetric(insertion: AnyTransition.opacity.animation(.easeInOut), removal: AnyTransition.identity
                            )
                        )
                    }
                }
                .padding(16)
            }
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .frame(minHeight: 50)
                    .foregroundColor(Color(.secondarySystemBackground))
            )
            .padding(.bottom, 8)
            
            Group {
                VStack {
                    Button("Invite friends") {
                        // TODO: Handle invite friends
                        withAnimation(.easeInOut) {
                            invitedFriends.append("nmsdnjosadn\(Int.random(in: 0...100))")
                            invitedFriends.append("nmsdnjosadn\(Int.random(in: 0...100))")
                            invitedFriends.append("nmsdnjosadn\(Int.random(in: 0...100))")
                            invitedFriends.append("nmsdnjosadn\(Int.random(in: 0...100))")
                            invitedFriends.append("nmsdnjosadn\(Int.random(in: 0...100))")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(PlainButtonStyle())

                    if !invitedFriends.isEmpty {
                        List(invitedFriends.indices) { index in
                            Section {
                                Text(invitedFriends[index])
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                        .frame(height: 200)
                    }
                }
                .padding(16)
            }
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .frame(minHeight: 50)
                    .foregroundColor(Color(.secondarySystemBackground))
            )
            .padding(.bottom, 8)

            RoundedButton("Start the competition") {
                guard !competitionName.isEmpty else { return }
                presentationMode.wrappedValue.dismiss()
            }
            .disabled(competitionName.isEmpty)
        }
        .padding(.horizontal)
        .navigationBarTitle("Create Competition")
    }
}

struct CreateCompetition_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CreateCompetition()
        }
    }
}
