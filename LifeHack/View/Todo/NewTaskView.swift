//
//  NewTaskView.swift
//  LifeHack
//
//  Created by sawamoren on 2023/08/13.
//
import SwiftUI

struct NewTaskView: View {
    var selectedSegment: Int
    @Binding var todoes:[Task]
    @Binding var longTodes:[Task]
    @Environment(\.dismiss) private var dismiss
    @State private var taskTitle: String = ""
    @State var text = ""
    var viewModel: TodoViewModel
    @State private var colorNum: Int = 0
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        hideKeyboard()
                    }
                }
            VStack(alignment: .center, spacing: 15, content: {
                Text(LocalizedStringKey("add"))
                    .font(.title2.bold())
                    .frame(width: UIScreen.main.bounds.width * 0.9)
                    .overlay (alignment:.trailing){
                        Button(action: {
                            dismiss()
                        }, label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .tint(.brown)
                        })
                    }
                
                VStack(alignment: .leading, spacing: 20, content: {
                    Text(LocalizedStringKey("title"))
                        .font(.body)
                    
                    TextField(LocalizedStringKey("title"), text: $taskTitle)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.black.opacity(0.4), lineWidth: 1)
                        )
                    
                    Text(LocalizedStringKey("contant"))
                    TextField(LocalizedStringKey("contant"), text: $text, axis: .vertical)
                        .padding(.horizontal, 15)
                        .frame(height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.black.opacity(0.4), lineWidth: 1)
                        )
                    
                    if selectedSegment == 0 {
                        VStack(alignment: .leading, spacing: 15, content: {
                            Text(LocalizedStringKey("approximate"))
                                .font(.body)
                            HStack(spacing: 0) {
                                ForEach(Array(Define_Colors.enumerated()), id: \.element) { index, color in
                                    VStack {
                                        Circle()
                                            .fill(color)
                                            .frame(width: 20, height: 20)
                                            .scaleEffect(colorNum == index ? 1.5 : 1)
                                            .hSpacing(.center)
                                        
                                        Text(Define_Times[index])
                                            .font(.caption)
                                            .foregroundColor(colorNum == index ? .black : .gray)
                                    }
                                    .onTapGesture {
                                        withAnimation(.easeIn) {
                                            colorNum = index
                                        }
                                    }
                                }
                                .background{
                                    Color.clear
                                        .contentShape(Rectangle())
                                }
                            }
                        })
                    }
                })
                .padding(.bottom,10)
                
                Button(action: {
                    let newTask = Task()
                    newTask.title = taskTitle
                    newTask.context = text
                    newTask.time = colorNum
                    newTask.date = Date()
                    
                    if selectedSegment == 0 {
                        newTask.status = .todo
                    } else {
                        newTask.time = 0
                        newTask.status = .longTodo
                    }
                    if selectedSegment == 0 {
                        viewModel.addTask(status: .todo, task: newTask)
                        todoes = viewModel.getTask(status: .todo)
                    } else {
                        viewModel.addTask(status: .longTodo, task: newTask)
                        longTodes = viewModel.getTask(status: .longTodo)
                    }
                    dismiss()
                }, label: {
                    Text(LocalizedStringKey("add"))
                        .bold()
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 180, height:40)
                })
                .frame(width: 180, height:40)
                .background(Color.brown)
                .cornerRadius(10)
                .offset(y: 10)
                .hSpacing(.center)
                .disabled(taskTitle == "")
                .opacity(taskTitle == "" ? 0.5 : 1)
            })
            .padding(15)
        }
    }
}
