//
//  BillingPortalView.swift
//  ConfigHub
//
//  Created by Raul Flores on 7/30/25.
//
import SwiftUI

struct Invoice: Identifiable {
    let id = UUID()
    let date: String
    let amount: Double
    let isPaid: Bool
}

struct BillingPortalView: View {
    let contexts: [String]
    private var isComboUser: Bool { contexts.count > 1 }

    let personalInvoices: [Invoice] = [Invoice(date: "July 1, 2025", amount: 120.00, isPaid: true)]
    let businessInvoices: [Invoice] = [Invoice(date: "July 1, 2025", amount: 850.00, isPaid: true)]
    
    var body: some View {
        List {
            if isComboUser {
                BillingSection(title: "Personal Plan Bill", amount: 125.00, dueDate: "August 1, 2025", history: personalInvoices)
                BillingSection(title: "Business Plan Bill", amount: 875.00, dueDate: "August 1, 2025", history: businessInvoices)
            } else {
                BillingSection(title: "Current Bill", amount: 125.00, dueDate: "August 1, 2025", history: personalInvoices)
            }
        }
        .navigationTitle("Billing Portal")
    }
}

struct BillingSection: View {
    let title: String, amount: Double, dueDate: String, history: [Invoice]
    var body: some View {
        Section(header: Text(title)) {
            VStack(alignment: .leading) {
                Text(String(format: "$%.2f", amount)).font(.largeTitle).fontWeight(.bold)
                Text("Due \(dueDate)").font(.subheadline).foregroundStyle(.secondary)
            }.padding(.vertical)
            Button("Pay Now") {}
            
            Section(header: Text("Payment History")) {
                ForEach(history) { invoice in
                    HStack {
                        Text(invoice.date)
                        Spacer()
                        Text(String(format: "$%.2f", invoice.amount))
                    }
                }
            }
        }
    }
}
