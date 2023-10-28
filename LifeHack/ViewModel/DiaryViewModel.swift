//
//  DiaryViewModel.swift
//  LifeHack
//
//  Created by sawamoren on 2023/10/24.
//

import SwiftUI
import RealmSwift

class DiaryViewModel: ObservableObject {
    @Published var diaries: [Diary] = []
    @Published var heartStates:[HeartState] = [] //今月全部
    @Published var todayState:HeartState? = nil
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
        self.startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) ?? .init()
        self.nextMonthStart  = calendar.date(byAdding: DateComponents(month: 1), to: startOfMonth) ?? .init()
        getDiary()
        getTodayHeartState()
        getMonthHeartStates()
    }
    
    func getDiary() {
        diaries = realmManager.shared.getDiarys(startOfDate: startOfDate, endOfDate: endOfDate)
    }
    
    func addDiary(date:Date, text: String,photo: Data?) {
        let newDiary = Diary(value: ["date":date, "text": text, "photo": photo] as [String : Any])
        realmManager.shared.addDiary(newDiary: newDiary)
        getDiary()
    }
    
    func deleteDiary(id :ObjectId) {
        realmManager.shared.deleteDiary(id: id)
        getDiary()
    }
    
    func updateDiary(id: ObjectId, text: String) {
        realmManager.shared.updateDiary(id: id, text: text)
        getDiary()
    }
    
    func addTodayState(img: String) {
        realmManager.shared.addState(img:img)
        getTodayHeartState()
    }
    
    func getTodayHeartState() {
        todayState = realmManager.shared.getHeartState(startOfDate: startOfDate, endOfDate: endOfDate)
    }
    
    func getMonthHeartStates() {
        heartStates = []
        heartStates = realmManager.shared.getMonthHeartStates(startOfMonth: startOfMonth, endOfMonth: nextMonthStart)
    }
    
    func updateState(id: ObjectId, img: String) {
        todayState = realmManager.shared.updateState(id: id, img: img, startOfDate: startOfDate, endOfDate: endOfDate)
    }
}


