//
//  SupportChatView.swift
//  ConfigHub
//
//  Created by Raul Flores on 7/30/25.
//
import SwiftUI

// A simple struct to model a chat message
struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isFromCurrentUser: Bool
}

struct SupportChatView: View {
    let contexts: [String]
    private var isComboUser: Bool { contexts.count > 1 }

    var body: some View {
        // Use a NavigationStack to allow drilling down into a specific chat
        NavigationStack {
            VStack {
                if isComboUser {
                    // Offer a clear choice for combo users
                    Text("Which service do you need help with?")
                        .font(.headline)
                        .padding()
                    
                    // Navigate to a chat view for the Personal plan
                    NavigationLink(destination: ChatDetailView(chatTitle: "Personal Support")) {
                        Text("Personal Plan Support")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Navigate to a chat view for the Business plan
                    NavigationLink(destination: ChatDetailView(chatTitle: "Business Support")) {
                        Text("Business Plan Support")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(UIColor.systemGray5))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                } else {
                    // For single-plan users, go directly to the chat view
                    ChatDetailView(chatTitle: "Support Chat")
                }
            }
        }
    }
}

// A new, reusable view that displays the actual chat interface
struct ChatDetailView: View {
    let chatTitle: String
    @State private var newMessage: String = ""

    // Mock messages for the chat interface
    let messages: [Message] = [
        Message(text: "Hello! How can I help you today?", isFromCurrentUser: false),
        Message(text: "Hi, I'm having an issue with my connection speed.", isFromCurrentUser: true),
        Message(text: "I can certainly help with that. Could you please run a diagnostic test from the Network Status screen?", isFromCurrentUser: false)
    ]
    
    var body: some View {
        VStack {
            // Scrollable view for all the messages
            ScrollView {
                VStack {
                    ForEach(messages) { message in
                        HStack {
                            if message.isFromCurrentUser {
                                Spacer()
                                Text(message.text)
                                    .padding(12)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                            } else {
                                Text(message.text)
                                    .padding(12)
                                    .background(Color(UIColor.systemGray5))
                                    .cornerRadius(16)
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            // Text input field at the bottom
            HStack {
                TextField("Type a message...", text: $newMessage)
                    .textFieldStyle(.roundedBorder)
                Button(action: {
                    // Action to send a message
                    // In a real app, you would add the message to an array
                    // and clear the text field.
                    print("Sending: \(newMessage)")
                    newMessage = ""
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title)
                }
                .disabled(newMessage.isEmpty)
            }
            .padding()
        }
        .navigationTitle(chatTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}
