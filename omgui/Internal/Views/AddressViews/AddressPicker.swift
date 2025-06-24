//
//  AddressPicker.swift
//  
//
//  Created by Calvin Chestnut on 6/22/24.
//

import SwiftUI

struct AddressPicker: View {
    @Environment(SceneModel.self)
    var scene
    @Environment(AccountAuthDataFetcher.self)
    var authFetcher
    
    @SceneStorage("app.lol.address")
    var actingAddress: AddressName = ""
    
    @State
    var expandAddresses: Bool = false
    @State
    var showConfirmLogout: Bool = false
    
    private var myOtherAddresses: [AddressName] {
        scene.addressBook.myOtherAddresses
    }
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            if scene.addressBook.signedIn {
                if expandAddresses {
                    selectionView
                }
                activeAddressLabel
            } else {
                signInButton
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        #if !os(tvOS)
        .background(Material.bar)
        #endif
        .alert("Are you sure?", isPresented: $showConfirmLogout, actions: {
            Button("Cancel", role: .cancel) { }
            Button(
                "Yes",
                role: .destructive,
                action: {
                    authFetcher.logout()
                })
        }, message: {
            Text("Are you sure you want to sign out of omg.lol?")
        })
    }
    
    @ViewBuilder
    var activeAddressLabel: some View {
        ListRow<AddressModel>(
            model: .init(name: actingAddress),
            preferredStyle: .minimal
        )
        .onTapGesture {
            withAnimation {
                expandAddresses.toggle()
            }
        }
    }
    
    @ViewBuilder
    var signInButton: some View {
        Button {
            expandAddresses = false
            authFetcher.perform()
        } label: {
            Label {
                Text("sign in")
                    .font(.title3)
                    .bold()
                    .fontDesign(.serif)
            } icon: {
                Image("prami")
                    .resizable()
                    .frame(width: 33, height: 33)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .background(Color.lolRandom())
        .cornerRadius(16)
    }
    
    @ViewBuilder
    var selectionView: some View {
        HStack(alignment: .top, spacing: 2) {
            if !myOtherAddresses.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(myOtherAddresses) { address in
                        Button {
                            withAnimation {
                                expandAddresses = false
                                actingAddress = address
                            }
                        } label: {
                            AddressNameView(address)
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            
            Spacer()
        
            Button {
                withAnimation {
                    self.showConfirmLogout.toggle()
                }
            } label: {
                Text("Sign out")
                    .bold()
                    .font(.callout)
                    .fontDesign(.serif)
                    .padding(3)
            }
            .accentColor(.red)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 6))
            .padding(.trailing, 4)
        }
        .transition(
            .asymmetric(
                insertion: .move(edge: .bottom).combined(with: .opacity),
                removal: .move(edge: .bottom).combined(with: .opacity)
            )
        )
    }
}
