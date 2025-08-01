//
//  MultiUserManagementView.swift
//  ConfigHub
//
//  Created by Raul Flores on 7/30/25.
//
import SwiftUI

// A simple struct to represent a team member for the view's mock data
struct TeamMember: Identifiable {
    let id = UUID()
    let name: String
    let email: String
    let role: String
    let status: String
}

struct MultiUserManagementView: View {
    // This property receives the context from the FeatureViewFactory
    let contexts: [String]
    
    // A computed property to determine the provider name from the context
    private var providerName: String {
        if let context = contexts.first(where: { $0.contains("business") }) {
            return context.split(separator: "_").first?.capitalized ?? "Your"
        }
        return "Your"
    }

    // Mock data for a realistic UI
    let teamMembers: [TeamMember] = [
        TeamMember(name: "Alice Johnson", email: "alice@example.com", role: "Admin", status: "Active"),
        TeamMember(name: "Bob Williams", email: "bob@example.com", role: "Member", status: "Active"),
        TeamMember(name: "Charlie Brown", email: "charlie@example.com", role: "Member", status: "Pending")
    ]
    
    var body: some View {
        List {
            // Section for adding new users
            Section {
                Button(action: {
                    // Action to invite a new member
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Invite New Member")
                    }
                }
            }
            
            // Section to display the list of current team members
            Section(header: Text("\(providerName) Team")) {
                ForEach(teamMembers) { member in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(member.name)
                                .fontWeight(.semibold)
                            Text(member.email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(member.role)
                                .font(.headline)
                            Text(member.status)
                                .font(.caption)
                                .foregroundColor(member.status == "Active" ? .green : .orange)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Manage Team")
    }
}
