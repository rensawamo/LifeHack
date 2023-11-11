////
////  LifeHackTests.swift
////  LifeHackTests
////
////  Created by sawamoren on 2023/08/11.
////
//
//import XCTest
//import RealmSwift
//@testable import LifeHack
//
//class MockRealmManager: realmManager {
//    var stubbedDiaries: [Diary] = []
//    var stubbedHeartStates: [HeartState] = []
//
//    override func getDiarys(startOfDate: Date, endOfDate: Date) -> [Diary] {
//        return stubbedDiaries
//    }
//
//    override func addDiary(newDiary: Diary) {
//        // テスト用のデータを操作
//    }
//
//    override func deleteDiary(id: ObjectId) {
//        // テスト用のデータを操作
//    }
//
//    // 他のメソッドも同様にオーバーライド
//}
//
//final class LifeHackTests: XCTestCase {
//    
//    let todoViewModel = TodoViewModel(currentDate: .init())
//    
//    func test_getAllTasks() {
//        // given
//        let vm = todoViewModel.todos
//    }
//}
