//
//  MypageView.swift
//  LifeHack
//
//  Created by sawamoren on 2023/09/01.
//

import SwiftUI
import MessageUI

struct MypageView: View {
    @AppStorage("seletingAppIcon") var seletingAppIcon: Int = 1
    @Environment(\.dismiss) var dismiss
    @State private var isActive: Bool = false
    @State private var selectedCivilization: String? = nil
    @State private var showMailView = false
    @State private var showAlertController:Bool = false
    @State private var showAlert: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text(LocalizedStringKey("setting"))
                    .font(.title2 .bold())
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
                VStack {
                    Image(seletingAppIcon == 1 ? "appimage" : (seletingAppIcon == 2 ? "appimage2" : "appimage3"))
                        .resizable()
                        .cornerRadius(10)
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.3, height: UIScreen.main.bounds.height * 0.1)
                    Text("Life Hack")
                        .font(.title.bold())
                    Text("ver: 1.1.2")
                        .foregroundColor(.gray)
                }
                List {
                    NavigationLink(destination: AppIconView()) {
                        Text(LocalizedStringKey("appIcon"))
                        Spacer()
                    }
                    Button {
                        self.showMailView.toggle()
                    } label: {
                        HStack{
                            Text(LocalizedStringKey("contact"))
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: "paperplane")
                                .foregroundColor(.gray.opacity(0.7))
                                .font(.caption)
                        }
                    }
                    .sheet(isPresented: $showMailView, content: {
                        MailView(showMailView: self.$showMailView, showAlert: $showAlertController)
                    })
                    .alert(isPresented: $showAlert) {
                        SwiftUI.Alert(title: Text(LocalizedStringKey("mail")))
                    }
                    .onChange(of: showAlertController) { newValue in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            showAlert = true
                            showAlertController = false
                        }
                    }
                    
                    HStack {
                        if let url = URL(string:
                                            NSLocalizedString("website_url", comment: "")) {
                            Link("website", destination: url)
                                .foregroundColor(.black)
                        }
                        Spacer()
                        Image(systemName: "globe")
                            .foregroundColor(.gray.opacity(0.7))
                            .font(.caption)
                    }
                    HStack {
                        if let url = URL(string:
                                            NSLocalizedString("privacy_url", comment: "")) {
                            Link(NSLocalizedString("termsOfUse", comment: ""), destination: url)
                                .foregroundColor(.black)
                        }
                        Spacer()
                        Image(systemName: "questionmark.app")
                            .foregroundColor(.gray.opacity(0.7))
                            .font(.caption)
                    }
                }
                .listStyle(.grouped)
            }
            .background(Color.white)
        }
    }
}

struct MypageView_Previews: PreviewProvider {
    static var previews: some View {
        MypageView()
    }
}


struct MailView: UIViewControllerRepresentable {
    @Binding var showMailView: Bool
    @Binding var showAlert: Bool
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> UIViewController {
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = context.coordinator
        controller.setSubject("Life Hack に関するお問い合わせ")
        controller.setToRecipients(["tcfiy62634@yahoo.co.jp"])
        controller.setMessageBody("", isHTML: false)
        return controller
    }
    
    func makeCoordinator() -> MailView.Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {
        let parent: MailView
        init(parent: MailView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            switch result {
            case .sent:
                self.parent.showMailView = false
                self.parent.showAlert = true
            case .cancelled:
                self.parent.showMailView = false
            case .failed:
                self.parent.showMailView = false
            case .saved:
                self.parent.showMailView = false
            default:
                print("default")
            }
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<MailView>) {
    }
    
}
