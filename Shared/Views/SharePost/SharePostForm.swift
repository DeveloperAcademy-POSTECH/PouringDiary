//
//  SharePostList.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/07/29.
//

import SwiftUI
import CoreData
import Photos
import PhotosUI

struct SharePostForm: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode

    @State var diary: Diary?

    @State var isPickerShow: Bool = false
    @State var isLoadingPhoto: Bool = false
    @State var pickedImages: [Data] = []
    @State var layers: [ContentLayer] = [.init()]

    private var diaryId: NSManagedObjectID?

    init(diaryId: NSManagedObjectID) {
        self.diaryId = diaryId
    }

    init() { }

    var photoAdded: Bool {
        return !layers
            .filter { $0.content.image != nil }
            .isEmpty
    }

    var photoLibraryConfig: PHPickerConfiguration {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .any(of: [.images, .livePhotos])
        return config
    }

    var body: some View {
        NavigationView {
            layerPreview
                .padding()
                .task {
                    if let id = diaryId {
                        prepare(diaryId: id)
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
                    if let imageData = images.first, let uiImage = UIImage(data: imageData) {
                        var config = ContentLayer()
                        config.content = .image(uiImage)
                        layers.replaceSubrange(0...0, with: [config])
                        // 현재는 사진 한 장을 교체하는 방식이어서 위의 코드로 대체합니다.
                        // layers.append(config)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
                .navigationTitle("share-form-title")
        }
        .navigationViewStyle(.stack)
    }
}

struct SharePostForm_Previews: PreviewProvider {
    static var previews: some View {
        SharePostForm()
            .modifier(AppEnvironment(inMemory: true))
    }
}
