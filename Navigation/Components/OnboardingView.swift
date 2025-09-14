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
    
    @AppStorage("lol.terms")
        var acceptedTerms: TimeInterval = 0
    
    @Environment(\.dismiss)
        var dismiss
    
    @State
        var logoHighlight: Bool = true
    @State
        var showDetails: Bool = false
    @State
        var safetyTraining: Bool = false
    
    @State
        var fakeBlocklist: [AddressName] = []
    
    var fakeDirectory: [AddressName] {
        [
            "crypt0pal",
            "m3m3factry",
            "ferdafan",
        ]
    }
    
    private let menuBuilder: ContextMenuBuilder<AddressModel> = .init()
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                LogoView(logoHighlight ? 88 : 44)
                    .matchedGeometryEffect(id: "logo", in: namespace)
                ThemedTextView(text: "app.lol", font: .largeTitle)
                    .foregroundStyle(Color.lolAccent)
                    .matchedGeometryEffect(id: "title", in: namespace)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 32)
            
            Text("an omg.lol client")
                .font(.headline)
                .fontDesign(.serif)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.secondary)
            
            if !logoHighlight {
                Spacer()
                    .onAppear {
                        Task {
                            try? await Task.sleep(nanoseconds: 1_250_000_000)
                            Task { @MainActor in
                                showDetails = true
                            }
                        }
                    }
                ThemedTextView(text: "Welcome to the omg.lol community", font: .title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                if !showDetails {
                    Spacer()
                    Spacer()
                } else {
                    ScrollView(.vertical) {
                        termsAndConditionsView()
                    }
                }
            }
        }
        .environment(\.viewContext, .column)
        .frame(maxWidth: 800, maxHeight: .infinity)
        .frame(maxWidth: .infinity)
        .ignoresSafeArea(.container, edges: .bottom)
        .background(Material.thin)
        .animation(.smooth(duration: 0.75), value: logoHighlight)
        .animation(.smooth(duration: 0.25), value: showDetails)
        .animation(.smooth(duration: 0.25), value: safetyTraining)
        .animation(.easeInOut(duration: 0.25), value: fakeBlocklist)
        .task {
            try? await Task.sleep(nanoseconds: 1_750_000_000)
            logoHighlight = false
        }
    }
    
    @ViewBuilder
    func termsAndConditionsView() -> some View {
        Text("Before you start exploring")
            .font(.headline)
            .fontDesign(.serif)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(.secondary)
            .padding(.horizontal)
        
        Text("Please review our community guidelines and expectiations")
            .frame(maxWidth: .infinity, alignment: .leading)
            .fontDesign(.rounded)
            .padding(.horizontal)
        
        ThemedTextView(text: "app.lol Terms of Service", font: .title3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top)
            .padding(.horizontal)
    
        VStack(alignment: .leading, spacing: 16) {
            
            Text("**Last updated**: Sep 12, 2025")
                .font(.subheadline)

            ThemedTextView(text: "Welcome to app.lol", font: .headline)
            Text("""
            app.lol is an independent third-party client for viewing and updating content on the [omg.lol](https://home.omg.lol) platform. It is not owned by or affiliated with omg.lol. By using this app, you agree to these Terms of Service (“these terms”).
            """)

            ThemedTextView(text: "1. Acceptance of terms", font: .headline)
            Text("""
            Your use of app.lol requires compliance with omg.lol’s **Terms of Service**, **Acceptable Use Policy**, and **Code of Conduct**. See https://home.omg.lol/info/legal for details. If you do not agree, discontinue use of the app.
            """)

            ThemedTextView(text: "2. Access to omg.lol data", font: .headline)
            Text("""
            The app displays omg.lol data and, if you sign in, can perform actions through the omg.lol API. We make no guarantees about completeness, accuracy, or availability. Use of omg.lol data remains subject to omg.lol’s terms.
            """)

            ThemedTextView(text: "3. User conduct", font: .headline)
            Text("""
            When using app.lol, you must follow omg.lol’s community standards. Prohibited conduct includes harassment, abuse, hateful behavior, spam, malicious activity, or unlawful use. Violations may result in loss of access.
            """)

            ThemedTextView(text: "4. Reporting abuse", font: .headline)
            Text("""
            To report abuse related to omg.lol, email **abuse@omg.lol**. For issues specific to this app, email **app@omg.lol**. Reports will be reviewed and addressed as quickly as possible.
            """)

            ThemedTextView(text: "5. Blocking accounts", font: .headline)
            Text("""
            You may block accounts in app.lol to hide their content. This does not affect the blocked account on omg.lol directly.
            """)

            ThemedTextView(text: "6. Authentication and features", font: .headline)
            Text("""
            Signing in enables features such as following addresses, viewing followers, and editing your profile. All authenticated actions and content remain subject to omg.lol’s Terms of Service, Acceptable Use Policy, and Code of Conduct.
            """)

            ThemedTextView(text: "7. Content responsibility", font: .headline)
            Text("""
            All user-generated content is the responsibility of the omg.lol account holders who created it. app.lol does not create, control, or endorse such content and is not responsible for it. Content must comply with omg.lol’s community guidelines.
            """)

            ThemedTextView(text: "8. Privacy", font: .headline)
            Text("""
            app.lol does not collect personal information beyond what is required for authentication. OAuth tokens are stored to identify your session. We do not sell, share, or track your activity. For details, see our Privacy Policy.
            """)

            ThemedTextView(text: "9. Changes to these terms", font: .headline)
            Text("""
            We may revise these terms from time to time. Updates will be posted here, with the “Last updated” date reflecting the current version. Continued use of app.lol constitutes acceptance of changes.
            """)

            ThemedTextView(text: "10. Limitation of liability", font: .headline)
            Text("""
            app.lol and it's developers are not liable for indirect, incidental, special, or consequential damages arising from use of the app or reliance on displayed information.
            """)

            ThemedTextView(text: "Contact us", font: .headline)
            Text("""
            For questions or issues regarding app.lol, email **app@omg.lol**. 
            
            For omg.lol platform policies and abuse reporting, visit https://home.omg.lol/info/legal and https://home.omg.lol/info/abuse
            """)
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
        
        Button(action: acceptTerms) {
            Label("accept community terms", systemImage: "checkmark")
                .font(.headline)
                .padding(.vertical, 8)
                .frame(maxWidth: 500)
        }
        .buttonStyle(.borderedProminent)
        .padding(.vertical, 16)
        .padding()
    }
    
    private func acceptTerms() {
        acceptedTerms = Date().timeIntervalSince1970
        dismiss()
    }
    
//    @ViewBuilder
//    func safetyTrainingView() -> some View {
//        Text("A moment for safety")
//            .font(.headline)
//            .fontDesign(.serif)
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .foregroundStyle(.secondary)
//            .padding(.horizontal)
//        
//        
//        Text("Practice blocking and reporting addresses below")
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .padding(.horizontal)
//
//        if fakeBlocklist.count < 3 {
//            Text("long press on the address and open the Safety menu for Block and Report options")
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .fontDesign(.rounded)
//                .padding(.horizontal)
//                .padding(.bottom)
//            
//            VStack {
//                ForEach(
//                    fakeDirectory
//                        .filter({ address in
//                            !fakeBlocklist
//                                .contains(where: { $0 == address.lowercased() })
//                        })
//                ) { address in
//                    ListRow(model: AddressModel(name: address))
//                        .environment(\.colorScheme, .light)
//                        .contextMenu(menuItems: {
//                            Menu {
//                                Button(role: .destructive, action: {
//                                    fakeBlocklist.append(address)
//                                }, label: {
//                                    Label("Block", systemImage: "eye.slash.circle")
//                                })
//                                
//                                ReportButton(addressInQuestion: address, overrideAction: { fakeBlocklist.append(address) })
//                            } label: {
//                                Label("Safety", systemImage: "hand.raised")
//                            }
//                        })
//                }
//            }
//            .background(NavigationDestination.directory.gradient)
//            .frame(maxWidth: 425)
//        } else {
//            Spacer()
//        }
//        
//        Button(action: acceptTerms) {
//            Label(fakeBlocklist.isEmpty ? "send me in" : "start exploring", systemImage: "heart.fill")
//                .font(.headline)
//                .padding(.vertical, 8)
//                .frame(maxWidth: 500)
//        }
//        .buttonStyle(.borderedProminent)
//        .padding(.vertical, 16)
//        .padding(.top)
//        .padding()
//    }
}

#Preview {
    
    @Previewable
    @State
    var sheet = true
    
    Text("Body")
        .sheet(isPresented: $sheet) {
            OnboardingView()
        }
}
