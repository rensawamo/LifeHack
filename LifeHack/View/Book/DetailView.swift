//
//  RatingView.swift
//  LifeHack
//
//  Created by sawamoren on 2023/08/25.
//

import SwiftUI
import RealmSwift

struct DetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var isSheetUp:Bool = false
    var booktilte:String
    var viewModel: BookViewModel
    
    @State var searchText:String = ""
    @State var isKeyboardVisible: Bool = false
    @State var allSearchController:Bool = false
    
    @State var isEditing: Bool = false
    @State var currentDetailId:UUID = .init()
    @State var currentId:ObjectId = .init()
    @State var textTitle: String  = ""
    @State var textContant:String = ""
    @State var textTodo:String = ""
    
    @State var sortNum:Int = 0
    @State var startBookMemo:BookMemo = .init()
    @State private var showAlert: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 6, content: {
            Text(booktilte)
                .font(.title2.bold())
            
            VStack {
                SearchView(searchText: $searchText,isKeyboardVisible:$isKeyboardVisible, allSearchController: $allSearchController)
                    .onChange(of: isKeyboardVisible) { newValue in
                        if newValue == false {
                            viewModel.searchBookMemo(searchText)
                        }
                    }
                    .onChange(of: allSearchController) { newValue in
                        viewModel.searchBookMemo("")
                    }
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        ForEach(viewModel.bookMemoes) { memo in
                            DetailCardView(memo)
                                .contextMenu(menuItems: {
                                    Button {
                                        currentId = memo.id
                                        textTitle = memo.title
                                        textContant = memo.contant
                                        textTodo = memo.todo
                                        isEditing = true
                                        isSheetUp = true
                                    } label: {
                                        Label(LocalizedStringKey("edit"), systemImage: "pencil")
                                            .font(.body)
                                    }
                                    Button(action: {
                                        //                                        realmManager.deleteBook(id: book.id)
                                    }, label: {
                                        Label(LocalizedStringKey("delete"), systemImage: "trash")
                                            .font(.body)
                                    })
                                })
                                .padding(.horizontal, 20)
                                .padding(.top,10)
                                .onDrag {
                                    currentDetailId = memo.dragableId
                                    startBookMemo = memo
                                    return NSItemProvider(contentsOf: URL(string: "\(memo.id)")!)!
                                }
                                .onDrop(of: [.url], delegate: Drag2(currentBookMemo: memo,currentDetailId: currentDetailId, viewModel: viewModel, bookTitle: booktilte)
                                )
                            
                        }
                    }
                }
            }
            .font(.subheadline)
        })
        .alert(isPresented: $showAlert) {
            SwiftUI.Alert(title: Text(LocalizedStringKey("bookTitleAlert")))
        }
        .onAppear {
            viewModel.updateTitle(booktilte)
            sortNum =  (viewModel.bookMemoes).count - 1
            print(sortNum)
        }
        .sheet(isPresented: $isSheetUp, content: {
            NewDeatailView()
                .presentationDetents([.height(500)])
                .interactiveDismissDisabled()
                .presentationCornerRadius(15)
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 15)
        .background(Color.customBackground)
        .navigationBarBackButtonHidden(true)
        .overlay(alignment: .bottomTrailing, content: {
            Button(action: {
                isEditing = false
                textTitle = ""
                textContant = ""
                textTodo = ""
                isSheetUp = true
            }, label: {
                Image(systemName: "plus")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 55, height: 55)
                    .background(.brown)
                    .clipShape(Circle())
                    .opacity(isKeyboardVisible ? 0 : 1)
            })
            .offset(x: -15,y: UIScreen.main.hasHomeButton ? -25 : -10)
        })
        .overlay(alignment: .topLeading, content: {
            Text("<")
                .foregroundColor(.gray)
                .padding(.leading,10)
                .font(.title2.bold())
                .onTapGesture {
                    presentationMode.wrappedValue.dismiss()
                }
        })
    }
    
    @ViewBuilder
    func NewDeatailView() -> some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        hideKeyboard()
                    }
                }
            VStack(alignment: .trailing, spacing: 15, content: {
                Text(isEditing ? LocalizedStringKey("edit") : LocalizedStringKey("add"))
                    .font(.title2.bold())
                    .frame(width: UIScreen.main.bounds.width * 0.9)
                    .overlay (alignment:.trailing){
                        Button(action: {
                            isSheetUp = false
                        }, label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .tint(.brown)
                        })
                    }
                
                VStack(alignment: .leading, spacing: 10, content: {
                    Text(LocalizedStringKey("memoTitle"))
                        .font(.subheadline.bold())
                    TextField(LocalizedStringKey("memoTitle"), text: $textTitle)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.black.opacity(0.4), lineWidth: 1)
                        )
                        .padding(.bottom,10)
                    
                    Text(LocalizedStringKey("contant"))
                        .font(.subheadline.bold())
                        .foregroundColor(.black.opacity(0.8))
                    TextField(LocalizedStringKey("contant2"), text: $textContant, axis: .vertical)
                        .padding(.horizontal, 15)
                        .frame(height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.black.opacity(0.4), lineWidth: 1)
                        )
                        .padding(.bottom,10)
                    
                    Text(LocalizedStringKey("action"))
                        .font(.subheadline.bold())
                        .foregroundColor(.red)
                    TextField(LocalizedStringKey("action"), text: $textTodo, axis: .vertical)
                        .padding(.horizontal, 15)
                        .frame(height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.black.opacity(0.4), lineWidth: 1)
                        )
                    Button(action: {
                        if isEditing {
                            viewModel.updateBookMemo(id: currentId, title: textTitle, contant: textContant, todo: textTodo)
                            isSheetUp = false
                        } else {
                            if viewModel.isAlreadyTitle(textTitle, booktilte) {
                                isSheetUp = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showAlert = true
                                }
                            } else {
                                sortNum += 1
                                viewModel.addBookMemo(bookTitle: booktilte, date: Date(), title: textTitle, contant: textContant, todo: textTodo, sortNum: sortNum)
                                isSheetUp = false
                            }
                        }
                    }, label: {
                        Text(isEditing ? LocalizedStringKey("edit") : LocalizedStringKey("add"))
                            .bold()
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 180, height:40)
                    })
                    .frame(width: 180, height:40)
                    .background(Color.brown)
                    .cornerRadius(10)
                    .offset(y: 10)
                    .hSpacing(.center)
                    .disabled(textTitle == "")
                    .opacity(textTitle == "" ? 0.5 : 1)
                })
                .padding(.bottom,10)
            })
            .padding(.horizontal,15)
        }
    }
    
    @ViewBuilder
    func DetailCardView(_ book: BookMemo) -> some View {
        VStack(alignment: .leading, spacing: 7, content: {
            Text(book.title)
                .font(.title3.bold())
            VStack (alignment: .leading){
                Text(LocalizedStringKey("contant"))
                    .foregroundStyle(.black.opacity(0.8))
                    .font(.caption.bold())
                ScrollView {
                    Text(book.contant)
                }
            }
            Spacer(minLength: 1)
            VStack (alignment: .leading){
                Text(LocalizedStringKey("action"))
                    .foregroundStyle(.red)
                    .font(.caption.bold())
                ScrollView {
                    Text(book.todo)
                }
                .frame(height: 40)
            }
        })
        .frame(maxWidth: .infinity,alignment: .leading)
        .padding(12)
        
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.white)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 1, y: 1)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 1, y: 1)
        }
    }
}


