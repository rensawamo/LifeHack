//
//  TodoView.swift
//  LifeHack
//
//  Created by sawamoren on 2023/08/13.
//

import SwiftUI
import Network
import RealmSwift

struct TodoView: View {
    var viewModel = TodoViewModel(currentDate: Date())
    @AppStorage("selectedTodoSegment") var selectedSegment:Int = 0
    
    @State var todoes: [Task]
    @State var workings: [Task]
    @State var completeds: [Task]
    @State var longTodoes: [Task]
    @State var longCompleteds: [Task]
    
    @State var currentId: ObjectId = .init()
    @State var currentTitle: String = ""
    @State var currentContext: String = ""
    @State var currentTime: Int = 0
    @State var currentStates: Status = .todo
    @State var currentlyDragging: Task?
    @State var isCreateNewTask: Bool = false
    @State var isDetailShow: Bool = false
    @State var isEditing:Bool = false
    
    // for edit
    @State  var selectedDate:Date = Date()
    
    // poper
    @State var isShowPopover: Bool = false
    @State var arrowDirection: ArrowDirection = .up
    @State var background: Color = .white
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 5, content: {
            Text(LocalizedStringKey("work"))
                .font(.title3.bold())
                .overlay {
                    Picker(selection: $selectedSegment, label: Text("")) {
                        Text(LocalizedStringKey("short")).tag(0)
                        Text(LocalizedStringKey("long")).tag(1)
                    }
                    .frame(width: 100)
                    .offset(x: 130)
                    .onChange(of: selectedSegment) { newValue in
                        isDetailShow = false
                    }
                }
            
            if selectedSegment == 0 {  //短期
                HStack {
                    VStack(alignment: .leading, spacing: 1, content: {
                        Text(LocalizedStringKey("progress"))
                            .font(.subheadline)
                            .padding(.leading,20)
                        WorkingView()
                            .frame(height: UIScreen.main.bounds.height * 0.375)
                    })
                    VStack(alignment: .leading, spacing: 1, content: {
                        HStack {
                            Text(LocalizedStringKey("complete"))
                                .font(.subheadline)
                                .padding(.leading,20)
                            Image(systemName: "lightbulb.circle")
                                .foregroundColor(.yellow)
                                .onTapGesture {
                                    isShowPopover.toggle()
                                }
                                .iOSPopover(isPresented: $isShowPopover, arrowDirection: arrowDirection.direction) {
                                    PoperView(isShowPopover: $isShowPopover,width: 0.8,height: 0.1,isStructShow: true, selectContent: .DetailTodo)
                                        .background {
                                            Rectangle()
                                                .fill(background)
                                                .shadow(color: Color.gray.opacity(0.3), radius: 10, x: 0, y: 0)
                                                .padding(-20)
                                        }
                                }
                        }
                        CompletedView()
                            .frame(height: UIScreen.main.bounds.height * 0.375)
                    })
                }
                .padding(.bottom,7)
                
                VStack (alignment: .leading,spacing: 1) {
                    Text(LocalizedStringKey("notYet"))
                        .font(.subheadline)
                        .padding(.leading,20)
                    TodoView()
                        .padding(.bottom,UIScreen.main.hasHomeButton ? 15 : 1)
                }
            } else {
                VStack {
                    VStack(alignment: .leading, spacing: 1, content: {
                        HStack {
                            Text(LocalizedStringKey("complete"))
                                .font(.subheadline)
                                .padding(.leading,20)
                            Image(systemName: "lightbulb.circle")
                                .foregroundColor(.yellow)
                                .onTapGesture {
                                    isShowPopover.toggle()
                                }
                                .iOSPopover(isPresented: $isShowPopover, arrowDirection: arrowDirection.direction) {
                                    PoperView(isShowPopover: $isShowPopover,width: 0.8,height: 0.1,isStructShow: true, selectContent: .DetailTodo)
                                        .background {
                                            Rectangle()
                                                .fill(background)
                                                .shadow(color: Color.gray.opacity(0.3), radius: 10, x: 0, y: 0)
                                                .padding(-20)
                                        }
                                }
                        }
                        TryCompletedView()
                            .frame(height: UIScreen.main.bounds.height * 0.3)
                    })
                    VStack(alignment: .leading, spacing: 1, content: {
                        Text(LocalizedStringKey("task"))
                            .font(.subheadline)
                            .padding(.leading, 20)
                        TryView()
                            .padding(.bottom,UIScreen.main.hasHomeButton ?  15 : 1)
                    })
                }
            }
        })
        .frame(maxWidth: .infinity,maxHeight:  .infinity,alignment: .top)
        .overlay(alignment: .bottomTrailing, content: {
            Button(action: {
                isCreateNewTask.toggle()
            }, label: {
                Image(systemName: "plus")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 55, height: 55)
                    .background(.brown)
                    .clipShape(Circle())
            })
            .offset(x: -15,y: UIScreen.main.hasHomeButton ? -25 : -10)
        })
        .background(Color.customBackground)
        .overlay(alignment: .center) {
            DetailTaskView(title: currentTitle,context: currentContext, time :currentTime, status: currentStates)
                .opacity(isDetailShow ? 1 : 0)
        }
        .sheet(isPresented: $isEditing, content: {
            EditTodoView()
                .presentationDetents([.height(460)])
                .interactiveDismissDisabled()
                .presentationCornerRadius(15)
        })
        .sheet(isPresented: $isCreateNewTask, content: {
            NewTaskView(selectedSegment: selectedSegment, todoes: $todoes, longTodes: $longTodoes, viewModel: viewModel)
                .presentationDetents([.height(490)])
                .interactiveDismissDisabled()
                .presentationCornerRadius(15)
        })
        .onDisappear {
            viewModel.saveTask(todoes: todoes, status: .todo)
            viewModel.saveTask(todoes: workings, status: .working)
            viewModel.saveTask(todoes: longTodoes, status: .longTodo)
            viewModel.saveCompletedTask(todoes: completeds, status: .completed)
            viewModel.saveCompletedTask(todoes: longCompleteds, status: .longCompleted)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            viewModel.saveTask(todoes: todoes, status: .todo)
            viewModel.saveTask(todoes: workings, status: .working)
            viewModel.saveTask(todoes: longTodoes, status: .longTodo)
            viewModel.saveCompletedTask(todoes: completeds, status: .completed)
            viewModel.saveCompletedTask(todoes: longCompleteds, status: .longCompleted)
        }
    }
    
    @ViewBuilder
    func TasksView(_ tasks: [Task]) -> some View {
        VStack(alignment: .leading, spacing: 10, content: {
            ForEach(tasks, id: \.self) { task in
                GeometryReader {
                    TaskRow(task, $0.size)
                }
                .frame(height: 40)
            }
        })
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    @ViewBuilder
    func TaskRow(_ task: Task, _ size: CGSize) -> some View {
        Text(task.title)
            .strikethrough(task.status == .completed || task.status == .longCompleted ? true : false)
            .font(.callout)
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: size.height)
            .background(selectedSegment == 0 ? Define_Colors[task.time].opacity(0.6) : (task.status == .longCompleted ? .gray.opacity(0.6) : .brown.opacity(0.6)))
            .cornerRadius(10)
            .shadow(color: Color.gray.opacity(0.3), radius: 10, x: 0, y: 0)
            .onTapGesture(count: 1) {
                currentTitle = task.title
                currentContext = task.context
                currentTime = task.time
                currentId = task.id
                currentStates = task.status
                withAnimation(.easeInOut(duration: 0.3)) {
                    chancgeBoolofDetail()
                }
            }
            .draggable(task.dragableId.uuidString) {
                Text(task.title)
                    .font(.callout)
                    .padding(.horizontal, 15)
                    .frame(width: size.width, height: size.height, alignment: .leading)
                    .background(.white)
                    .onAppear(perform: {
                        currentlyDragging = task
                        isDetailShow = false
                    })
            }
            .dropDestination(for: String.self) { items, location in
                currentlyDragging = nil
                return false
            } isTargeted: { status in
                if let currentlyDragging, status, currentlyDragging.dragableId != task.dragableId {
                    withAnimation(.easeIn) {
                        appendTask(task.status)
                        switch task.status {
                        case .todo:
                            replaceItem(tasks: &todoes, droppingTask: task, status: .todo)
                        case .working:
                            replaceItem(tasks: &workings, droppingTask: task, status: .working)
                        case .completed:
                            replaceItem(tasks: &completeds, droppingTask: task, status: .completed)
                        case .longTodo:
                            replaceItem(tasks: &longTodoes, droppingTask: task, status: .longTodo)
                        case .longCompleted:
                            replaceItem(tasks: &longCompleteds, droppingTask: task, status: .longCompleted)
                        }
                    }
                }
            }
            .contextMenu {
                Button {
                    currentTitle = task.title
                    currentContext = task.context
                    currentTime = task.time
                    currentId = task.id
                    currentStates = task.status
                    isEditing = true
                } label: {
                    Label(LocalizedStringKey("edit"), systemImage: "pencil")
                }
                Button {
                    viewModel.deleteTodo(id: task.id)
                    switch task.status {
                    case .todo:
                        if let index = todoes.firstIndex(where: { $0.id == task.id }) {
                            todoes.remove(at: index)
                        }
                    case .working:
                        if let index = workings.firstIndex(where: { $0.id == task.id }) {
                            workings.remove(at: index)
                        }
                    case .completed:
                        if let index = completeds.firstIndex(where: { $0.id == task.id }) {
                            completeds.remove(at: index)
                        }
                    case .longTodo:
                        if let index = longTodoes.firstIndex(where: { $0.id == task.id }) {
                            longTodoes.remove(at: index)
                        }
                    case .longCompleted:
                        if let index = longCompleteds.firstIndex(where: { $0.id == task.id }) {
                            longCompleteds.remove(at: index)
                        }
                    }
                } label: {
                    Label(LocalizedStringKey("trash"), systemImage: "trash")
                }
            }
    }
    
    func appendTask(_ status: Status) {
        if let currentlyDragging {
            switch status {
            case .todo:
                if !todoes.contains(where: { $0.dragableId == currentlyDragging.dragableId }) {
                    let updatedTask = currentlyDragging
                    updatedTask.status = .todo
                    todoes.append(updatedTask)
                    workings.removeAll(where: { $0.dragableId == currentlyDragging.dragableId })
                    completeds.removeAll(where: { $0.dragableId == currentlyDragging.dragableId })
                    viewModel.updateTask(id: updatedTask.id, status: .todo)
                }
                
            case .working:
                if !workings.contains(where: { $0.dragableId == currentlyDragging.dragableId }) {
                    let updatedTask = currentlyDragging
                    updatedTask.status = .working
                    workings.append(updatedTask)
                    todoes.removeAll(where: { $0.dragableId == currentlyDragging.dragableId })
                    completeds.removeAll(where: { $0.dragableId == currentlyDragging.dragableId })
                    viewModel.updateTask(id: updatedTask.id, status: .working)
                }
                
            case .completed:
                if !completeds.contains(where: { $0.dragableId == currentlyDragging.dragableId }) {
                    let updatedTask = currentlyDragging
                    updatedTask.status = .completed
                    completeds.append(updatedTask)
                    workings.removeAll(where: { $0.dragableId == currentlyDragging.dragableId })
                    todoes.removeAll(where: { $0.dragableId == currentlyDragging.dragableId })
                    viewModel.updateTask(id: updatedTask.id, status: .completed)
                }
                
            case .longTodo:
                if !longTodoes.contains(where: { $0.dragableId == currentlyDragging.dragableId }) {
                    let updatedTask = currentlyDragging
                    updatedTask.status = .longTodo
                    longTodoes.append(updatedTask)
                    longCompleteds.removeAll(where: { $0.dragableId == currentlyDragging.dragableId })
                    viewModel.updateTask(id: updatedTask.id, status: .longTodo)
                }
                
            case .longCompleted:
                if !longCompleteds.contains(where: { $0.dragableId == currentlyDragging.dragableId }) {
                    let updatedTask = currentlyDragging
                    updatedTask.status = .longCompleted
                    longTodoes.removeAll(where: { $0.dragableId == currentlyDragging.dragableId })
                    longCompleteds.append(updatedTask)
                    viewModel.updateTask(id: updatedTask.id, status: .longCompleted)
                }
            }
        }
    }
    
    func replaceItem(tasks: inout [Task], droppingTask: Task,status: Status) {
        if let currentlyDragging {
            if let sourceIndex = tasks.firstIndex(where: { $0.dragableId == currentlyDragging.dragableId }),
               let destinationIndex = tasks.firstIndex(where: { $0.dragableId == droppingTask.dragableId}) {
                let sourceItem = tasks.remove(at: sourceIndex)
                sourceItem.status = status
                tasks.insert(sourceItem, at: destinationIndex)
            }
        }
    }
    
    @ViewBuilder
    func TodoView() -> some View {
        NavigationStack {
            ScrollView(.vertical) {
                TasksView(todoes)
            }
            .frame(maxWidth: .infinity)
            .background(.brown.opacity(0.2))
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isDetailShow = false
                }
            }
            .dropDestination(for: String.self) { items, location in
                withAnimation(.easeIn) {
                    appendTask(.todo)
                }
                return true
            } isTargeted: { _ in
            }
        }
    }
    
    @ViewBuilder
    func WorkingView() -> some View {
        NavigationStack {
            ScrollView(.vertical) {
                TasksView(workings)
            }
            .frame(maxWidth: .infinity)
            .background(.brown.opacity(0.2))
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isDetailShow = false
                }
            }
            .dropDestination(for: String.self) { items, location in
                withAnimation(.easeIn) {
                    appendTask(.working)
                }
                return true
            } isTargeted: { _ in
                
            }
        }
    }
    
    @ViewBuilder
    func CompletedView() -> some View {
        NavigationStack {
            ScrollView(.vertical) {
                TasksView(completeds)
            }
            .frame(maxWidth: .infinity)
            .background(.brown.opacity(0.2))
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isDetailShow = false
                }
            }
            .dropDestination(for: String.self) { items, location in
                withAnimation(.easeIn) {
                    appendTask(.completed)
                }
                return true
            } isTargeted: { _ in
            }
        }
    }
    
    @ViewBuilder
    func TryView() -> some View {
        NavigationStack {
            ScrollView(.vertical) {
                TasksView(longTodoes)
            }
            .frame(maxWidth: .infinity)
            .background(.brown.opacity(0.2))
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isDetailShow = false
                }
            }
            .dropDestination(for: String.self) { items, location in
                withAnimation(.easeIn) {
                    appendTask(.longTodo)
                }
                return true
            } isTargeted: { _ in
            }
        }
    }
    
    @ViewBuilder
    func TryCompletedView() -> some View {
        NavigationStack {
            ScrollView(.vertical) {
                TasksView(longCompleteds)
            }
            .frame(maxWidth: .infinity)
            .background(.brown.opacity(0.2))
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isDetailShow = false
                }
            }
            .dropDestination(for: String.self) { items, location in
                withAnimation(.easeIn) {
                    appendTask(.longCompleted)
                }
                return true
            } isTargeted: { _ in
            }
        }
    }
    
    @ViewBuilder
    func DetailTaskView(title:String,context:String,time:Int ,status: Status) -> some View {
        ZStack {
            Rectangle()
                .fill(Color.customBackground)
                .background(Color.white)
                .cornerRadius(20)
                .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * (islongTerm(status) ? 0.36 : 0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(selectedSegment == 0 ? Define_Colors[time].opacity(0.6) : (status == .longCompleted ? .gray.opacity(0.6) : .brown.opacity(0.6)), lineWidth: 2.5)
                )
                .shadow(color: Color.gray.opacity(0.6), radius: 40, x: 0, y: 0)
            
            VStack(alignment: .center, spacing: 15, content: {
                Text(title)
                    .font(title.count > 10 ? .title3 : .title2)
                    .bold()
                    .padding(.bottom,5)
                
                VStack(alignment: .leading, spacing: 15, content: {
                    VStack(alignment: .leading, spacing: 5, content: {
                        Text(LocalizedStringKey("contant"))
                            .bold()
                        ScrollView {
                            Text(context)
                        }
                    })
                    .frame(height: UIScreen.main.bounds.height * (islongTerm(status) ? 0.17 : 0.11),alignment: .top)
                    if !islongTerm(status) {
                        VStack(alignment: .leading, spacing: 5, content: {
                            Text(LocalizedStringKey("approximate"))
                                .bold()
                            Text(Define_Times[time])
                        })
                        .padding(.bottom,5)
                    }
                })
                .frame(width: UIScreen.main.bounds.width * 0.75,alignment: .leading)
                .padding(.horizontal,20)
            })
            .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * (islongTerm(status) ? 0.21 : 0.24))
        }
        .overlay(alignment: .topTrailing, content: {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isDetailShow.toggle()
                }
            }, label: {
                Image(systemName: "xmark")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 25, height: 25)
                    .background(.brown)
                    .clipShape(Circle())
                
            })
            .offset(x: -7,y: 7)
        })
        
    }
    
    @ViewBuilder
    func EditTodoView() -> some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        hideKeyboard()
                    }
                }
            VStack(alignment: .trailing, spacing: 7, content: {
                Text(LocalizedStringKey("edit"))
                    .font(.title2.bold())
                    .frame(width: UIScreen.main.bounds.width * 0.9)
                    .overlay (alignment:.trailing){
                        Button(action: {
                            isEditing = false
                        }, label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .tint(.brown)
                        })
                    }
                
                VStack(alignment: .leading, spacing: 20, content: {
                    Text(LocalizedStringKey("title"))
                        .font(.body)
                    
                    TextField(LocalizedStringKey("title"), text: $currentTitle)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.black.opacity(0.4), lineWidth: 1)
                        )
                    
                    Text(LocalizedStringKey("contant"))
                    TextField(LocalizedStringKey("contant"), text: $currentContext, axis: .vertical)
                        .padding(.horizontal, 15)
                        .frame(height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.black.opacity(0.4), lineWidth: 1)
                        )
                    
                    if selectedSegment == 0 {
                        VStack(alignment: .leading, spacing: 15, content: {
                            Text(LocalizedStringKey("approximate2"))
                                .font(.body)
                            
                            HStack(spacing: 0) {
                                ForEach(Array(Define_Colors.enumerated()), id: \.element) { index, color in
                                    VStack {
                                        Circle()
                                            .fill(color)
                                            .frame(width: 20, height: 20)
                                            .scaleEffect(currentTime == index ? 1.5 : 1)
                                            .hSpacing(.center)
                                            .onTapGesture {
                                                withAnimation(.easeIn) {
                                                    currentTime = index
                                                }
                                            }
                                        Text(Define_Times[index])
                                            .font(.caption)
                                            .foregroundColor(currentTime == index ? .black : .gray)
                                    }
                                    .background {
                                        Color.clear
                                            .contentShape(Rectangle())
                                        
                                    }
                                }
                            }
                        })
                    }
                })
                .padding(.bottom,10)
                Button(action: {
                    let updateTask = Task()
                    updateTask.id = currentId
                    updateTask.title = currentTitle
                    updateTask.context = currentContext
                    updateTask.time = currentTime
                    updateTask.date = .init()
                    updateTask.status = currentStates
                    viewModel.editTask(updateTask: updateTask)
                    switch currentStates {
                    case .todo:
                        if let index = todoes.firstIndex(where: { $0.id == currentId }) {
                            todoes[index] = .init(value: updateTask)
                        }
                    case .working:
                        if let index = workings.firstIndex(where: { $0.id == currentId }) {
                            workings[index] = .init(value: updateTask)
                        }
                    case .completed:
                        if let index = completeds.firstIndex(where: { $0.id == currentId }) {
                            completeds[index] = .init(value: updateTask)
                        }
                    case .longTodo:
                        if let index = longTodoes.firstIndex(where: { $0.id == currentId }) {
                            longTodoes[index] = .init(value: updateTask)
                        }
                    case .longCompleted:
                        if let index = longCompleteds.firstIndex(where: { $0.id == currentId }) {
                            longCompleteds[index] = .init(value: updateTask)
                        }
                    }
                    isEditing = false
                    
                }, label: {
                    Text(LocalizedStringKey("edit"))
                        .bold()
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 180, height:40)
                        .disabled(currentTitle == "")
                        .opacity(currentTitle == "" ? 0.5 : 1)
                })
                .frame(width: 180, height:40)
                .background(Color.brown)
                .cornerRadius(10)
                .offset(y: 10)
                .hSpacing(.center)
                
            })
            .padding(.horizontal,20)
        }
    }
    func chancgeBoolofDetail() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if isDetailShow  {
                isDetailShow = false
            } else {
                isDetailShow = true
            }
        }
    }
    func islongTerm(_ status: Status) -> Bool {
        if status == .longTodo || status == .longCompleted {
            return true
        } else {
            return false
        }
    }
}



