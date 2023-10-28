//
//  graphViewModel.swift
//  LifeHack
//
//  Created by sawamoren on 2023/10/24.
//

import SwiftUI
import RealmSwift

class graphViewModel: ObservableObject {
    
    func getGrafMemo(currentDate:Date, selectedSegment:Int) -> ([GraphMemo],Int) {
        return realmManager.shared.getGrafMemo(currentDate: currentDate, selectedSegment:selectedSegment)
    }   
    
    func getGrafState(currentDate:Date, selectedSegment:Int) -> [GraphState] {
        return realmManager.shared.getGrafState(currentDate: currentDate, selectedSegment: selectedSegment)
    }
}


