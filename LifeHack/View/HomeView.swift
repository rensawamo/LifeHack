//
//  HomeView.swift
//  LifeHack
//
//  Created by sawamoren on 2023/08/11.

import SwiftUI
struct HomeView: View {
    
    @State private var activeTab: Tab = .calendar
    @Namespace private var animation
    @State private var tabShapePosition: CGPoint = .zero
    @State var isKeyboad:Bool = false
    @State var currentBookTitle: String = ""
    @State var currentDate: Date = .init()
    @StateObject var todoViewModel = TodoViewModel(currentDate: Date())
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $activeTab) {
                CarenderView(currentDate: $currentDate)
                    .environmentObject(DiaryViewModel(currentDate: currentDate))
                    .environmentObject(TodoViewModel(currentDate: currentDate))
                    .tag(Tab.calendar)
                
                TodoView(todoes: todoViewModel.todos, workings: todoViewModel.workings, completeds: todoViewModel.completeds, longTodoes: todoViewModel.longTodos, longCompleteds: todoViewModel.longCompleteds)
                    .tag(Tab.checklist)
                
                BookView(currentBookTitle: $currentBookTitle)
                    .tag(Tab.book)
                
                DiaryView(isKeyboad: $isKeyboad)
                    .tag(Tab.plus)
                
//                GrafView(grafStates: realmManager.getGrafState(Date(), 0), grafMemoes: realmManager.getGrafMemo(Date(),0).0)
                GrafView()
                    .tag(Tab.function)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .padding(.vertical,30)
            .padding(.horizontal,10)
            .overlay(alignment:.bottom) {
                
                CustomTabBar()
                    .background(Color(red: 255/255, green: 250/255, blue: 250/255))
                    .opacity(isKeyboad ? 0 : 1)
                    .overlay(
                        Divider()
                            .background(Color.gray.opacity(0.1))
                            .frame(maxWidth: .infinity, maxHeight: 1)
                            .padding([.leading, .trailing], 0),
                        alignment: .top
                    )
                
            }
        }
        .background(Color.customBackground)
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    func CustomTabBar() -> some View {
        HStack(alignment: .bottom, spacing: 0) {
            ForEach(Tab.allCases, id: \.rawValue) {
                TabItem(
                    tab: $0,
                    animation: animation,
                    activeTab: $activeTab,
                    position: $tabShapePosition
                )
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, UIScreen.main.hasHomeButton ? 15 : 6)
        .padding(.bottom, UIScreen.main.hasHomeButton ? 24 : 0)
        .animation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 1), value: activeTab)
    }
}

struct TabItem: View {
    var tab: Tab
    var animation: Namespace.ID
    @Binding var activeTab: Tab
    @Binding var position: CGPoint
    @State private var tabPosition: CGPoint = .zero
    var body: some View {
        VStack(spacing: 7) {
            VStack (spacing:4){
                Image(systemName: tab.systemImage)
                    .font(.title3)
                Text(LocalizedStringKey(tab.rawValue))
                    .font(.caption2)
            }
            .foregroundColor(activeTab == tab ? CurrentColor : .brown)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .viewPosition(completion: { rect in
            tabPosition.x = rect.midX
            if activeTab == tab {
                position.x = rect.midX
            }
        })
        .onTapGesture {
            activeTab = tab
            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
                position.x = tabPosition.x
            }
        }
    }
}

struct PositionKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

extension View {
    @ViewBuilder
    func viewPosition(completion: @escaping (CGRect) -> ()) -> some View {
        self
            .overlay {
                GeometryReader {
                    let rect = $0.frame(in: .global)
                    Color.clear
                        .preference(key: PositionKey.self, value: rect)
                        .onPreferenceChange(PositionKey.self, perform: completion)
                }
            }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
