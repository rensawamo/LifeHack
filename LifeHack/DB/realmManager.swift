import Foundation
import SwiftUI
import Network
import RealmSwift


final class realmManager {
    private(set) var localRealm: Realm?
    static let shared = realmManager()
    
    private init() {
        openRealm()
    }
    func openRealm() {
        do {
            let config = Realm.Configuration(schemaVersion: 1)
            Realm.Configuration.defaultConfiguration = config
            
            localRealm = try Realm()
        } catch {
            print("Error opening Realm", error)
        }
    }
    
    // MARK: - Diary
    func getDiarys(startOfDate:Date,endOfDate:Date) -> [Diary] {
        var diaries: [Diary] = []
        if let localRealm = localRealm {
            let predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDate as CVarArg, endOfDate as CVarArg)
            let allDiaries = localRealm.objects(Diary.self).filter(predicate)
            allDiaries.forEach { diary in
                diaries.append(.init(value: diary))
            }
        }
        return diaries
    }
    
    func addDiary(newDiary:Diary) {
        if let localRealm = localRealm {
            do {
                try localRealm.write {
                    localRealm.add(newDiary)
                }
            } catch {
                print("Error adding task to Realm: \(error)")
            }
        }
    }
    
    func deleteDiary(id: ObjectId) {
        if let localRealm = localRealm {
            do {
                let taskToDelete = localRealm.objects(Diary.self).filter(NSPredicate(format: "id == %@", id))
                guard !taskToDelete.isEmpty else { return }
                try localRealm.write {
                    localRealm.delete(taskToDelete)
                    print("Deleted task with id \(id)")
                }
            } catch {
                print("Error deleting task \(id) to Realm: \(error)")
            }
        }
    }
    
    func updateDiary(id: ObjectId, text: String) {
        if let localRealm = localRealm {
            do {
                let DiaryToUpdate = localRealm.objects(Diary.self).filter(NSPredicate(format: "id == %@", id))
                guard !DiaryToUpdate.isEmpty else { return }
                try localRealm.write {
                    DiaryToUpdate[0].text = text
                }
            } catch {
                print("Error updating task \(id) to Realm: \(error)")
            }
        }
    }
    
    func addState(img: String) {
        if let localRealm = localRealm {
            do {
                try localRealm.write {
                    let newState = HeartState(value:["date":Date(),"systemImage":img] as [String : Any])
                    localRealm.add(newState)
                }
            } catch {
                print("Error adding task to Realm: \(error)")
            }
        }
    }
    
    func updateState(id: ObjectId, img: String,startOfDate:Date,endOfDate:Date) -> HeartState? {
        if let localRealm = localRealm {
            do {
                let StateToUpdate = localRealm.objects(HeartState.self).filter(NSPredicate(format: "id == %@", id))
                guard !StateToUpdate.isEmpty else { return .init()}
                try localRealm.write {
                    StateToUpdate[0].systemImage = img
                }
            } catch {
                print("Error updating task \(id) to Realm: \(error)")
            }
        }
        return getHeartState(startOfDate:startOfDate,endOfDate:endOfDate)
    }
    
    func getHeartState(startOfDate:Date,endOfDate:Date) -> HeartState? {
        var heartState:HeartState? = nil
        let predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDate as CVarArg, endOfDate as CVarArg)
        if let localRealm = localRealm {
            if let firstHeartState = localRealm.objects(HeartState.self).filter(predicate).first {
                heartState = firstHeartState
            }
        }
        return heartState
    }
    
    func getMonthHeartStates(startOfMonth:Date,endOfMonth:Date) -> [HeartState] {
        let predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfMonth as CVarArg, endOfMonth as CVarArg)
        var heartStates:[HeartState] = []
        if let localRealm = localRealm {
            let allStates = localRealm.objects(HeartState.self).filter(predicate)
            allStates.forEach { state in
                heartStates.append(state)
            }
        }
        return heartStates
    }
    
    
    // MARK: - Todo
    func getTask(status: Status,startOfDate:Date,endOfDate:Date) -> [Task] {
        var results: [Task] = []
        var predicate: NSPredicate
        if let localRealm = realmManager.shared.localRealm {
            switch status {
            case .todo:
                predicate = NSPredicate(format: "status == %@", Status.todo.rawValue)
                let allTodos = localRealm.objects(Task.self).filter(predicate)
                allTodos.forEach { todo in
                    results.append(.init(value: todo))
                }
            case .working:
                predicate = NSPredicate(format: "status == %@", Status.working.rawValue)
                let allworkings = localRealm.objects(Task.self).filter(predicate)
                allworkings.forEach { working in
                    results.append(.init(value: working))
                }
            case .completed:
                predicate = NSPredicate(format: "status == %@ AND date >= %@ AND date < %@", Status.completed.rawValue, startOfDate as CVarArg, endOfDate as CVarArg)
                let allcompleteds = localRealm.objects(Task.self).filter(predicate)
                allcompleteds.forEach { complete in
                    results.append(.init(value: complete))
                }
            case .longTodo:
                predicate = NSPredicate(format: "status == %@ AND date >= %@ AND date < %@", Status.longTodo.rawValue, startOfDate as CVarArg, endOfDate as CVarArg)
                let allTryTodos = localRealm.objects(Task.self).filter(predicate)
                allTryTodos.forEach { trytodo in
                    results.append(.init(value: trytodo))
                }
            case .longCompleted:
                predicate =  NSPredicate(format: "status == %@ AND date >= %@ AND date < %@", Status.longCompleted.rawValue, startOfDate as CVarArg, endOfDate as CVarArg)
                let allTrycompleteds = localRealm.objects(Task.self).filter(predicate)
                allTrycompleteds.forEach { trycomplete in
                    results.append(.init(value: trycomplete))
                }
            }
        }
        return results
    }
    
    func getAllTasks(startOfDate:Date,endOfDate:Date) -> (todos:[Task],working:[Task],completeds:[Task],longTodos:[Task],longCompleteds:[Task]) {
        var todos:[Task] = []
        var workings:[Task] = []
        var completeds:[Task] = []
        var longTodos:[Task] = []
        var longCompleteds:[Task] = []
        
        if let localRealm = realmManager.shared.localRealm {
            let todoPredicate = NSPredicate(format: "status == %@", Status.todo.rawValue)
            let longtodoPredicate = NSPredicate(format: "status == %@", Status.longTodo.rawValue)
            let workingsPredicate = NSPredicate(format: "status == %@", Status.working.rawValue)
            let completedsPredicate = NSPredicate(format: "status == %@ AND date >= %@ AND date < %@", Status.completed.rawValue, startOfDate as CVarArg, endOfDate as CVarArg)
            let longcompletedsPredicate = NSPredicate(format: "status == %@ AND date >= %@ AND date < %@", Status.longCompleted.rawValue, startOfDate as CVarArg, endOfDate as CVarArg)
            let allTodos = localRealm.objects(Task.self).filter(todoPredicate)
            let allworkings = localRealm.objects(Task.self).filter(workingsPredicate)
            let allcompleteds = localRealm.objects(Task.self).filter(completedsPredicate)
            let allTryTodos = localRealm.objects(Task.self).filter(longtodoPredicate)
            let allTrycompleteds = localRealm.objects(Task.self).filter(longcompletedsPredicate)
            allTodos.forEach { t in
                todos.append(.init(value: t))
            }
            allworkings.forEach { w in
                workings.append(.init(value: w))
            }
            allcompleteds.forEach { c in
                completeds.append(.init(value: c))
            }
            allTryTodos.forEach { tt in
                longTodos.append(.init(value: tt))
            }
            allTrycompleteds.forEach { ct in
                longCompleteds.append(.init(value: ct))
            }
        }
        return (todos,workings,completeds,longTodos,longCompleteds)
    }
    
    func addTask(task: Task) {
        do {
            try localRealm?.write {
                localRealm?.add(task)
            }
        } catch {
            print("Error saving task: \(error)")
        }
    }
    
    
    func updateTask(id: ObjectId, status: Status) {
        if let localRealm = localRealm {
            do {
                let StateToUpdate = localRealm.objects(Task.self).filter(NSPredicate(format: "id == %@", id as CVarArg))
                guard !StateToUpdate.isEmpty else { return }
                try localRealm.write {
                    StateToUpdate[0].status = status
                    StateToUpdate[0].date = Date()
                }
            } catch {
                print("Error updating task \(id) to Realm: \(error)")
            }
        }
    }
    
    func editTask(updateTask:Task) {
        if let localRealm = localRealm {
            do {
                let StateToUpdate = localRealm.objects(Task.self).filter(NSPredicate(format: "id == %@", updateTask.id as CVarArg))
                guard !StateToUpdate.isEmpty else { return }
                try localRealm.write {
                    StateToUpdate[0].title = updateTask.title
                    StateToUpdate[0].context = updateTask.context
                    StateToUpdate[0].time = updateTask.time
                }
            } catch {
                print("Error updating task \(updateTask.id) to Realm: \(error)")
            }
        }
    }
    
    func deleteTask(id: ObjectId) {
        if let localRealm = localRealm {
            do {
                let taskToDelete = localRealm.objects(Task.self).filter(NSPredicate(format: "id == %@", id))
                guard !taskToDelete.isEmpty else { return }
                try localRealm.write {
                    localRealm.delete(taskToDelete)
                }
                print("deleted")
            } catch {
                print("Error deleting task \(id) to Realm: \(error)")
            }
        }
    }
    
    func saveTask(todoes:[Task],status:Status) {
        if let localRealm = realmManager.shared.localRealm {
            do {
                let TodoToUpdate = localRealm.objects(Task.self).filter(NSPredicate(format: "status == %@", status.rawValue))
                try localRealm.write {
                    guard !TodoToUpdate.isEmpty else { return }
                    for (index, todo) in todoes.enumerated() {
                        TodoToUpdate[index].dragableId = todo.dragableId
                        TodoToUpdate[index].title = todo.title
                        TodoToUpdate[index].context = todo.context
                        TodoToUpdate[index].time = todo.time
                        TodoToUpdate[index].date = Date()
                    }
                }
            } catch {
                print("Error updating task  to Realm: \(error)")
            }
        }
    }
    
    func saveCompletedTask(todoes:[Task],status:Status,startOfDate:Date,endOfDate:Date) {
        if let localRealm = realmManager.shared.localRealm {
            do {
                if status == .completed || status == .longCompleted {
                    let TodoToUpdate = localRealm.objects(Task.self).filter(NSPredicate(format: "status == %@ AND date >= %@ AND date < %@", status.rawValue, startOfDate as CVarArg, endOfDate as CVarArg))
                    try localRealm.write {
                        guard !TodoToUpdate.isEmpty else { return }
                        for (index, todo) in todoes.enumerated() {
                            TodoToUpdate[index].dragableId = todo.dragableId
                            TodoToUpdate[index].title = todo.title
                            TodoToUpdate[index].context = todo.context
                            TodoToUpdate[index].time = todo.time
                            TodoToUpdate[index].date = Date()
                        }
                    }
                }
            } catch {
                print("Error updating task  to Realm: \(error)")
            }
        }
    }
    
    // MARK: - book
    func addBook(title: String,category:String, rating: Int, goal1: String,goal2: String,goal3: String) {
        let book = Book()
        book.title = title
        book.category = category
        book.rating = rating
        book.goal1 = goal1
        book.goal2 = goal2
        book.goal3 = goal3
        book.resistedDate = Date()
        book.updateDate = Date()
        do {
            try realmManager.shared.localRealm?.write {
                realmManager.shared.localRealm?.add(book)
            }
        } catch {
            print("Error saving task: \(error)")
        }
    }
    func deleteBook(id: ObjectId) {
        if let localRealm = localRealm {
            do {
                let taskToDelete = localRealm.objects(Book.self).filter(NSPredicate(format: "id == %@", id))
                guard !taskToDelete.isEmpty else { return }
                try localRealm.write {
                    localRealm.delete(taskToDelete)
                    print("Deleted task with id \(id)")
                }
            } catch {
                print("Error deleting task \(id) to Realm: \(error)")
            }
        }
    }
    func updateBook(id: ObjectId, category: String,title:String,rating:Int,goal1:String,goal2:String,goal3:String) {
        if let localRealm = localRealm {
            do {
                let DiaryToUpdate = localRealm.objects(Book.self).filter(NSPredicate(format: "id == %@", id))
                guard !DiaryToUpdate.isEmpty else { return }
                try localRealm.write {
                    DiaryToUpdate[0].category = category
                    DiaryToUpdate[0].title = title
                    DiaryToUpdate[0].rating = rating
                    DiaryToUpdate[0].goal1 = goal1
                    DiaryToUpdate[0].goal2 = goal2
                    DiaryToUpdate[0].goal3 = goal3
                    DiaryToUpdate[0].updateDate = Date()
                }
            } catch {
                print("Error updating task \(id) to Realm: \(error)")
            }
        }
    }
    func getBook(searchBookText:String,selectedSortSegment:Int) -> [Book] {
        var books:[Book] = []
        if let localRealm = realmManager.shared.localRealm {
            if searchBookText != "" {
                let allBooks = localRealm.objects(Book.self).filter("title CONTAINS[c] %@ OR goal1 CONTAINS[c] %@ OR goal2 CONTAINS[c] %@ OR goal3 CONTAINS[c] %@", searchBookText, searchBookText, searchBookText, searchBookText)
                allBooks.forEach { book in
                    books.append(book)
                }
            } else {
                let allBooks: Results<Book>
                if selectedSortSegment == 0 {
                    allBooks = localRealm.objects(Book.self).sorted(byKeyPath: "resistedDate", ascending: false)
                } else if selectedSortSegment == 1 {
                    allBooks = localRealm.objects(Book.self).sorted(byKeyPath: "resistedDate", ascending: false).sorted(byKeyPath: "rating", ascending: false)
                    
                } else {
                    allBooks = localRealm.objects(Book.self)
                }
                books = []
                allBooks.forEach { book in
                    books.append(book)
                }
            }
        }
        return books
    }
    
    func getBookMemo(searchBookMemoText:String,currentBookTitle:String) -> [BookMemo] {
        var bookMemoes:[BookMemo] = []
        if let localRealm = localRealm  {
            if searchBookMemoText != "" { // 検索
                let allBooks = localRealm.objects(BookMemo.self).filter("title CONTAINS[c] %@ OR contant CONTAINS[c] %@ OR todo CONTAINS[c]  %@", searchBookMemoText, searchBookMemoText, searchBookMemoText).sorted(byKeyPath: "sortNum", ascending: true)
                allBooks.forEach { book in
                    bookMemoes.append(book)
                }
            } else { //全部
                let allBooks = localRealm.objects(BookMemo.self).filter("bookTitle == %@", currentBookTitle).sorted(byKeyPath: "sortNum", ascending: true)
                bookMemoes = []
                allBooks.forEach { book in
                    bookMemoes.append(book)
                }
            }
        }
        return bookMemoes
    }
    
    func updateBookMemo(id: ObjectId, title:String,contant:String,todo:String) {
        if let localRealm = localRealm {
            do {
                let DiaryToUpdate = localRealm.objects(BookMemo.self).filter(NSPredicate(format: "id == %@", id))
                guard !DiaryToUpdate.isEmpty else { return }
                try localRealm.write {
                    DiaryToUpdate[0].title = title
                    DiaryToUpdate[0].contant = contant
                    DiaryToUpdate[0].todo = todo
                }
            } catch {
                print("Error updating task \(id) to Realm: \(error)")
            }
        }
    }
    
    func addBookMemo(bookTitle: String, date: Date, title: String, contant: String, todo: String,sortNum: Int) {
        let bookMemo = BookMemo()
        bookMemo.bookTitle = bookTitle
        bookMemo.date = date
        bookMemo.title = title
        bookMemo.contant = contant
        bookMemo.todo = todo
        bookMemo.sortNum = sortNum
        do {
            try localRealm?.write {
                localRealm?.add(bookMemo)
            }
        } catch {
            print("Error saving task: \(error)")
        }
    }
    
    func getBookCategory() -> [BookCategory] {
        var bookCategoris:[BookCategory] = []
        if let localRealm = localRealm {
            let allBookCategories = localRealm.objects(BookCategory.self)
            allBookCategories.forEach { bookCategory in
                bookCategoris.append(.init(value: bookCategory))
            }
        }
        return bookCategoris
    }
    
    func updateBookWhyDeleteCategory(category: String) {
        if let localRealm = localRealm {
            do {
                let allBooks = localRealm.objects(Book.self).filter(NSPredicate(format: "category == %@", category))
                guard !allBooks.isEmpty else { return }
                try localRealm.write {
                    allBooks.forEach { book in
                        book.category = "all"
                    }
                }
            } catch {
                print("Error updating task \(category) to Realm: \(error)")
            }
        }
    }
    
    func deleteBookCategory(id: ObjectId) {
        if let localRealm = localRealm {
            do {
                let taskToDelete = localRealm.objects(BookCategory.self).filter(NSPredicate(format: "id == %@", id))
                guard !taskToDelete.isEmpty else { return }
                try localRealm.write {
                    localRealm.delete(taskToDelete)
                    print("Deleted task with id \(id)")
                }
            } catch {
                print("Error deleting task \(id) to Realm: \(error)")
            }
        }
    }
    
    func updateBookMemoSort(currentBookTitle: String, fromObject: String, toObject: String,fromIndex:Int,toIndex:Int) {
        guard let localRealm = localRealm else { return }
        do {
            let stateToUpdate = localRealm.objects(BookMemo.self).filter("bookTitle == %@", currentBookTitle)
            guard !stateToUpdate.isEmpty else { return }
            
            try localRealm.write {
                if let from = stateToUpdate.first(where: { $0.title == fromObject }) {
                    from.sortNum = toIndex
                }
                if let to = stateToUpdate.first(where: { $0.title == toObject }) {
                    to.sortNum = fromIndex
                }
            }
        } catch {
            print("Error updating task to Realm: \(error)")
        }
    }
    
    func addBookCategory(category:String ) {
        let bookCategory = BookCategory()
        bookCategory.category = category
        do {
            try localRealm?.write {
                localRealm?.add(bookCategory)
            }
        } catch {
            print("Error saving task: \(error)")
        }
    }
    
    func isAlreadyTitle(_ title: String, _ bookTitle: String) -> Bool {
        if let localRealm = localRealm {
            let filteredBooks = localRealm.objects(BookMemo.self).filter("title == %@ AND bookTitle == %@", title, bookTitle)
            return !filteredBooks.isEmpty
        }
        return false
    }
    
    func isShowSortBook(activeTag:String) -> Bool {
        if activeTag == "all" {
            return true
        }
        if let localRealm = localRealm {
            let allBookCategories = localRealm.objects(Book.self).filter("category == %@", activeTag)
            var ary:[Book] = []
            allBookCategories.forEach { bookCategory in
                ary.append(.init(value: bookCategory))
            }
            if ary.isEmpty {
                return false
            } else {
                return true
            }
        }
        return true
    }
    
    func updateBookCategory(fromIndex: Int, toIndex:Int,fromCategory:String,toCategory:String) {
        if let localRealm = localRealm {
            do {
                let StateToUpdate = localRealm.objects(BookCategory.self)
                guard !StateToUpdate.isEmpty else { return }
                try localRealm.write {
                    StateToUpdate[fromIndex].category = toCategory
                    StateToUpdate[toIndex].category = fromCategory
                }
            } catch {
                print("Error updating task \("") to Realm: \(error)")
            }
        }
    }
    
    // MARK: - graph
    func getGrafMemo(currentDate:Date, selectedSegment:Int) -> ([GraphMemo],Int) {
        var graphMemoes:[GraphMemo] = []
        var totalCount: Int = 0
        if let localRealm = localRealm {
            let calendar = Calendar.current
            var predicate: NSPredicate? = nil
            if selectedSegment == 0 {
                if let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) {
                    if let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) {
                        predicate = NSPredicate(format: "resistedDate >= %@ AND resistedDate < %@", startOfMonth as CVarArg, endOfMonth as CVarArg)
                    }
                }
            } else if selectedSegment == 1 { // 3ヶ月
                let currentDate = Date()
                if let startOfThreeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: currentDate) {
                    let endOfMonth = currentDate
                    predicate = NSPredicate(format: "resistedDate >= %@ AND resistedDate <= %@", startOfThreeMonthsAgo as CVarArg, endOfMonth as CVarArg)
                }
            } else if selectedSegment == 2 {
                let currentDate = Date()
                if let startOfThreeMonthsAgo = calendar.date(byAdding: .month, value: -6, to: currentDate) {
                    let endOfMonth = currentDate
                    predicate = NSPredicate(format: "resistedDate >= %@ AND resistedDate <= %@", startOfThreeMonthsAgo as CVarArg, endOfMonth as CVarArg)
                }
            } else {
                let currentDate = Date()
                if let startOfThreeMonthsAgo = calendar.date(byAdding: .month, value: -12, to: currentDate) {
                    let endOfMonth = currentDate
                    predicate = NSPredicate(format: "resistedDate >= %@ AND resistedDate <= %@", startOfThreeMonthsAgo as CVarArg, endOfMonth as CVarArg)
                }
            }
            let allBooks = localRealm.objects(Book.self).filter(predicate!)
            if allBooks.isEmpty {
                return ([],0)
            }
            getBookCategory().forEach { category in
                let count = allBooks.filter { $0.category == category.category }.count
                if category.category != "all" {
                    graphMemoes.append(createGrafMemo(category.category, count))
                    totalCount += count
                } else {
                    totalCount += count
                }
            }
        }
        return (graphMemoes,totalCount)
    }
    
    func createGrafMemo(_ name:String, _ day:Int) -> GraphMemo {
        let grafMemo = GraphMemo()
        grafMemo.name = name
        grafMemo.percent = day
        return grafMemo
    }
    
    func getGrafState(currentDate:Date, selectedSegment:Int) -> [GraphState] {
        var allGraphStates:[GraphState] = []
        if let localRealm = realmManager.shared.localRealm {
            let calendar = Calendar.current
            if selectedSegment == 0 {
                if let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) {
                    if let nextMonthStart = calendar.date(byAdding: DateComponents(month: 1), to: startOfMonth) {
                        let predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfMonth as CVarArg, nextMonthStart as CVarArg)
                        let allHeartStatus = localRealm.objects(HeartState.self).filter(predicate)
                        if allHeartStatus.isEmpty {
                            return []
                        }
                        allGraphStates = createGetGrafState(allHeartStatus)
                    } else {
                        fatalError("Couldn't calculate start of next month")
                    }
                } else {
                    fatalError("Couldn't calculate start of month")
                }
            } else if selectedSegment == 1 { // 3ヶ月
                let currentDate = Date()
                if let startOfThreeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: currentDate) {
                    let endOfMonth = currentDate
                    let predicate = NSPredicate(format: "date >= %@ AND date <= %@", startOfThreeMonthsAgo as CVarArg, endOfMonth as CVarArg)
                    let allHeartStatus = localRealm.objects(HeartState.self).filter(predicate)
                    if allHeartStatus.isEmpty {
                        return []
                    }
                    allGraphStates = createGetGrafState(allHeartStatus)
                }
            } else if selectedSegment == 2 {
                let currentDate = Date()
                if let startOfThreeMonthsAgo = calendar.date(byAdding: .month, value: -6, to: currentDate) {
                    let endOfMonth = currentDate
                    let predicate = NSPredicate(format: "date >= %@ AND date <= %@", startOfThreeMonthsAgo as CVarArg, endOfMonth as CVarArg)
                    let allHeartStatus = localRealm.objects(HeartState.self).filter(predicate)
                    if allHeartStatus.isEmpty {
                        return []
                    }
                    allGraphStates = createGetGrafState(allHeartStatus)
                }
            } else {
                let currentDate = Date()
                if let startOfThreeMonthsAgo = calendar.date(byAdding: .month, value: -12, to: currentDate) {
                    let endOfMonth = currentDate
                    let predicate = NSPredicate(format: "date >= %@ AND date <= %@", startOfThreeMonthsAgo as CVarArg, endOfMonth as CVarArg)
                    let allHeartStatus = localRealm.objects(HeartState.self).filter(predicate)
                    if allHeartStatus.isEmpty {
                        return []
                    }
                    allGraphStates = createGetGrafState(allHeartStatus)
                }
            }
        }
        return allGraphStates
    }
    
    func createGetGrafState(_ allHeartStatus :Results<HeartState>) -> [GraphState]{
        var returns:[GraphState] = []
        var sunDay:Int = 0
        var cloudDay: Int = 0
        var rainDay: Int = 0
        var totalDay: Int = 0
        
        allHeartStatus.forEach { status in
            if status.systemImage == "sun.max" {
                sunDay += 1
                totalDay += 1
            } else if status.systemImage == "cloud" {
                cloudDay += 1
                totalDay += 1
            } else if status.systemImage == "cloud.rain"{
                rainDay += 1
                totalDay += 1
            }
        }
        let grafSunState = GraphState()
        grafSunState.day = sunDay
        grafSunState.percent =  Int(Double(sunDay) / Double(totalDay) * 100)
        let grafCloudState = GraphState()
        grafCloudState.day = cloudDay
        grafCloudState.percent =  Int(Double(cloudDay) / Double(totalDay) * 100)
        let grafRainState = GraphState()
        grafRainState.day = rainDay
        grafRainState.percent =  Int(Double(rainDay) / Double(totalDay) * 100)
        returns.append(grafSunState)
        returns.append(grafCloudState)
        returns.append(grafRainState)
        return returns
    }
    
}



