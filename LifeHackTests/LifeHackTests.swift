//
//  LifeHackTests.swift
//  LifeHackTests
//
//  Created by sawamoren on 2023/08/11.
//

import XCTest
import RealmSwift
@testable import LifeHack

final class LifeHackTests: XCTestCase {
    
    var realm: Realm {
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "Mock", ofType: "realm")!)
        return try! Realm(configuration: Realm.Configuration(fileURL: url, schemaVersion: 4))
    }
    private let todoViewModel = TodoViewModel(currentDate: .init())
    
    override func setUpWithError() throws {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
      }
    
    override func tearDownWithError() throws {
        reset()
    }
    
    private func reset() {
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    func testThreeIngredientCakeCosts9() {
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
