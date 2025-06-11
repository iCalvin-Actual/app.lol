//
//  SwiftUIView.swift
//
//
//  Created by Calvin Chestnut on 5/2/23.
//

import SwiftUI

struct AccountView: View {
    @SceneStorage("app.lol.address")
    var actingAddress: AddressName = ""
    
    @Environment(\.colorScheme)
    var colorScheme
    
    @Environment(SceneModel.self)
    var sceneModel
    @Environment(AccountAuthDataFetcher.self)
    var authFetcher
    
    @State
    var searchAddress: String = ""
    @State
    var presentUpsell: Bool = false
    @State
    var forceUpdateState: Bool = false
    
    var availabilityText: String {
        "Enter an address to check availability"
    }
    
    var body: some View {
        ListsView(sceneModel: sceneModel)
    }
    
    @ViewBuilder
    var oldAccountBody: some View {
        appropriateBody
            .onChange(of: actingAddress, { oldValue, newValue in
                forceUpdateState.toggle()
            })
            .navigationBarTitleDisplayMode(.inline)
            .environment(\.viewContext, ViewContext.detail)
            .sheet(isPresented: $presentUpsell) {
                UpsellView()
            }
    }
    
    @ViewBuilder
    var appropriateBody: some View {
        if !(authFetcher.authKey?.wrappedValue ?? "").isEmpty {
            AddressSummaryView(
                selectedPage: .profile,
                addressSummaryFetcher: sceneModel.addressSummary(sceneModel.addressBook.actingAddress.wrappedValue)
            )
        } else {
            ScrollView {
                signedOutHeader
                
                VStack(alignment: .leading) {
                    Text("Start here")
                        .font(.caption2)
                        .fontDesign(.monospaced)
                        .foregroundStyle(Color.lolPurple)
                        .brightness(-0.5)
                    TextField("Search Address", text: $searchAddress, prompt: Text("Type your name"))
                        .padding(6)
                        .background(Color.white)
                        .cornerRadius(8)
                    Text(availabilityText)
                        .font(.caption)
                        .foregroundStyle(Color.lolPurple)
                        .brightness(-0.5)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.lolPurple)
                
                VStack(alignment: .leading) {
                    HStack {
                        Group {
                            Text("Already have an address on")
                            +
                            Text(" omg.lol")
                                .foregroundColor(.lolPink)
                            +
                            Text("?")
                        }
                        .bold()
                        .multilineTextAlignment(.leading)
                        .font(.title2)
                        .fontDesign(.serif)
                        foregroundStyle(Color.black)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    
                    HStack {
                        Button {
                            authFetcher.perform()
                        } label: {
                            Text("Sign in with omg.lol")
                                .bold()
                                .font(.callout)
                                .fontDesign(.serif)
                                .padding(3)
                        }
                        .accentColor(.lolPink)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.roundedRectangle(radius: 6))
                        Spacer()
                    }
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.lolBlue)
                
                
                VStack(alignment: .leading) {
                    HStack {
                        Group {
                            Text("Learn more about ")
                                .foregroundColor(Color.primary)
                            +
                            Text("omg.lol")
                                .foregroundColor(Color.lolPink)
                        }
                        .bold()
                        .multilineTextAlignment(.leading)
                        .font(.title2)
                        .fontDesign(.serif)
                        foregroundStyle(Color.black)
                        
                        Spacer()
                        
                        Image(systemName: "tree.fill")
                            .resizable()
                            .frame(width: 88, height: 88)
                            foregroundStyle(Color.lolGreen)
                            .brightness(-0.5)
                            .padding([.top, .trailing], 4)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Text("The best way to build your presence on the open web.")
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.headline)
                        .fontDesign(.monospaced)
                        foregroundStyle(Color.black)
                    
                    HStack {
                        Link(destination: URL(string: "https://home.omg.lol/referred-by/app")!) {
                            Text("Discover")
                                .bold()
                                .font(.callout)
                                .fontDesign(.serif)
                                .padding(3)
                        }
                        .accentColor(.lolPink)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.roundedRectangle(radius: 6))
                        Spacer()
                    }
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.lolGreen)
                
                VStack(alignment: .leading) {
                    HStack {
                        Group {
                            Text("The complete experience, on-the-go, with ")
                            +
                            Text("app.lol++")
                                foregroundStyle(Color.lolPink)
                        }
                        .bold()
                        .multilineTextAlignment(.leading)
                        .font(.title2)
                        .fontDesign(.serif)
                        foregroundStyle(Color.black)
                        
                        Spacer()
                        
                        Image(systemName: "app.badge.fill")
                            .resizable()
                            .frame(width: 88, height: 88)
                            foregroundStyle(Color.lolOrange)
                            .brightness(-0.5)
                            .padding([.top, .trailing], 4)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Text("Follow addresses, find new friends. Take the experience further with plus-plus.")
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.headline)
                        .fontDesign(.monospaced)
                        foregroundStyle(Color.black)
                    
                    HStack {
                        Button {
                            presentUpsell = true
                        } label: {
                            Text("app.lol ++")
                                .bold()
                                .font(.callout)
                                .fontDesign(.serif)
                                .padding(3)
                        }
                        .accentColor(.lolPink)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.roundedRectangle(radius: 6))
                        Spacer()
                    }
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.lolOrange)
                .padding(.bottom, 24)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ThemedTextView(text: "omg.lol?")
                }
            }
        }
    }
    
    @ViewBuilder
    var signedOutHeader: some View {
        VStack(alignment: .leading) {
            Text("Looking for the best internet address you've ever had?")
                .multilineTextAlignment(.center)
                .font(.title)
                .bold()
                .fontDesign(.serif)
                .foregroundColor(colorScheme == .dark ? .lolYellow : .lolTeal)
                .padding()
                .frame(maxWidth: .infinity)
            
            HStack {
                Text("Web Page")
                    foregroundStyle(Color.lolPink)
                Spacer()
                Text("Email Address")
                    foregroundStyle(Color.lolGreen)
                Spacer()
                Text("PasteBin")
                    foregroundStyle(Color.lolTeal)
                Spacer()
                Text("PURLs")
                    foregroundStyle(Color.lolBlue)
                Spacer()
                Text("StatusLog")
                    foregroundStyle(Color.lolPurple)
            }
            .bold()
            .dynamicTypeSize(.xSmall ... .xLarge)
            .font(.caption)
            .padding(.horizontal, 4)
        }
    }
}
