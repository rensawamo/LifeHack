//
//  selectablePoperView.swift
//  LifeHack
//
//  Created by sawamoren on 2023/08/19.
//

import SwiftUI

enum DisplayView {
    case DetailTodo
    case DaiaryPoper
    case BookPoper
}

struct PoperView: View {
    @Binding var isShowPopover:Bool
    var width:Double = 0.4
    var height:Double = 0.2
    var text:String = ""
    var isStructShow:Bool = false
    var selectContent: DisplayView = .DetailTodo
    
    var body: some View {
        VStack (alignment: .trailing){
            
            VStack {
                if isStructShow {
                    switch selectContent {
                    case .DetailTodo:
                        CompleteAlert()
                    case .DaiaryPoper:
                        DaiaryPoperView()
                    case .BookPoper:
                        BookPoperView()
                    default:
                        Text("error")
                    }
                } else {
                    Text(text)
                        .font(.title)
                        .tint(.brown)
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width * width,height: UIScreen.main.bounds.height * height,alignment: .top)
        .padding(.horizontal,20)
        .padding(.top,30)
    }
}
