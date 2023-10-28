//
//  bookViewModel.swift
//  LifeHack
//
//  Created by sawamoren on 2023/10/24.
//

import SwiftUI
import RealmSwift

class bookViewModel: ObservableObject {
    
    @Published var books:[Book] = []
    @Published var bookCategoris:[BookCategory] = []
    @Published var bookMemoes:[BookMemo] = []
    @Published var searchBookText: String = ""
    @Published var selectedSortSegment: Int = 0
    @Published var searchBookMemoText: String = ""
    @Published var currentBookTitle: String = ""
    
    init() {
        getBook()
        getBookCategory()
        getBookMemo()
    }
    
    func getBook() {
        books = realmManager.shared.getBook(searchBookText: searchBookText, selectedSortSegment: selectedSortSegment)
        searchBookText = ""
    }
    
    func addBook(title: String,category:String, rating: Int, goal1: String,goal2: String,goal3: String) {
        realmManager.shared.addBook(title: title, category: category, rating: rating, goal1: goal1, goal2: goal2, goal3: goal3)
        getBook()
    }
    func updateBook(id: ObjectId, category: String,title:String,rating:Int,goal1:String,goal2:String,goal3:String) {
        realmManager.shared.updateBook(id: id, category: category, title: title, rating: rating, goal1: goal1, goal2: goal2, goal3: goal3)
        getBook()
    }
    
    func updateSortSegment(_ segment:Int) {
        selectedSortSegment = segment
        getBook()
    }
    
    func searchBook(_ searchText:String) {
        searchBookText = searchText
        getBook()
    }
    
    func deleteBook(id: ObjectId) {
        realmManager.shared.deleteBook(id: id)
        getBook()
    }
    
    func updateTitle(_ currentBookTitle:String) {
        self.currentBookTitle = currentBookTitle
        getBookMemo()
    }
    
    func isAlreadyTitle(_ title: String, _ bookTitle: String) -> Bool {
        return realmManager.shared.isAlreadyTitle(title, bookTitle)
    }
    
    func searchBookMemo(_ searchText:String) {
        self.searchBookMemoText = searchText
        getBookMemo()
    }
    
    func getBookMemo() {
        bookMemoes = realmManager.shared.getBookMemo(searchBookMemoText: searchBookMemoText, currentBookTitle: currentBookTitle)
        searchBookMemoText = ""
    }
    
    func addBookMemo(bookTitle: String, date: Date, title: String, contant: String, todo: String,sortNum: Int) {
        realmManager.shared.addBookMemo(bookTitle: bookTitle, date: date, title: title, contant: contant, todo: todo, sortNum: sortNum)
        getBookMemo()
    }
    
    func updateBookMemo(id: ObjectId, title:String,contant:String,todo:String) {
        realmManager.shared.updateBookMemo(id: id, title: title, contant: contant, todo: todo)
        getBookMemo()
    }
    
    func getBookCategory() {
        bookCategoris = realmManager.shared.getBookCategory()
    }
    
    func addBookCategory(category:String ) {
        realmManager.shared.addBookCategory(category: category)
        getBookCategory()
    }
    func updateBookWhyDeleteCategory(category: String) { //カテゴリが削除されたら all にする
        realmManager.shared.updateBookWhyDeleteCategory(category: category)
    }
    
    func deleteBookCategory(id: ObjectId) {
        realmManager.shared.deleteBookCategory(id: id)
        getBookCategory()
    }
    
    func isShowSortBook(_ activeTag:String) -> Bool {
        return realmManager.shared.isShowSortBook(activeTag: activeTag)
    }
    
    func updateBookCategory(fromIndex: Int, toIndex:Int,fromCategory:String,toCategory:String) {
        realmManager.shared.updateBookCategory(fromIndex: fromIndex, toIndex: toIndex, fromCategory: fromCategory, toCategory: toCategory)
    }
    
    func updateBookMemoSort(currentBookTitle: String, fromObject: String, toObject: String,fromIndex:Int,toIndex:Int) {
        realmManager.shared.updateBookMemoSort(currentBookTitle: currentBookTitle, fromObject: fromObject, toObject: toObject, fromIndex: fromIndex, toIndex: toIndex)
    }
}

