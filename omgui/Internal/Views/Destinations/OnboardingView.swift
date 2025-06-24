//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 9/18/24.
//

import SwiftUI


struct OnboardingView: View {
    
    @Namespace
    var namespace
    
    @AppStorage("app.lol.terms")
    var acceptedTerms: TimeInterval = 0
    
    @Environment(\.dismiss)
    var dismiss
    
    @State
    var preview: Bool = true
    
    @State
    var appear: Bool = false
    
    @State
    var safety: Bool = false
    
    @State
    var sampleModel: SceneModel = .sample
    var menuBuilder: ContextMenuBuilder<AddressModel> = .init()
    
    @State
    var blocked: [AddressName] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            if preview {
                VStack {
                    LogoView(preview ? 88 : 44)
                        .matchedGeometryEffect(id: "logo", in: namespace)
                    ThemedTextView(text: "app.lol", font: .largeTitle)
                        .foregroundStyle(Color.lolAccent)
                        .matchedGeometryEffect(id: "title", in: namespace)
                }
                .frame(maxWidth: .infinity)
                .padding(.top)
            } else {
                HStack {
                    LogoView(preview ? 88 : 44)
                        .matchedGeometryEffect(id: "logo", in: namespace)
                    ThemedTextView(text: "app.lol", font: .title)
                        .foregroundStyle(Color.lolAccent)
                        .matchedGeometryEffect(id: "title", in: namespace)
                }
                .frame(maxWidth: .infinity)
                .padding(.top)
            }
            
            Text("an omg.lol client")
                .font(.headline)
                .fontDesign(.serif)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.secondary)
            
            if !preview {
                Spacer()
                    .onAppear {
                        Task {
                            try? await Task.sleep(nanoseconds: 1_250_000_000)
                            Task { @MainActor in
                                appear = true
                            }
                        }
                    }
                ThemedTextView(text: "welcome to the omg.lol community", font: .title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                if !appear {
                    Spacer()
                    Spacer()
                } else {
                    ScrollView(.vertical) {
                        if safety {
                            Text("a moment for safety")
                                .font(.headline)
                                .fontDesign(.serif)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)
                            
                            
                            Text("practice blocking and reporting addresses below")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)

                            if blocked.count < 3 {
                                Text("long press on the address and open the Safety menu for Block and Report options")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .fontDesign(.rounded)
                                    .padding(.horizontal)
                                    .padding(.bottom)
                                
                                VStack {
                                    ForEach(["crypt0pal", "memefact0ry", "ferdafan$"]) { address in
                                        if !blocked.contains(address) {
                                            ListRow(model: AddressModel(name: address))
                                                .environment(\.colorScheme, .light)
                                                .contextMenu(menuItems: {
                                                    Menu {
                                                        Button(role: .destructive, action: {
                                                            blocked.append(address)
                                                        }, label: {
                                                            Label("Block", systemImage: "eye.slash.circle")
                                                        })
                                                        
                                                        ReportButton(addressInQuestion: address, overrideAction: { blocked.append(address) })
                                                    } label: {
                                                        Label("Safety", systemImage: "hand.raised")
                                                    }
                                                }) {
                                                    ListRow(model: AddressModel(name:address), selected: .constant(nil))
                                                        .environment(\.colorScheme, .light)
                                                        .environment(sampleModel)
                                                }
                                        }
                                    }
                                }
                                .background(NavigationDestination.directory.gradient)
                                .frame(maxWidth: 425)
                            } else {
                                Spacer()
                            }
                            
                            Button(action: acceptTerms) {
                                Label(blocked.isEmpty ? "send me in" : "start exploring", systemImage: "heart.fill")
                                    .font(.headline)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: 500)
                            }
                            .buttonStyle(.borderedProminent)
                            .padding(.vertical, 16)
                            .padding(.top)
                            .padding()
                        } else {
                            Text("before you start exploring")
                                .font(.headline)
                                .fontDesign(.serif)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)
                            
                            Text("please review our community guidelines and expectiations")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fontDesign(.rounded)
                                .padding(.horizontal)
                            
                            ThemedTextView(text: "app.lol Terms of Service", font: .title3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top)
                                .padding(.horizontal)
                        
                            VStack(alignment: .leading, spacing: 16) {
                                
                                Text("**Last updated**: Oct 02, 2024")
                                    .font(.subheadline)
                                
                                ThemedTextView(text: "Welcome to app.lol!", font: .headline)
                                Text("""
                                By using this application, which accesses and displays data from the [omg.lol platform](https://home.omg.lol), you agree to comply with the following Terms of Service. 
                                
                                These terms are intended to ensure a safe and respectful environment for all users and are based on the community guidelines set forth by omg.lol.
                                """)
                                
                                ThemedTextView(text: "1. Acceptance of Terms", font: .headline)
                                Text("""
                                 By downloading, installing, or using app.lol, you acknowledge that you have read, understood, and agree to be bound by these Terms of Service, the Acceptable Use Policy, and the Code of Conduct of omg.lol. If you do not agree to these terms, you must discontinue use of the app.
                                 """)
                                
                                ThemedTextView(text: "2. Access to omg.lol Data", font: .headline)
                                Text("app.lol provides third-party access to certain public data available on omg.lol. While we strive to ensure the data displayed is accurate and current, we are not responsible for the completeness, accuracy, or availability of data from omg.lol. The use of this data is subject to omg.lol’s terms and conditions.")
                                
                                ThemedTextView(text: "3. User Conduct", font: .headline)
                                Text("""
                                 Users are expected to follow the same community expectations and standards set by omg.lol when using app.lol. This includes, but is not limited to:
                                 
                                 No harassment, abuse, or hateful behavior
                                 No spamming or engaging in malicious activities
                                 No use of the app to violate any local, state, or federal laws
                                 """)

                                
                                ThemedTextView(text: "4. Reporting Abuse", font: .headline)
                                Text("""
                                We take reports of abuse seriously. If you encounter abuse or violations of these terms while using app.lol, please report it by emailing us at app@omg.lol. We will promptly investigate any reported incidents within 24 hours and take appropriate action in accordance with our policies.
                                """)
                                
                                ThemedTextView(text: "5. Blocking Accounts", font: .headline)
                                Text("app.lol allows users to block certain accounts from displaying within the app. This feature is intended to give users more control over their experience. Blocking an account in app.lol does not block or affect that account on omg.lol directly.")
                                
                                ThemedTextView(text: "6. Authentication and Additional Features", font: .headline)
                                Text("""
                                Authenticated users gain access to additional features such as following other omg.lol addresses, viewing their followers, and editing their profile. All interactions and content updates, including profile changes, must comply with the omg.lol Terms of Service, Acceptable Use Policy, and Code of Conduct.
                                """)

                                ThemedTextView(text: "7. Responsibility of Content", font: .headline)
                                Text("""
                                While we strive to maintain a safe and respectful environment, you acknowledge that app.lol is not responsible for user-generated content or interactions within the app. All content accessed and displayed, including authenticated profile updates, is the responsibility of the original omg.lol account holders and must comply with omg.lol’s community guidelines.
                                """)
                                
                                ThemedTextView(text: "8. Changes to These Terms", font: .headline)
                                Text("We may update these Terms of Service from time to time. When we do, we will post the updated terms here, and the 'Last updated' date at the top of this document will reflect the date of the most recent changes. Continued use of app.lol following any updates constitutes your acceptance of those changes.")
                                
                                ThemedTextView(text: "9. Limitation of Liability", font: .headline)
                                Text("app.lol and its developers are not liable for any indirect, incidental, or consequential damages resulting from the use of the app or reliance on the information provided.")
                                
                                ThemedTextView(text: "10. Termination", font: .headline)
                                Text("We reserve the right to terminate or suspend access to app.lol without prior notice for users who violate these terms or engage in prohibited behavior.")
                                
                                ThemedTextView(text: "Contact Us", font: .headline)
                                Text("If you have any questions about these Terms of Service or encounter issues while using app.lol, please contact us at app@omg.lol")
                            }
                            .multilineTextAlignment(.leading)
                            .padding()
                            #if canImport(UIKit) && !os(tvOS)
                            .background(Color(uiColor: .systemBackground))
                            #endif
                            .clipShape(RoundedRectangle(cornerSize: .init(width: 16, height: 16)))
                            .padding(.horizontal)
                            .padding(.bottom)
                            .frame(maxWidth: 800)
                            .interactiveDismissDisabled()
                            
                            Text("By using app.lol, you agree to comply with this Terms of Service and help maintain a positive community.")
                                .padding(.horizontal)
                            
                            Button(action: {
                                acceptedTerms = Date().timeIntervalSince1970
                                safety = true
                            }) {
                                Label("accept community terms", systemImage: "checkmark")
                                    .font(.headline)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: 500)
                            }
                            .buttonStyle(.borderedProminent)
                            .padding(.vertical, 16)
                            .padding()
                        }
                    }
                }
            }
        }
        .environment(\.viewContext, .column)
        .environment(sampleModel)
        .frame(maxWidth: 800, maxHeight: .infinity)
        .frame(maxWidth: .infinity)
        .ignoresSafeArea(.container, edges: .bottom)
        .background(Material.ultraThin)
        .animation(.smooth(duration: 0.75), value: preview)
        .animation(.smooth(duration: 0.25), value: appear)
        .animation(.smooth(duration: 0.25), value: safety)
        .animation(.easeInOut(duration: 0.25), value: blocked)
        .onAppear {
            Task {
                try? await Task.sleep(nanoseconds: 1_750_000_000)
                Task { @MainActor in
                    preview = false
                }
            }
        }
    }
    
    private func acceptTerms() {
        acceptedTerms = Date().timeIntervalSince1970
        dismiss()
    }
}
