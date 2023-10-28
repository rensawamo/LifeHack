//
//  function.swift
//  LifeHack
//
//  Created by sawamoren on 2023/08/11.
//

import UIKit

func dismissKeyboard() {
    UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.endEditing(true) // 4
}

func isCurret(date1: Date,date2: Date)->Bool{
    let calendar = Calendar.current
    return calendar.isDate(date1, inSameDayAs: date2)
}

func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd"
    return formatter.string(from: date)
}

func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}
