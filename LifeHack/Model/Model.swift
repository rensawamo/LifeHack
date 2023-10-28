//
//  Model.swift
//  LifeHack
//
//  Created by sawamoren on 2023/08/11.
//
import Foundation
import RealmSwift
import SwiftUI

enum Tab: String, CaseIterable {
    case calendar = "calender"
    case checklist = "work"
    case book = "memo"
    case plus = "diary"
    case function = "graph"
    
    var systemImage: String {
        switch self {
        case .calendar:
            return "calendar"
        case .checklist:
            return "checklist"
        case .book:
            return "book"
        case .function:
            return "chart.pie"
        case .plus:
            return "pencil.line"
        }
    }
    var index: Int {
        return Tab.allCases.firstIndex(of: self) ?? 0
    }
}

class Diary: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var date: Date
    @Persisted var text:String
    @Persisted var photo:Data?
}

class HeartState: Object,ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var date: Date
    @Persisted var systemImage:String
}

enum StateColor {
    case red
    case black
    case blue
    init(stateImage: String) {
        switch stateImage {
        case "sun.max":
            self = .red
        case "cloud":
            self = .black
        case "cloud.rain":
            self = .blue
        default:
            self = .blue
        }
    }
    var tintColor: Color {
        switch self {
        case .red:
            return Color.red
        case .black:
            return Color.black.opacity(0.8)
        case .blue:
            return Color.blue
        }
    }
}

struct DateValue: Identifiable{
    var id = UUID().uuidString
    var day: Int
    var year: Int
    var month:Int
    var date: Date
}

func getSampleDate(offset: Int)->Date{
    let calender = Calendar.current
    let date = calender.date(byAdding: .day, value: offset, to: Date())
    return date ?? Date()
}

struct TaskMetaData: Identifiable{
    var id = UUID().uuidString
    var task: [Task]
    var taskDate: Date
}

class Task: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var dragableId: UUID = .init()
    @Persisted var title: String
    @Persisted var context: String
    @Persisted var time: Int
    @Persisted var date: Date
    @Persisted var status: Status
}

enum Status: String, RawRepresentable, PersistableEnum {
    // 短期
    case todo
    case working
    case completed
    // 長期
    case longTodo
    case longCompleted
}

// Book
class Book: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var category: String
    @Persisted var title: String
    @Persisted var rating: Int
    @Persisted var goal1: String
    @Persisted var goal2: String
    @Persisted var goal3: String
    @Persisted var resistedDate: Date
    @Persisted var updateDate: Date
}

class BookCategory: Object,ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var dragableId: UUID = .init()
    @Persisted var category: String
}

class BookMemo: Object,ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var dragableId: UUID = .init()
    @Persisted var bookTitle: String
    @Persisted var date: Date
    @Persisted var title: String
    @Persisted var contant: String
    @Persisted var todo: String
    @Persisted var sortNum: Int
}

class GraphMemo: Object,ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var name: String
    @Persisted var percent: Int
}

class GraphState: Object,ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var day: Int
    @Persisted var percent: Int
}
