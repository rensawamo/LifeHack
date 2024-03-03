//
//  PoperInnerView.swift
//  LifeHack
//
//  Created by sawamoren on 2023/08/19.
//

import SwiftUI

struct CompleteAlert: View {
    var body: some View {
        Text(LocalizedStringKey("poper1"))
    }
}

struct DaiaryPoperView: View {
    var body: some View {
        Text(LocalizedStringKey("poper2"))
    }
}

struct BookPoperView: View {
    var body: some View {
        Text(LocalizedStringKey("poper3"))
    }
}

struct DetailTodoView_Previews: PreviewProvider {
    static var previews: some View {
        CompleteAlert()
    }
}
