//
//  CreateCompetition.swift
//  Project SF
//
//  Created by Roman Esin on 12.07.2020.
//

import SwiftUI

struct CreateCompetition: View {

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.locale) var locale
    @State var competitionName = ""
    @State var competitionEndDate = Date() + 60 * 60 * 24
    @State var pickedDate = 0
    @State var invitedFriends: [String] = []
    
    @State var move = true
    @State var exercise = true
    @State var stand = true
    @State var steps = false
    @State var stepsGoal = "10000"
    @State var stepsGoalInt = 10000
    @State var distance = false
    @State var distanceGoal = "10"
    @State var distanceGoalInt = 10
    
    let competitionController = CompetitionsController()

    var body: some View {
        ScrollView(showsIndicators: false) {
            
            Text("Create Competition")
                .font(.largeTitle)
                .bold()
                .padding(.top, 48)
                .frame(maxWidth: .infinity, alignment: .leading)
                
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
                                Stepper("Goal") {
                                    stepsGoalInt = min(50000, max(1000, stepsGoalInt + 1000))
                                    stepsGoal = String(stepsGoalInt)
                                } onDecrement: {
                                    stepsGoalInt = min(50000, max(1000, stepsGoalInt - 1000))
                                    stepsGoal = String(stepsGoalInt)
                                }
                                .opacity(Int(stepsGoal) == nil ? 1 : 1) // Fixes stepper issue.
                            }
                            HStack {
                                Spacer()
                                TextField("Amount", text: $stepsGoal, onEditingChanged: { _ in
                                    stepsGoalInt = min(50000, max(1000, Int(stepsGoal) ?? 10000))
                                    stepsGoal = String(stepsGoalInt)
                                })
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                Text("steps")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .transition(
                            AnyTransition.asymmetric(insertion: AnyTransition.opacity.animation(.easeInOut),
                                                     removal: AnyTransition.identity)
                        )
                    }
                    Toggle("Walking/Running Distance", isOn: $distance)
                    if distance {
                        VStack {
                            HStack {
                                Image(systemName: "chevron.down")
                                    .foreground(Color(.tertiaryLabel))
                                Stepper("Goal") {
                                    distanceGoalInt = min(
                                        locale.usesMetricSystem ? 1000 : 600,
                                        max(1, distanceGoalInt + 1)
                                    )
                                    distanceGoal = String(distanceGoalInt)
                                } onDecrement: {
                                    distanceGoalInt = min(
                                        locale.usesMetricSystem ? 1000 : 600,
                                        max(1, distanceGoalInt - 1)
                                    )
                                    distanceGoal = String(distanceGoalInt)
                                }
                                .opacity(Int(distanceGoal) == nil ? 1 : 1) // Fixes stepper issue.
                            }
                            HStack {
                                Spacer()
                                TextField("Amount", text: $distanceGoal, onEditingChanged: { _ in
                                    distanceGoalInt = min(
                                        locale.usesMetricSystem ? 1000 : 600,
                                        max(1, Int(distanceGoal) ?? 10)
                                    )
                                    distanceGoal = String(distanceGoalInt)
                                })
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                Text(locale.usesMetricSystem ? "km" : "miles")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .transition(
                            AnyTransition.asymmetric(insertion: AnyTransition.opacity.animation(.easeInOut),
                                                     removal: AnyTransition.identity)
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
                    .foregroundColor(.accentColor)

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
                
                competitionController.createCompetition(
                    type: .init(
                        move: move,
                        exercise: exercise,
                        stand: stand,
                        steps: steps,
                        distance: distance,
                        stepsGoal: stepsGoalInt,
                        distanceGoal: distanceGoalInt
                    ),
                    title: competitionName,
                    endDate: competitionEndDate,
                    // TODO: Add support for inviting friends when creating competition.
                    friends: [],
                    then: { result in
                        print(result)
                    }
                )
                
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
        CreateCompetition()
    }
}
