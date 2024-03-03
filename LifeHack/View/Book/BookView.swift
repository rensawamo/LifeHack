//
//  BookVIew.swift
//  LifeHack
//
//  Created by sawamoren on 2023/08/25.
//

import SwiftUI
import RealmSwift


struct BookView: View {
    @StateObject var viewModel = BookViewModel()
    @AppStorage("apperCount") var apperCount: Int = 0
    @State var isSheetUp:Bool = false
    @Binding var currentBookTitle: String
    @AppStorage("activeTag") var activeTag: String = "all"
    
    @State var isContext:Bool = false
    @State var isEditing:Bool = false
    @State var isNewCategory:Bool = false
    @State var textCategory:String = ""
    @State var currentDetailId: UUID = UUID()
    @State var selectedSegment:Int = 0
    @State var isShowSort:Bool = false
    
    @State var searchText:String = ""
    @State var isKeyboardVisible: Bool = false
    @State var allSearchController:Bool = false
    
    @AppStorage("selectedSortSegment") var selectedSortSegment:Int = 0
    
    // NewBookView
    @State var currentId: ObjectId = .init()
    @State var textTitle: String = ""
    @State var textgoal1:String = ""
    @State var textgoal2:String = ""
    @State var textgoal3:String = ""
    @State var rating:Int = 0
    @State var selectedDate:Date = Date()
    
    @State var isShowAlert = false
    @State var alertText:String = ""
    @State var alertLocalize:String = ""
    
    // poper
    @State var isShowPopover: Bool = false
    @State var arrowDirection: ArrowDirection = .up
    @State var background: Color = .white
    

    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 15, content: {
                HStack {
                    Text(LocalizedStringKey("memo"))
                        .font(.title3.bold())
                    
                    Image(systemName: "lightbulb.circle")
                        .font(.title3)
                        .foregroundColor(.yellow)
                        .onTapGesture {
                            isShowPopover.toggle()
                        }
                        .iOSPopover(isPresented: $isShowPopover, arrowDirection: arrowDirection.direction) {
                            PoperView(isShowPopover: $isShowPopover,width: 0.8,height: 0.1,isStructShow: true, selectContent: .BookPoper)
                                .background {
                                    Rectangle()
                                        .fill(background)
                                        .shadow(color: Color.gray.opacity(0.3), radius: 10, x: 0, y: 0)
                                        .padding(-20)
                                }
                        }
                }
                .offset(x: 10)
                
                TagsView()
                    .padding(.trailing, 35)
                    .overlay(alignment: .trailing, content: {
                        Image(systemName: "plus")
                            .foregroundStyle(.white)
                            .font(.caption2)
                            .foregroundColor(.brown)
                            .frame(width: 20, height: 25)
                            .background(.brown)
                            .clipShape(Circle())
                            .onTapGesture {
                                textCategory = ""
                                isNewCategory = true
                            }
                    })
                
                VStack(alignment: .trailing,spacing: 6, content: {
                    HStack {
                        SearchView(searchText: $searchText,isKeyboardVisible:$isKeyboardVisible, allSearchController: $allSearchController)
                            .offset(x:20)
                            .opacity(isShowSort ? 1 : 0)
                            .onChange(of: isKeyboardVisible) { newValue in
                                if newValue == false {
                                    viewModel.searchBook(searchText)
                                }
                            }
                        // all search
                            .onChange(of: allSearchController) { newValue in
                                viewModel.searchBook("")
                            }
                        Picker(selection: $selectedSortSegment, label: Text("")) {
                            Text(LocalizedStringKey("latest")).tag(0)
                            Text(LocalizedStringKey("review")).tag(1)
                        }
                        .opacity(isShowSort ? 1 : 0)
                        .onChange(of: selectedSortSegment) { newValue in
                            withAnimation(.easeInOut(duration: 0.4)) {
                                viewModel.updateSortSegment(newValue)
                            }
                        }
                        .onAppear {
                            viewModel.updateSortSegment(selectedSortSegment)
                            isShowSort =  viewModel.isShowSortBook(activeTag)
                        }
                    }
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 65) {
                            ForEach(viewModel.books) { book in
                                if book.category == activeTag || activeTag == "all" {
                                    NavigationLink(
                                        destination: DetailView(booktilte: book.title, viewModel: viewModel),
                                        label: {
                                            BookCardView(book)
                                        })
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical,25)
                        .offset(y:10)
                    }
                })
            })
            .background(Color.customBackground)
            .foregroundColor(.black.opacity(0.9))
            .overlay(alignment: .bottomTrailing, content: {
                Button(action: {
                    isEditing = false
                    textTitle = ""
                    textgoal1 = ""
                    textgoal2 = ""
                    textgoal3 = ""
                    selectedSegment = searchCategoryIndex(activeTag)
                    rating = 0
                    isSheetUp = true
                }, label: {
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(width: 55, height: 55)
                        .background(.brown)
                        .clipShape(Circle())
                })
                .offset(x: -15,y: UIScreen.main.hasHomeButton ? -25 : -10)
                .opacity(isKeyboardVisible ? 0 : 1)
            })
            .sheet(isPresented: $isSheetUp, content: {
                NewBookView()
                    .presentationDetents([.height(600)])
                    .interactiveDismissDisabled()
                    .presentationCornerRadius(15)
            })
            .sheet(isPresented: $isNewCategory, content: {
                NewCategoryView()
                    .presentationDetents([.height(260)])
                    .interactiveDismissDisabled()
                    .presentationCornerRadius(15)
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            if apperCount == 0 {
                viewModel.addBookCategory(category: "all")
            }
            apperCount = 1
            selectedSegment = searchCategoryIndex(activeTag)
        }
        .alert(isPresented: $isShowAlert) {
            SwiftUI.Alert(title: Text(LocalizedStringKey(alertText)))
        }
    }
    
    @ViewBuilder
    func TagsView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            if viewModel.bookCategoris.count == 0 {
                Text("")
                    .padding(.leading,10)
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                HStack(spacing: 10) {
                    ForEach(viewModel.bookCategoris, id: \.id) { i in
                        Text(i.category)
                            .font(.caption)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                            .background {
                                if activeTag == i.category {
                                    Capsule()
                                        .fill(.brown)
                                } else {
                                    Capsule()
                                        .fill(.gray.opacity(0.2))
                                }
                            }
                            .foregroundColor(activeTag == i.category ? .white : .gray)
                            .onTapGesture {
                                withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.7)) {
                                    activeTag = i.category
                                }
                            }
                            .onLongPressGesture(minimumDuration: 3.5, pressing: { pressing in
                                if pressing {
                                    isContext = true
                                } else {
                                }
                            }, perform: {})
                            .contextMenu(menuItems: {
                                if isContext {
                                    Button(action: {
                                        if i.category == "all" {
                                            alertText = "CantAllDelete"
                                            isShowAlert = true
                                        } else {
                                            viewModel.updateBookWhyDeleteCategory(category: i.category)
                                            activeTag = "all"
                                            viewModel.deleteBookCategory(id: i.id)
                                        }
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
                            .onChange(of: activeTag) { newValue in
                                isShowSort =  viewModel.isShowSortBook(newValue)
                            }
                            .onDrag {
                                currentDetailId = i.dragableId
                                return NSItemProvider(contentsOf: URL(string: "\(i.id)")!)!
                            }
                            .onDrop(of: [.url], delegate: Drag(currentBookCategory: i, currentDetailId: currentDetailId, viewModel: viewModel))
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func BookCardView(_ book: Book) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(book.title)
                .font(.title3)
                .fontWeight(.semibold)
            
            HStack (spacing: 5){
                Text(LocalizedStringKey("registrationDate"))
                Text(formatDate(book.resistedDate)).font(.caption)
            }
            .font(.caption)
            .foregroundColor(.gray)
            Spacer(minLength: 0.5)
            
            RatingView(book.rating)
            
            Spacer(minLength: 0.5)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(LocalizedStringKey("goal"))
                    .font(.subheadline.bold())
                    .foregroundColor(.black.opacity(0.7))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("1. " + "\(book.goal1)")
                    Text("2. " + "\(book.goal2)")
                    Text("3. " + "\(book.goal3)")
                }
                .frame(width: UIScreen.main.bounds.width * 0.7,height: 50, alignment: .leading)
            }
            .font(.caption)
            Spacer(minLength: 4)
        }
        .padding(.horizontal,25)
        .padding(.vertical,8)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.white)
                .shadow(color: .black.opacity(0.07), radius: 8, x: 1, y: 2)
                .shadow(color: .black.opacity(0.07), radius: 8, x: 1, y: 2)
        }
        .contextMenu(menuItems: {
            Button {
                isEditing = true
                currentId = book.id
                textTitle = book.title
                textgoal1 = book.goal1
                textgoal2 = book.goal2
                textgoal3 = book.goal3
                selectedSegment = searchCategoryIndex(book.category)
                rating = book.rating
                isSheetUp = true
            } label: {
                Label(LocalizedStringKey("edit"), systemImage: "pencil")
                    .font(.body)
            }
            Button(action: {
                viewModel.deleteBook(id: book.id)
            }, label: {
                Label(LocalizedStringKey("delete"), systemImage: "trash")
                    .font(.body)
            })
        })
        .zIndex(1)
        .frame(height: 120)
    }
    
    @ViewBuilder
    func RatingView(_ rating: Int) -> some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundColor(index <= rating ? .yellow : .gray.opacity(0.5))
            }
        }
    }
    
    @ViewBuilder
    func NewBookView() -> some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    hideKeyboard()
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
                    HStack {
                        Text(LocalizedStringKey("category"))
                        if viewModel.bookCategoris.isEmpty {
                            Text("all")
                                .font(.caption2)
                                .foregroundColor(.gray.opacity(0.8))
                        } else {
                            Picker(selection: $selectedSegment,
                                   label: Text("category")
                            ) {
                                ForEach(0..<viewModel.bookCategoris.count, id: \.self) { index in
                                    Text(viewModel.bookCategoris[index].category)
                                        .tag(index)
                                }
                            }
                        }
                    }
                    .font(.subheadline.bold())
                    .padding(.bottom,10)
                    
                    Text(LocalizedStringKey("bookTitle"))
                        .font(.subheadline.bold())
                        .foregroundColor(.black.opacity(0.7))
                    
                    TextField(LocalizedStringKey("bookTitle"), text: $textTitle)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.black.opacity(0.4), lineWidth: 1)
                        )
                        .padding(.bottom,10)
                    
                    
                    EditRatingView()
                        .background {
                            Color.clear
                                .contentShape(Rectangle())
                        }
                        .padding(.bottom,10)
                    
                    Text(LocalizedStringKey("goal"))
                        .font(.subheadline.bold())
                        .foregroundColor(.black.opacity(0.8))
                    
                    TextField(LocalizedStringKey("goal1"), text: $textgoal1)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.black.opacity(0.4), lineWidth: 1)
                        )
                        .padding(.bottom,10)
                    TextField(LocalizedStringKey("goal2"), text: $textgoal2)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.black.opacity(0.4), lineWidth: 1)
                        )
                        .padding(.bottom,10)
                    TextField(LocalizedStringKey("goal3"), text: $textgoal3)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.black.opacity(0.4), lineWidth: 1)
                        )
                        .padding(.bottom,10)
                    
                    Button(action: {
                        if isEditing {
                            viewModel.updateBook(id: currentId, category: viewModel.bookCategoris[selectedSegment].category, title: textTitle, rating: rating, goal1: textgoal1, goal2: textgoal2, goal3: textgoal3)
                        } else  {
                            viewModel.addBook(title: textTitle, category: viewModel.bookCategoris[selectedSegment].category, rating: rating, goal1: textgoal1,goal2: textgoal2,goal3: textgoal3)
                        }
                        isSheetUp = false
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
    func NewCategoryView() -> some View {
        VStack(alignment: .trailing, spacing: 15, content: {
            Text(LocalizedStringKey("add"))
                .font(.title2.bold())
                .frame(width: UIScreen.main.bounds.width * 0.9)
                .overlay (alignment:.trailing){
                    Button(action: {
                        isNewCategory = false
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .tint(.brown)
                    })
                }
            
            VStack(alignment: .leading, spacing: 12, content: {
                Text(LocalizedStringKey("category"))
                    .font(.subheadline.bold())
                TextField(LocalizedStringKey("category"), text: $textCategory)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.black.opacity(0.4), lineWidth: 1)
                    )
                    .padding(.bottom,10)
                
                Button(action: {
                    if viewModel.bookCategoris.count >= 20 {
                        isNewCategory = false
                        alertText = "CantAddCategory"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isShowAlert = true
                        }
                    } else if searchCategoryIndex(textCategory) != -1 {
                        isNewCategory = false
                        alertText = "alreadyResistration"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isShowAlert = true
                        }
                    } else {
                        viewModel.addBookCategory(category: textCategory)
                        isNewCategory = false
                    }
                }, label: {
                    Text(isEditing ? LocalizedStringKey("edit") : LocalizedStringKey("add"))
                        .bold()
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 180, height:40)
                        .background(Color.brown)
                        .cornerRadius(10)
                        .padding(.top,20)
                        .hSpacing(.center)
                })
                .disabled(textCategory == "")
                .opacity(textCategory == "" ? 0.5 : 1)
            })
            .padding(.bottom,10)
        })
        .padding(.horizontal,15)
    }
    
    @ViewBuilder
    func EditRatingView() -> some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: "star.fill")
                    .onTapGesture {
                        self.rating = index
                    }
                    .font(.title3)
                    .foregroundColor(index <= rating ? .yellow : .gray.opacity(0.5))
            }
        }
    }
    func searchCategoryIndex(_ searchCategory: String) -> Int {
        var ary:[String] = []
        var result:Int = -1
        for i in viewModel.bookCategoris {
            ary.append(i.category)
        }
        result = ary.firstIndex(where: { $0 == searchCategory }) ?? -1
        return result
    }
}


//struct BookView_Previews: PreviewProvider {
//    static var previews: some View {
//        BookView()
//    }
//}

