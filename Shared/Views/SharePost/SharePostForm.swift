//
//  SharePostList.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/07/29.
//

import SwiftUI
import Photos

struct SharePostForm: View {
    struct ImageConfig {
        private var scale: CGFloat = 1
        private var scaleDelta: CGFloat = 0

        private var offset: CGSize = .zero
        private var offsetDelta: CGSize = .zero

        var preview: UIImage?

        var finalOffset: CGSize {
            return CGSize(
                width: offset.width + offsetDelta.width,
                height: offset.height + offsetDelta.height
            )
        }
        var finalScale: CGFloat {
            return scale - scaleDelta
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
    @Environment(\.managedObjectContext)
    private var viewContext

    @FetchRequest(sortDescriptors: [SortDescriptor(\.created, order: .reverse)])
    private var posts: FetchedResults<SharePost>

    @State private var isPickerShow: Bool = false
    @State private var isLoadingPhoto: Bool = false
    @State private var pickedImages: [Data] = []

    @State private var source: ImageConfig = .init()

    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                GeometryReader { proxy in
                    ZStack {
                        if let uiImage = source.preview {
                            ScrollView(.init()) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .tag(uiImage)
                                    .aspectRatio(contentMode: .fill)
                                    .scaleEffect(source.finalScale)
                                    .offset(source.finalOffset)
                                    .gesture(
                                        MagnificationGesture()
                                            .onChanged { source.magnificationOnChange(value: $0) }
                                            .onEnded { source.magnificationOnEnd(value: $0) }
                                    )
                                    .simultaneousGesture(
                                        DragGesture()
                                            .onChanged { source.dragOnChange(gesture: $0) }
                                            .onEnded { source.dragOnEnd(gesture: $0) }
                                    )
                            }
                        }
                    }
                    .frame(
                        width: min(proxy.size.width, proxy.size.height),
                        height: min(proxy.size.width, proxy.size.height)
                    )
                    .background(Color.black.opacity(0.2))
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
                        configuration: .init(photoLibrary: .shared()),
                        isPresented: $isPickerShow,
                        isLoading: $isLoadingPhoto,
                        images: $pickedImages
                    )
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
                if let imageData = images.first {
                    source.preview = UIImage(data: imageData)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct SharePostForm_Previews: PreviewProvider {
    static var previews: some View {
        SharePostForm()
    }
}
