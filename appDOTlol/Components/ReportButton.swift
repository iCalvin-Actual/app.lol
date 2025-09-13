//
//  ReportButton.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 9/11/25.
//

import SwiftUI

struct ReportButton: View {
    @Environment(\.openURL)
    var openURL
    
    let addressInQuestion: AddressName?
    
    let overrideAction: (() -> Void)?
    
    init(addressInQuestion: AddressName? = nil, overrideAction: (() -> Void)? = nil) {
        self.addressInQuestion = addressInQuestion
        self.overrideAction = overrideAction
    }
    
    var body: some View {
        Button(action: overrideAction ?? {
            let subject = "app.lol content report"
            let body = "/*\nPlease describe the offending behavior, provide links where appropriate.\nWe will review the offending content as quickly as we can and respond appropriately.\n */ \nOffending address: \(addressInQuestion ?? "unknown")\nmy omg.lol address: \n\n"
            let coded = "mailto:app@omg.lol?subject=\(subject)&body=\(body)"
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

            if let coded = coded, let emailURL = URL(string: coded) {
                openURL(emailURL)
            }
        }, label: {
            Label("report", systemImage: "exclamationmark.bubble")
        })
    }
}
