//
//  SignUpView.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct SignUpView: View {

    @Binding var showOnboarding: Bool
    @AppStorage("username") var username = ""
    @AppStorage("phone-number") var phoneNumber = ""

    var body: some View {
        VStack {
            Text("") // This makes the scrollview not break the navtitle.
            ScrollView {
                Text("REQUIRED")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 32)
                GroupBox {
                    TextField("Name", text: $username) { didChange in
                        print(didChange)
                    } onCommit: {
                        print("Commited")
                    }
                }
                GroupBox {
                    TextField("Username", text: $username) { didChange in
                        print(didChange)
                    } onCommit: {
                        print("Commited")
                    }
                }
                
                Text("OPTIONAL")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 32)
                GroupBox {
                    TextField("Phone Number", text: $phoneNumber) { _ in
                        phoneNumber = format(with: "+X (XXX) XXX-XXXX", phone: phoneNumber)
                    } onCommit: {
                        print("Commited")
                    }
                    .onChange(of: phoneNumber) { _ in
                        phoneNumber = format(with: "+X (XXX) XXX-XXXX", phone: phoneNumber)
                    }
                }
                Text("This will be used so other people with your contact can discover you.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Spacer()
            RoundedNavigationLink(
                "Continue", destination: GrantDataAccessView(showOnboarding: $showOnboarding)
            )
        }
        .padding(.horizontal)
        .navigationTitle("Sign Up")
    }

    func format(with mask: String, phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex // numbers iterator

        // iterate over the mask characters until the iterator of numbers ends
        for char in mask where index < numbers.endIndex {
            if char == "X" {
                // mask requires a number in this place, so take the next one
                result.append(numbers[index])

                // move numbers iterator to the next index
                index = numbers.index(after: index)

            } else {
                result.append(char) // just append a mask character
            }
        }
        return result
    }
}

struct SignIn_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SignUpView(showOnboarding: .constant(true))
        }
    }
}
