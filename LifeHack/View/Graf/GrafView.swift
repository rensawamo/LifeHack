//
//  GrafView.swift
//  LifeHack
//
//  Created by sawamoren on 2023/09/01.
//

import SwiftUI
import Charts
import PieChart

struct GrafView: View {
    let calendar = Calendar.current
    @State var viewModel = graphViewModel()
    @State var currentDate: Date = Date()
    @State var grafStates:[GraphState] = []
    @State var grafMemoes: [GraphMemo] = []
    @State var selectedSegment:Int = 0
    @State private var currentMonth: Int = 0
    @State private var m_BaseMoney: Int = 250
    @State var grafColorNum = 0
    
    var body: some View {
        VStack(alignment: .center, spacing: 15, content: {
            Text(LocalizedStringKey("graph"))
                .font(.title3.bold())
            
            
            Picker(selection: $selectedSegment, label: Text("Segmented Control")) {
                Text(LocalizedStringKey("1month")).tag(0)
                Text(LocalizedStringKey("3month")).tag(1)
                Text(LocalizedStringKey("6month")).tag(2)
                Text(LocalizedStringKey("12month")).tag(3)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.bottom,15)
            .onChange(of: selectedSegment) { newValue in
                grafStates = viewModel.getGrafState(currentDate: currentDate, selectedSegment: selectedSegment)
                grafMemoes = viewModel.getGrafMemo(currentDate: currentDate, selectedSegment: selectedSegment).0
            }
            HStack {
                Button {
                    withAnimation{
                        let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: currentDate)
                        currentDate = oneMonthAgo!
                        grafStates = viewModel.getGrafState(currentDate: currentDate, selectedSegment: selectedSegment)
                        grafMemoes = viewModel.getGrafMemo(currentDate: currentDate, selectedSegment: selectedSegment).0
                    }
                } label: {
                    Image(systemName: "arrow.backward.circle")
                        .foregroundColor(CharaColor)
                        .font(.body)
                }
                Text(getStrDate(currentDate))
                    .bold()
                    .foregroundColor(CharaColor)
                
                Button {
                    withAnimation{
                        if let oneMonthlate = calendar.date(byAdding: .month, value: 1, to: currentDate) {
                            currentDate = oneMonthlate
                            grafStates = viewModel.getGrafState(currentDate: currentDate, selectedSegment: selectedSegment)
                            grafMemoes = viewModel.getGrafMemo(currentDate: currentDate, selectedSegment: selectedSegment).0
                        }
                    }
                } label: {
                    Image(systemName: "arrow.right.circle")
                        .foregroundColor(CharaColor)
                        .font(.body)
                }
            }
            .frame(maxWidth: .infinity,alignment:.trailing)
            .opacity(selectedSegment == 0 ? 1 : 0)
            
            ScrollView {
                if grafStates != [] {
                    VStack(alignment: .leading, spacing: 0, content: {
                        PieChart(
                            values: grafStates.map { $0.day },
                            colors: [.red, .gray, .blue],
                            backgroundColor: Color.customBackground,
                            configuration: PieChart.Configuration(space: 0.5, hole: 0.6)
                        )
                        .frame(width:  UIScreen.main.bounds.width * 0.8,height: UIScreen.main.bounds.height * 0.28)
                        
                        ForEach(Array(grafStates.enumerated()), id: \.element.id) { index, state in
                            StateAngeView(Define_GrafSysImg[index], state.day, state.percent, Define_GrafSysColor[index])
                                .offset(y:-15)
                        }
                    })
                    .frame(width:  UIScreen.main.bounds.width * 0.8)
                    .overlay(alignment: .topLeading, content: {
                        Text(LocalizedStringKey("condition"))
                            .font(.body.bold())
                    })
                    .padding(.bottom,15)
                }
                
                if grafMemoes != [] {
                    VStack(alignment: .leading, spacing: 0, content: {
                        PieChart(
                            values: grafMemoes.map { $0.percent },
                            colors: Define_GrafColor,
                            backgroundColor: Color.customBackground,
                            configuration: PieChart.Configuration(space: 0.5, hole: 0.6)
                        )
                        .frame(width:  UIScreen.main.bounds.width * 0.8,height: UIScreen.main.bounds.height * 0.28)
                        HStack {
                            Text(LocalizedStringKey("total"))
                                .font(.body.bold())
                            
                            Spacer()
                            HStack {
                                //                                Text(String(realmManager.getGrafMemo(currentDate, selectedSegment).1))
                                Text(LocalizedStringKey("memo"))
                            }
                            .font(.callout)
                        }
                        .padding(.bottom,6.5)
                        ForEach(Array(grafMemoes.enumerated()), id: \.element.name) { index, grafMemo in
                            MemoAngeView(grafMemo.name, grafMemo.percent, index)
                        }
                    })
                    .frame(width:  UIScreen.main.bounds.width * 0.8)
                    .overlay(alignment: .topLeading, content: {
                        Text(LocalizedStringKey("memo"))
                            .font(.title3.bold())
                    })
                    .padding(.bottom,30)
                }
            }
        })
        .padding(.horizontal,10)
        .frame(maxWidth: .infinity,maxHeight:  .infinity,alignment: .top)
        .background(Color.customBackground)
        .onAppear {
            grafStates = viewModel.getGrafState(currentDate: currentDate, selectedSegment: 0)
            grafMemoes = viewModel.getGrafMemo(currentDate: currentDate, selectedSegment: 0).0
        }
    }
    
    @ViewBuilder
    func MemoAngeView(_ title: String, _ percent: Int,_ idxNum: Int) -> some View {
        HStack {
            HStack {
                Text("◼︎")
                    .font(.title)
                    .foregroundColor(Define_GrafColor[idxNum])
                Text(title)
            }
            Spacer()
            HStack {
                Text(String(percent))
                Text(LocalizedStringKey("memo"))
            }
            .font(.callout)
        }
    }
    
    @ViewBuilder
    func StateAngeView(_ systemName:String, _ day:Int, _ percent:Int,_ color:Color) -> some View {
        VStack (spacing:6){
            HStack {
                HStack {
                    Text("◼︎")
                        .font(.title)
                    Image(systemName: systemName)
                }
                .foregroundStyle(color)
                Spacer()
                VStack(alignment: .trailing, spacing: 2, content: {
                    HStack {
                        Text(String(day))
                            .font(.callout)
                        Text(LocalizedStringKey("day"))
                    }
                    Text(String(percent) + " %")
                        .foregroundColor(.gray)
                        .font(.caption2)
                })
            }
        }
    }
    
    func getStrDate(_ current: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: current)
        let year = components.year!
        let month = components.month!
        return String(year) + "/" + String(month)
    }
}


