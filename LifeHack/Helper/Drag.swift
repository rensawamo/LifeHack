//
//  Drag.swift
//  LifeHack
//
//  Created by sawamoren on 2023/08/26.
//

import SwiftUI
import RealmSwift

struct Drag: DropDelegate {
    var currentBookCategory: BookCategory
    var currentDetailId:UUID
    var viewModel: bookViewModel
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropEntered(info: DropInfo) {
        //from
        let fromIndex = viewModel.bookCategoris.firstIndex { (currentBookCategory) -> Bool in
            return currentBookCategory.dragableId == currentDetailId
        } ?? 0
        
        // to
        let toIndex = viewModel.bookCategoris.firstIndex { (currentBookCategory) -> Bool in
            return currentBookCategory.dragableId == self.currentBookCategory.dragableId
        } ?? 0
        
        if fromIndex != toIndex {
            withAnimation(.default) {
                let fromObject = viewModel.bookCategoris[fromIndex]
                let toCategory = viewModel.bookCategoris[toIndex].category
                viewModel.bookCategoris[fromIndex] = viewModel.bookCategoris[toIndex]
                viewModel.bookCategoris[toIndex] = fromObject
                //DB update
                viewModel.updateBookCategory(fromIndex: fromIndex, toIndex: toIndex,fromCategory:fromObject.category, toCategory: toCategory)
            }
        }
    }
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}


struct Drag2: DropDelegate {
    var currentBookMemo: BookMemo
    var currentDetailId:UUID
    var viewModel: bookViewModel
    var bookTitle:String
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let fromObject = viewModel.bookMemoes.first(where: { $0.dragableId == currentDetailId }),
              let toObject = viewModel.bookMemoes.first(where: { $0.dragableId == self.currentBookMemo.dragableId }) else {
            return
        }
    
        guard let fromIndex = viewModel.bookMemoes.firstIndex(of: fromObject),
              let toIndex = viewModel.bookMemoes.firstIndex(of: toObject) else {
            return
        }
        
        if fromIndex != toIndex {
            withAnimation(.default) {
                viewModel.bookMemoes.swapAt(fromIndex, toIndex)
                // DB update
                viewModel.updateBookMemoSort(currentBookTitle: bookTitle,
                                                fromObject: fromObject.title, toObject: toObject.title,fromIndex:fromIndex,toIndex: toIndex)
            }
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}
