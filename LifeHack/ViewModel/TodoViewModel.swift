//
//  SwiftUIView.swift
//  LifeHack
//
//  Created by sawamoren on 2023/10/24.
//

import SwiftUI
import RealmSwift

class TodoViewModel: ObservableObject {
    @Published var todos: [Task] = []
    @Published var workings:[Task] = []
    @Published var completeds:[Task] = []
    @Published var longTodos:[Task] = []
    @Published var longCompleteds:[Task] = []
    
    @Published var currentDate: Date
    
    private var startOfDate: Date
    private var endOfDate: Date
    private var startOfMonth: Date
    private var nextMonthStart: Date
    
    init(currentDate: Date) {
        self.currentDate = currentDate
        let calendar = Calendar.current
        self.startOfDate = calendar.startOfDay(for: currentDate)
        self.endOfDate = calendar.date(byAdding: .day, value: 1, to: startOfDate)!
        self.startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date())) ?? .init()
        self.nextMonthStart  = calendar.date(byAdding: DateComponents(month: 1), to: startOfMonth) ?? .init()
        getAllTasks()
    }
    
    func getAllTasks() {
        let resultTasks = realmManager.shared.getAllTasks(startOfDate: startOfDate, endOfDate: endOfDate)
        todos = resultTasks.todos
        workings = resultTasks.working
        completeds = resultTasks.completeds
        longTodos = resultTasks.longTodos
        longCompleteds = resultTasks.longCompleteds
    }
    func getTask(status: Status) -> [Task] {
        return realmManager.shared.getTask(status: status, startOfDate: startOfDate, endOfDate: endOfDate)
    }
    
    func addTask(status:Status, task: Task) {
        realmManager.shared.addTask(task: task)
    }
    
    func updateTask(id: ObjectId, status: Status) {
        realmManager.shared.updateTask(id: id, status: status)
    }
    
    func saveCompletedTask(tasks:[Task],status:Status) {
        realmManager.shared.saveCompletedTask(todoes: tasks, status: status,startOfDate:startOfDate,endOfDate:endOfDate)
    }
    
    func saveTask(tasks:[Task],status:Status) {
        realmManager.shared.saveTask(todoes: tasks, status: status)
    }
    
    func editTask(updateTask:Task) {
        realmManager.shared.editTask(updateTask: updateTask)
    }
    
    func deleteTodo(id: ObjectId) {
        realmManager.shared.deleteTask(id: id)
        getAllTasks()
    }
}
