//
//  SharePostList.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/07/29.
//

import SwiftUI
import Photos

struct SharePostList: View {
    @Environment(\.managedObjectContext)
    private var viewContext

    @FetchRequest(sortDescriptors: [SortDescriptor(\.created, order: .reverse)])
    private var posts: FetchedResults<SharePost>

    @State private var isPickerShow: Bool = false
    @State private var pickedImages: [Data] = []

    var body: some View {
        NavigationView {
            VStack {
                if let sourceData = pickedImages.first, let uiImage = UIImage(data: sourceData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                Button {
                    pickedImages.removeAll()
                    isPickerShow.toggle()
                } label: {
                    Text("Image \(pickedImages.count)")
                }
            }
            .sheet(isPresented: $isPickerShow) {
                PhotoPicker(
                    configuration: .init(photoLibrary: .shared()),
                    isPresented: $isPickerShow,
                    images: $pickedImages
                )
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct SharePostList_Previews: PreviewProvider {
    static var previews: some View {
        SharePostList()
    }
}
