//
//  ContentView.swift
//  Chat
//
//  Created by Balaji on 27/06/20.
//

import SwiftUI

struct SentenceView: View {
    var ViewModel:DiaryViewModel
    @Binding var isKeyboad:Bool
    @State var fixText:String
    @State private var isContext = false
    @State var isExpand:Bool = false
    var isDisable:Bool = false
    var diary: Diary
    var body: some View {
        
        ZStack {
            if diary.photo == nil {
                TextField(diary.text, text: $fixText, axis: .vertical)
                    .frame(width: 300)
                    .onTapGesture {
                        isKeyboad = true
                    }
                    .onAppear {
                        fixText = diary.text
                    }
                    .onChange(of: isKeyboad) { newValue in
                        if isKeyboad == false {
                            ViewModel.updateDiary(id: diary.id, text: fixText)
                        }
                    }
            } else {
                ZStack {
                    if !diary.isInvalidated {
                        Image(uiImage: UIImage(data: diary.photo!)!)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.8, maxHeight:  UIScreen.main.bounds.height * 0.5)
                            .contextMenu(menuItems: {
                                if isContext {
                                    Button(action: {
                                        ViewModel.deleteDiary(id: diary.id)
                                    }) {
                                        Text(LocalizedStringKey("delete"))
                                    }
                                    Button(action: {
                                        isContext = false
                                    }) {
                                        Text(LocalizedStringKey("cancel"))
                                    }
                                }
                            })
                            .onTapGesture{
                                var transaction = Transaction()
                                transaction.disablesAnimations = true
                                withTransaction(transaction) {
                                    isExpand = true
                                }
                            }
                            .onLongPressGesture(minimumDuration: 2.0, pressing: { pressing in
                                if pressing {
                                    isContext = true
                                } else {
                                }
                            }, perform: {})
                            .fullScreenCover(isPresented: $isExpand) {
                                ExpandPhotoView(photo: diary.photo!)
                            }
                    }
                }
            }
        }
    }
}





