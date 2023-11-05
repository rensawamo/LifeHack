//
//  WriteDiaryView.swift
//  LifeHack
//
//  Created by sawamoren on 2023/07/25.
//
import SwiftUI

struct DiaryView: View {
    @State var text = ""
    @State var fixText:String = ""
    @State var imagePicker = false
    @State var imgData : Data = Data(count: 0)
    @State var activeState = ""
    @FocusState private var isKeyboardShowing: Bool
    @Binding var isKeyboad:Bool
    @StateObject private var viewModel = DiaryViewModel(currentDate: Date())
    
    // poper
    @State private var isShowPopover: Bool = false
    @State private var arrowDirection: ArrowDirection = .up
    @State private var background: Color = .white
    
    var body: some View {
        VStack {
            VStack (alignment:.leading){
                HStack {
                    Text(LocalizedStringKey("diary"))
                        .font(.title3)
                        .bold()
                    Image(systemName: "lightbulb.circle")
                        .font(.title3)
                        .foregroundColor(.yellow)
                        .onTapGesture {
                            isShowPopover.toggle()
                        }
                        .iOSPopover(isPresented: $isShowPopover, arrowDirection: arrowDirection.direction) {
                            PoperView(isShowPopover: $isShowPopover,width: 0.8,height: 0.1,isStructShow: true, selectContent: .DaiaryPoper)
                                .background {
                                    Rectangle()
                                        .fill(background)
                                        .shadow(color: Color.gray.opacity(0.3), radius: 10, x: 0, y: 0)
                                        .padding(-20)
                                }
                        }
                }
            }
            .padding(.leading,20)
            .font(.title2)
            
            VStack(alignment: .trailing, spacing: 15, content: {
                Spacer(minLength: 0)
                HStack (spacing:25) {
                    Text(LocalizedStringKey("todayState"))
                        .font(.caption)
                    
                    let stateImges:[String]  = ["sun.max","cloud","cloud.rain"]
                    ForEach(stateImges, id: \.self) { img in
                        let stateColor = StateColor(stateImage: img)
                        Image(systemName: img)
                            .font(.title2)
                            .foregroundColor(activeState == img ? stateColor.tintColor : .gray)
                            .onTapGesture {
                                if let state = viewModel.todayState {
                                    if isCurret(date1: state.date, date2: Date()) {
                                        viewModel.updateState(id: viewModel.todayState!.id, img: img)
                                    }
                                } else {
                                    viewModel.addTodayState(img: img)
                                }
                                activeState = img
                                withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
                                }
                            }
                            .onAppear {
                                viewModel.currentDate = Date()
                                if let state = viewModel.todayState {
                                    activeState = state.systemImage
                                } else {
                                    print("no state")
                                }
                            }
                    }
                }
                .font(.title)
                
                ScrollView (.vertical, showsIndicators: false, content: {
                    ScrollViewReader{ reader in
                        VStack {
                            ForEach(viewModel.diaries, id: \.id) { diary in
                                SentenceView(ViewModel: viewModel, isKeyboad: $isKeyboad, fixText: diary.text, diary: diary)
                                    .onChange(of: isKeyboad) { newValue in
                                        reader.scrollTo((viewModel.diaries.last?.id))
                                    }
                            }
                            TextField(LocalizedStringKey("happend"), text: $text, axis: .vertical)
                                .offset(y:20)
                                .focused($isKeyboardShowing)
                                .contentShape(Rectangle())
                                .opacity(viewModel.diaries.last?.text == nil || viewModel.diaries.last?.text == "" ? 1 : 0)
                                .onTapGesture {
                                    isKeyboad = true
                                    reader.scrollTo((viewModel.diaries.last?.id))
                                    isKeyboardShowing = true
                                }
                                .padding(.bottom,50)
                        }
                    }
                }
                )
            })
            .overlay(alignment: .topTrailing) {
                Button(action: {
                    if isKeyboad {
                        dismissKeyboard()
                        isKeyboad = false
                        if text != "" {
                            viewModel.addDiary(date: Date(), text: text, photo: nil)
                            text = ""
                        }
                    } else {
                        imagePicker.toggle()
                        isKeyboad = false
                    }
                }, label: {
                    if isKeyboad {
                        Text(LocalizedStringKey("imgcomplete"))
                    } else {
                        Image(systemName: "camera")
                            .font(.title2)
                    }
                })
                .offset(y:-25)
            }
            .fullScreenCover(isPresented: self.$imagePicker, onDismiss: {
                if self.imgData.count != 0{
                    if text != "" {
                        viewModel.addDiary(date: Date(), text: text, photo: nil)
                        text = ""
                    }
                    viewModel.addDiary(date: Date(), text: "", photo: self.imgData)
                }
            }) {
                ImagePicker(imagePicker: self.$imagePicker, imgData: self.$imgData)
            }
            .animation(.easeOut)
        }
        .padding(.horizontal,30)
        .background(Color.customBackground)
    }
}

struct DiaryView_Previews: PreviewProvider {
    static var previews: some View {
        DiaryView(isKeyboad: .constant(false))
    }
}

struct ImagePicker : UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        return ImagePicker.Coordinator(parent1: self)
    }
    @Binding var imagePicker : Bool
    @Binding var imgData : Data
    
    func makeUIViewController(context: Context) -> UIImagePickerController{
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }
    
    class Coordinator : NSObject,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
        var parent : ImagePicker
        init(parent1 : ImagePicker) {
            parent = parent1
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.imagePicker.toggle()
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            let image = info[.originalImage] as! UIImage
            parent.imgData = image.jpegData(compressionQuality: 0.5)!
            parent.imagePicker.toggle()
        }
    }
}

