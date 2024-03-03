//
//  remon.swift
//  LifeHack
//
//  Created by sawamoren on 2023/08/22.
//

import SwiftUI

struct ExpandPhotoView: View {
    var photo:Data
    @State var magnifying = 1.0
    @State var currentScale = 1.0
    
    @State var position: CGPoint = .zero
    @State var dragging: CGSize = .zero
    @State var swipeDragging: CGSize = .zero
    
    @State private var isOnlyImage:Bool = false
    private let minScale = 1.0
    private let maxScale = 7.0
    
    @Environment(\.dismiss) var dismiss
    var body: some View {
        GeometryReader {
            let size = $0.size
            let width = size.width
            let height = size.height
            ZStack {
                Color.black.ignoresSafeArea()
                Image(uiImage: UIImage(data: photo)!)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: size.width * 1, maxHeight:  size.height * 1)
                    .position(
                        x: (position.x + dragging.width),
                        y: (position.y + dragging.height)
                    )
                    .scaleEffect(currentScale * magnifying)
                    .overlay (alignment:.topTrailing){
                        Button(action: {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                                dismiss()
                            }
                        }, label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(.white)
                                .font(.title2)
                                .padding(15)
                                .background(.black, in: Circle())
                                .offset(x: -5)
                            
                        })
                    }
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                magnifying = value
                            }
                            .onEnded { _ in
                                let scale = currentScale * magnifying
                                if scale > maxScale {
                                    currentScale = maxScale
                                } else if scale < minScale {
                                    currentScale = minScale
                                } else {
                                    currentScale = scale
                                }
                                magnifying = 1.0
                            }
                            .simultaneously(with: DragGesture()
                                .onChanged { value in
                                    if currentScale * magnifying == 1.0 {
                                        dragging = value.translation
                                        dragging.width = 0
                                        dragging.height = 0
                                        swipeDragging = value.translation
                                        swipeDragging.width /= currentScale
                                        swipeDragging.height /= currentScale
                                    } else {
                                        dragging = value.translation
                                        dragging.width /= currentScale
                                        dragging.height /= currentScale
                                    }
                                }
                                .onEnded { value in
                                    if currentScale * magnifying != 1.0 {
                                        let positionx = position.x + dragging.width
                                        let positiony = position.y + dragging.height
                                        let centerX = size.width / 2
                                        if abs(positionx - centerX ) > centerX  {
                                            position.x = centerX
                                        } else {
                                            position.x = positionx
                                        }
                                        let centerY = size.height / 2
                                        if abs(positiony - centerY ) > centerY  {
                                            position.y = centerY
                                        } else {
                                            position.y = positiony
                                        }
                                        dragging = .zero
                                    }
                                }
                            )
                    )
                    .onAppear {
                        position.x = size.width / 2
                        position.y = size.height / 2
                    }
                    .gesture(
                        TapGesture(count: 2)
                            .onEnded { _ in
                                withAnimation {
                                    currentScale = 1.0
                                    position.x = size.width / 2
                                    position.y = size.height / 2
                                }
                            }
                    )
                    .onTapGesture(count: 1) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isOnlyImage.toggle()
                        }
                    }
            }
        }
    }
}

//
//struct remon_Previews: PreviewProvider {
//    static var previews: some View {
//        ExpandPhotoView(photo: Data())
//    }
//}
