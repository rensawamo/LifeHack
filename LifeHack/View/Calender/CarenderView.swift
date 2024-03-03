//
//  CarenderView.swift
//  LifeHack
//
//  Created by sawamoren on 2023/08/11.
//
import SwiftUI


struct CarenderView: View {
    @Binding var currentDate: Date
    @State var currentMonth: Int = 0
    @State var showScreenCover = false
    @State var text:String = ""
    @State var isKeyboad:Bool = false
   
    @EnvironmentObject var diaryViewModel: DiaryViewModel
    @EnvironmentObject var todoViewModel:TodoViewModel
    
    init(currentDate: Binding<Date>) {
        self._currentDate = currentDate
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 5, content: {
            Text(LocalizedStringKey("calender"))
                .font(.title3.bold())
            
            ScrollView {
                ScrollViewReader{ reader in
                    let days: [String] = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
                    HStack(spacing: 20){
                        Text(String(extraDate().0) + " / " + String(extraDate().1) )
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Spacer(minLength: 0)
                        Button {
                            withAnimation{
                                currentMonth -= 1
                            }
                        } label: {
                            Image(systemName: "arrow.backward.circle")
                                .foregroundColor(CharaColor)
                                .font(.title2)
                        }
                        Button {
                            withAnimation{
                                currentMonth += 1
                            }
                        } label: {
                            Image(systemName: "arrow.right.circle")
                                .foregroundColor(CharaColor)
                                .font(.title2)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom,10)
                    HStack(spacing: 0){
                        ForEach(days,id: \.self){day in
                            Text(day)
                                .font(.callout)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    let columns = Array(repeating: GridItem(.flexible()), count: 7)
                    
                    //カレンダー
                    LazyVGrid(columns: columns) {
                        ForEach(adjustDate()){ Date in
                            CardView(Date: Date)
                                .onTapGesture {
                                    currentDate = Date.date
                                    diaryViewModel.getDiary()
                                }
                        }
                    }
                    
                    VStack {
                        // 完了タスク
                        DisclosureGroup(
                            content: {
                                VStack (alignment:.leading) {
                                    // 短期
                                    let isShortcurretDate =  todoViewModel.getTask(status: .completed).first(where: { complete in
                                        let isCurretDate = isCurret(date1: complete.date, date2: currentDate)
                                        return isCurretDate
                                    })
                                    // 長期
                                    let isLongCurrentDate = todoViewModel.getTask(status: .longCompleted).first(where: { complete in
                                        let isCurretDate = isCurret(date1: complete.date, date2: currentDate)
                                        return isCurretDate})
                                    
                                    
                                    if ((isShortcurretDate != nil) || (isLongCurrentDate != nil)) {
                                        HStack {
                                            Text("<")
                                            Text(LocalizedStringKey("short"))
                                            Text(">")
                                        }
                                        .padding(.bottom,5)
                                        ForEach(todoViewModel.completeds, id: \.id) { complete in
                                            VStack (alignment: .leading){
                                                Text("• " + complete.title)
                                                    .font(.title3.bold())
                                                Text(complete.context)
                                            }
                                            .padding(.bottom,10)
                                            .frame(maxWidth: .infinity,alignment:.leading)
                                        }
                                        HStack {
                                            Text("<")
                                            Text(LocalizedStringKey("long"))
                                            Text(">")
                                        }
                                        .padding(.bottom,5)
                                        
                                        ForEach(todoViewModel.longCompleteds, id: \.id) { complete in
                                            VStack (alignment: .leading){
                                                Text("• " + complete.title)
                                                    .font(.title3.bold())
                                                Text(complete.context)
                                            }
                                            .padding(.bottom,10)
                                            .frame(maxWidth: .infinity,alignment:.leading)
                                        }
                                    }
                                    else{
                                        Text(LocalizedStringKey("noTask"))
                                    }
                                }
                                .foregroundColor(.black.opacity(0.8))
                            },
                            label: {
                                Text(LocalizedStringKey("complete"))
                                    .font(.title3.bold())
                                    .foregroundColor(.black.opacity(0.8))
                                    .padding(.bottom,10)
                            }
                        )
                        .padding(.vertical,15)
                        DisclosureGroup(
                            content: {
                                VStack (alignment:.leading, spacing: 15) {
                                    if diaryViewModel.diaries.first(where: { diary in
                                        return isCurret(date1: diary.date, date2: currentDate)
                                    }) != nil{
                                        ForEach(diaryViewModel.diaries, id: \.id) { diary in
                                            SentenceView(ViewModel: diaryViewModel, isKeyboad: $isKeyboad, fixText: diary.text, diary: diary)
                                                .onChange(of: isKeyboad) { newValue in
                                                    reader.scrollTo((diaryViewModel.diaries.last?.id))
                                                }
                                        }
                                    }
                                    else{
                                        Text(LocalizedStringKey("noDiary"))
                                    }
                                }
                                .padding(.bottom,20)
                            },
                            label: {
                                Text(LocalizedStringKey("diary"))
                                    .font(.title3.bold())
                                    .foregroundColor(.black.opacity(0.8))
                                    .padding(.bottom,10)
                            }
                        )
                    }
                    .padding(.horizontal,10)
                }
                .onChange(of: currentMonth) { newValue in
                    currentDate = getCurrentMonth()
                }
                .padding(.top,14)
            }
        })
        .background(Color.customBackground)
        .overlay(alignment: .topTrailing, content: {
            Button(action: {
                if isKeyboad {
                    dismissKeyboard()
                    isKeyboad = false
                    if text != "" {
                        diaryViewModel.addDiary(date: Date(), text: text, photo: nil)
                        text = ""
                    }
                } else {
                    showScreenCover.toggle()
                }
            }){
                if isKeyboad {
                    Text(LocalizedStringKey("imgcomplete"))
                } else {
                    Image(systemName: "person.circle")
                        .font(.title)
                        .foregroundColor(.brown)
                        .offset(x:-14)
                }
            }
        })
        .fullScreenCover(isPresented: $showScreenCover) {
            MypageView()
        }
    }
    
    @ViewBuilder
    func CardView(Date: DateValue)-> some View{
        VStack{
            if Date.day != -1 {
                if isCurret(date1: .init(), date2: Date.date)
                {
                    Text("\(Date.day)")
                        .font(.title3.bold())
                        .foregroundColor(isCurret(date1: Date.date, date2: currentDate) ? .blue : CharaColor)
                        .frame(maxWidth: .infinity)
                        .background {
                            Circle()
                                .fill(.pink.opacity(0.4))
                                .frame(width: 35,height: 35)
                        }
                    Spacer()
                    if let state = diaryViewModel.heartStates.first(where: { state in
                        return isCurret(date1: state.date, date2: Date.date)
                    }){
                        let stateColor = StateColor(stateImage: state.systemImage)
                        Image(systemName: state.systemImage)
                            .foregroundColor(stateColor.tintColor)
                    } else {
                        Text("")
                    }
                }
                else{
                    Text("\(Date.day)")
                        .font(.title3.bold())
                        .foregroundColor(isCurret(date1: Date.date, date2: currentDate) ? .blue : CharaColor)
                        .frame(maxWidth: .infinity)
                    Spacer()
                    if let state = diaryViewModel.heartStates.first(where: { state in
                        return isCurret(date1: state.date, date2: Date.date)
                    }){
                        let stateColor = StateColor(stateImage: state.systemImage)
                        Image(systemName: state.systemImage)
                            .foregroundColor(stateColor.tintColor)
                    } else {
                        Text("")
                    }
                }
            }
        }
        .padding(.vertical,9)
        .frame(height: 60,alignment: .top)
    }
    func isToday(_ date: DateValue)->Bool{
        if date.day ==  Now().2 && date.month == Now().1 && date.year == Now().0 {
            return true
        }
        return false
    }
    //現在の日付
    func Now()-> (Int,Int,Int) {
        let calendar = Calendar.current
        let nowDate: Date = Date()
        let currentDate = Date() // 現在の日付を取得
        let month = calendar.component(.month, from: nowDate)
        let year = calendar.component(.year, from: nowDate)
        let day = calendar.component(.day, from: nowDate)
        return (year,month,day)
    }
    // 更新日付
    func extraDate()-> (Int,Int){
        let calendar = Calendar.current
        let month = calendar.component(.month, from: currentDate)
        let year = calendar.component(.year, from: currentDate)
        
        return (year,month)
    }
    func getCurrentMonth()->Date{
        let calendar = Calendar.current
        guard let currentMonth = calendar.date(byAdding: .month, value: self.currentMonth, to: Date()) else{
            return Date()
        }
        return currentMonth
    }
    func adjustDate()->[DateValue] {
        let calendar = Calendar.current
        let currentMonth = getCurrentMonth()
        let year = calendar.component(.year, from: currentDate)
        let month = calendar.component(.month, from: currentDate)
        var days = currentMonth.getAllDates().compactMap { date -> DateValue in
            let day = calendar.component(.day, from: date)
            return DateValue(day: day,year:year,month:month, date: date)
        }
        let firstWeekday = calendar.component(.weekday, from: days.first!.date)
        for _ in 0..<firstWeekday - 1{
            days.insert(DateValue(day: -1,year:year,month:month, date: Date()), at: 0)
        }
        return days
    }
}

extension Date{
    func getAllDates()->[Date]{
        let calendar = Calendar.current
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year,.month], from: self))!
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        return range.compactMap { day -> Date in
            return calendar.date(byAdding: .day, value: day - 1, to: startDate)!
        }
    }
}

struct Previews_CarenderView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
