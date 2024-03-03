//
//  GrafModl.swift
//  LifeHack
//
//  Created by sawamoren on 2023/09/01.
//

import SwiftUI

struct InfrasionData: Identifiable {
    let id = UUID()
    let year: [Int]
    var money: [Int]
    
    init(year: [Int], money: [Int]) {
        self.year = year
        self.money = money
    }
}
