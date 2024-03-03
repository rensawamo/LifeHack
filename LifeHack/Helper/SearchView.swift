//
//  SearchView.swift
//  LifeHack
//
//  Created by sawamoren on 2023/08/27.
//

import SwiftUI

struct SearchView: View {
    @Binding var searchText: String
    @Binding var isKeyboardVisible: Bool
    @Binding var allSearchController:Bool
    
    var body: some View {
        VStack {
            ZStack {
                // 背景
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 239 / 255,
                                green: 239 / 255,
                                blue: 241 / 255))
                    .frame(height: 36)
                
                HStack(spacing: 6) {
                    Spacer()
                        .frame(width: 0)
                    
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search", text: $searchText)
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText.removeAll()
                            allSearchController.toggle()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 6)
                    }
                }
            }
            .padding(.horizontal)
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                isKeyboardVisible = false
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                isKeyboardVisible = true
            }
        }
    }
}


struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(searchText: .constant("search"), isKeyboardVisible: .constant(false), allSearchController: .constant(false))
    }
}
