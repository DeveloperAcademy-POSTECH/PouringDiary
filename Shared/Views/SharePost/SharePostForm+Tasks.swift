//
//  SharePostForm+Tasks.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/08/24.
//

import SwiftUI
import CoreData

extension SharePostForm {
    func selectPhoto() {
        pickedImages.removeAll()
        isPickerShow.toggle()
    }

    func toggleLayerHidden(layer: ContentLayer) {
        if let index = layers.firstIndex(where: { $0.id == layer.id }) {
            layers[index].isHidden.toggle()
        }
    }

    func layerSize(proxy: GeometryProxy, scale: CGFloat = 1.0) -> CGFloat {
        let maxSize = 400.0
        return min(min(proxy.size.width, proxy.size.height), maxSize) * scale
    }

    func prepare(diaryId: NSManagedObjectID) {
        diary = Diary.get(by: diaryId, context: viewContext)
        if let diary = diary {
            let notExist = layers
                .filter { $0.content.isRecord }
                .isEmpty
            if notExist {
                var flavorLayer = ContentLayer(offset: .init(width: 0, height: 100))
                flavorLayer.content = .flaverRecords(diary)
                layers.append(contentsOf: [flavorLayer])

                var memoLayer = ContentLayer(offset: .init(width: 0, height: 150))
                memoLayer.content = .memo(diary)
                layers.append(contentsOf: [memoLayer])
            }
        }
        if let bean = diary?.coffeeBean {
            let notExist = layers
                .filter { $0.content.bean == bean }
                .isEmpty
            if notExist {
                var config = ContentLayer(offset: .init(width: 0, height: -50))
                config.content = .coffeeBean(bean)
                layers.append(contentsOf: [config])
            }
        }
        if let recipe = diary?.recipe {
            let notExist = layers
                .filter { $0.content.recipe == recipe }
                .isEmpty
            if notExist {
                var config = ContentLayer(offset: .init(width: 0, height: -150))
                config.content = .recipe(recipe)
                layers.append(contentsOf: [config])
            }
        }
    }

    func generatePreviewImage<T: View>(view: T) -> UIImage? {
        let controller = UIHostingController(rootView: view)
        if let view = controller.view {
            let contentSize = view.intrinsicContentSize
            view.bounds = CGRect(origin: .zero, size: contentSize)
            view.backgroundColor = .clear

            let renderer = UIGraphicsImageRenderer(size: contentSize)
            return renderer.image { _ in
                view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            }
        }
        return nil
    }
}
