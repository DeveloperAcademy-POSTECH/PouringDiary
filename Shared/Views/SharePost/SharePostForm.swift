//
//  SharePostList.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/07/29.
//

import SwiftUI
import Photos

struct SharePostForm: View {
    @Environment(\.managedObjectContext)
    private var viewContext

    @FetchRequest(sortDescriptors: [SortDescriptor(\.created, order: .reverse)])
    private var posts: FetchedResults<SharePost>

    @State private var isPickerShow: Bool = false
    @State private var isLoadingPhoto: Bool = false
    @State private var pickedImages: [Data] = []
    @State private var sourceScale: CGFloat = 1
    @State private var sourceOffset: CGSize = .zero

    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                GeometryReader { proxy in
                    ZStack {
                        if let sourceData = pickedImages.first, let uiImage = UIImage(data: sourceData) {
                            ScrollView(.init()) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .tag(uiImage)
                                    .aspectRatio(contentMode: .fill)
                                    .scaleEffect(CGFloat(sourceScale))
                                    .offset(sourceOffset)
                                    .gesture(MagnificationGesture().onChanged({ value in
                                        withAnimation(.spring()) {
                                            sourceScale = value
                                        }
                                    }))
                                    .simultaneousGesture(DragGesture()
                                        .onChanged({ gesture in
                                            withAnimation(.spring()) {
                                                sourceOffset = gesture.translation
                                            }
                                        })
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
        }
        .navigationViewStyle(.stack)
    }
}

struct SharePostForm_Previews: PreviewProvider {
    static var previews: some View {
        SharePostForm()
    }
}
