//
//  SharePostList.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/07/29.
//

import SwiftUI
import Photos
import PhotosUI

struct SharePostForm: View {
    @Environment(\.managedObjectContext)
    private var viewContext

    @ObservedObject var diary: Diary

    @State private var isPickerShow: Bool = false
    @State private var isLoadingPhoto: Bool = false
    @State private var pickedImages: [Data] = []

    @State private var layers: [SourceConfig] = [.init()]

    private var photoLibraryConfig: PHPickerConfiguration {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .any(of: [.images, .livePhotos])
        return config
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                GeometryReader { proxy in
                    ZStack {
                            ForEach(layers.indices, id: \.self) { index in
                                if let uiImage = layers[index].preview {
                                    layerImage(uiImage: uiImage, index: index)
                                }
                            }
                    }
                    .frame(
                        width: min(proxy.size.width, proxy.size.height),
                        height: min(proxy.size.width, proxy.size.height)
                    )
                    .background(Color.black.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    Image("Logo")
                        .resizable()
                        .frame(
                            width: min(proxy.size.width, proxy.size.height)*0.1,
                            height: min(proxy.size.width, proxy.size.height)*0.1
                        )
                        .clipShape(RoundedRectangle(cornerSize: .init(width: 8, height: 8)))
                        .opacity(0.6)
                        .padding(4)
                }
                .padding()
                Button {
                    pickedImages.removeAll()
                    isPickerShow.toggle()
                } label: {
                    Text("Image \(pickedImages.count)")
                }
            }
            .sheet(isPresented: $isPickerShow) {
                ZStack {
                    PhotoPicker(
                        configuration: photoLibraryConfig,
                        isPresented: $isPickerShow,
                        isLoading: $isLoadingPhoto,
                        images: $pickedImages
                    )
                    .ignoresSafeArea(.keyboard)
                    if isLoadingPhoto {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.black.opacity(0.5))
                                .frame(width: 80, height: 80)
                            ProgressView()
                                .tint(Color.white)
                        }
                    }
                }
            }
            .onChange(of: pickedImages) { images in
                print(images.count)
                if let imageData = images.first {
                    var config = SourceConfig()
                    config.preview = UIImage(data: imageData)
                    layers = [config]
//                    현재는 사진 한 장을 교체하는 방식이어서 위의 코드로 대체합니다.
//                    layers.append(config)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

extension SharePostForm {
    struct SourceConfig: Identifiable {
        var id: UUID = UUID()
        private var scale: CGFloat = 1
        private var scaleDelta: CGFloat = 0

        private var offset: CGSize = .zero
        private var offsetDelta: CGSize = .zero

        private let minScale = 0.5
        private let maxScale = 2.0

        var preview: UIImage?

        var finalOffset: CGSize {
            return CGSize(
                width: offset.width + offsetDelta.width,
                height: offset.height + offsetDelta.height
            )
        }
        var finalScale: CGFloat {
            return min(max(scale - scaleDelta, minScale), maxScale)
        }

        mutating func magnificationOnChange(value: MagnificationGesture.Value) {
            scaleDelta = 1 - value
        }

        mutating func magnificationOnEnd(value: MagnificationGesture.Value) {
            scale = finalScale
            scaleDelta = 0
        }

        mutating func dragOnChange(gesture: DragGesture.Value) {
            offsetDelta = gesture.translation
        }

        mutating func dragOnEnd(gesture: DragGesture.Value) {
            offset = finalOffset
            offsetDelta = .zero
        }
    }
}

// MARK: Views
extension SharePostForm {
    private func layerImage(uiImage: UIImage, index: Int) -> some View {
        Image(uiImage: uiImage)
            .resizable()
            .tag(uiImage)
            .aspectRatio(contentMode: .fill)
            .scaleEffect(layers[index].finalScale)
            .offset(layers[index].finalOffset)
            .gesture(
                MagnificationGesture()
                    .onChanged { layers[index].magnificationOnChange(value: $0) }
                    .onEnded { layers[index].magnificationOnEnd(value: $0) }
            )
            .simultaneousGesture(
                DragGesture()
                    .onChanged { layers[index].dragOnChange(gesture: $0) }
                    .onEnded { layers[index].dragOnEnd(gesture: $0) }
            )
    }
}

struct SharePostForm_Previews: PreviewProvider {
    static var previews: some View {
        SharePostForm(diary: .init())
    }
}
