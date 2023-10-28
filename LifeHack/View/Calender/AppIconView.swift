//
//  AppIconView.swift
//  LifeHack
//
//  Created by sawamoren on 2023/09/07.
//

import SwiftUI

struct AppIconView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("isAppicon1") var isAppicon1 = true
    @AppStorage("isAppicon2") var isAppicon2 = false
    @AppStorage("isAppicon3") var isAppicon3 = false
    @AppStorage("seletingAppIcon") var seletingAppIcon: Int = 1
    var body: some View {
        VStack {
            Text(LocalizedStringKey("AppIcon"))
                .font(.title3.bold())
                .overlay {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("<")
                            .font(.title)
                            .tint(.black.opacity(0.8))
                    })
                    .frame(width:  UIScreen.main.bounds.width * 0.9, alignment: .leading)
                }
                .padding(.top,20)
            List {
                Toggle(isOn: $isAppicon1) {
                    Image("appimage")
                        .resizable()
                        .cornerRadius(10)
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.25, height: UIScreen.main.bounds.height * 0.08)
                }
                .disabled(isAppicon1)
                .onChange(of: isAppicon1) { newValue in
                    if newValue {
                        seletingAppIcon = 1
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            UIApplication.shared.setAlternateIconName(nil)
                        }
                        isAppicon2 = false
                        isAppicon3 = false
                    }
                }
                Toggle(isOn: $isAppicon2) {
                    Image("appimage2")
                        .resizable()
                        .cornerRadius(10)
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.25, height: UIScreen.main.bounds.height * 0.08)
                }
                .onChange(of: isAppicon2) { newValue in
                    if newValue {
                        seletingAppIcon = 2
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            UIApplication.shared.setAlternateIconName("AppIcon2", completionHandler: nil)
                        }
                        isAppicon1 = false
                        isAppicon3 = false
                    }
                }
                .disabled(isAppicon2)
                Toggle(isOn: $isAppicon3) {
                    Image("appimage3")
                        .resizable()
                        .cornerRadius(10)
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.25, height: UIScreen.main.bounds.height * 0.08)
                }
                .disabled(isAppicon3)
                .onChange(of: isAppicon3) { newValue in
                    if newValue {
                        seletingAppIcon = 3
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            UIApplication.shared.setAlternateIconName("AppIcon3", completionHandler: nil)
                        }
                        isAppicon2 = false
                        isAppicon1 = false
                    }
                }
            }
            .listStyle(.grouped)
        }
        .background(Color.white)
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarBackButtonHidden(true)
    }
}

struct AppIconView_Previews: PreviewProvider {
    static var previews: some View {
        AppIconView()
    }
}
