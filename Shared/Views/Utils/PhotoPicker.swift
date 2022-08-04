//
//  PhotoPicker.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/07/28.
//

import SwiftUI
import PhotosUI

// https://sweetdev.tistory.com/727 의 코드를 활용하여 만들었습니다.
// 참고 해주세요
struct PhotoPicker: UIViewControllerRepresentable {
    let configuration: PHPickerConfiguration
    @Binding var isPresented: Bool
    @Binding var images: [Data]

    func makeUIViewController(context: Context) -> PHPickerViewController {
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Use a Coordinator to act as your PHPickerViewControllerDelegate
    class Coordinator: PHPickerViewControllerDelegate {
        private let parent: PhotoPicker

        init(_ parent: PhotoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            var resultCount = 0
            for result in results {
                resultCount += 1
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] reading, _ in
                    if let image = reading as? UIImage, let data = image.png() {
                        self?.parent.images.append(data)
                    }
                    if resultCount == results.count {
                        self?.parent.isPresented = false
                    }
                }
            }
        }
    }
}

extension UIImage {
    func png(isOpaque: Bool = true) -> Data? { flattened(isOpaque: isOpaque)?.pngData() }
    func flattened(isOpaque: Bool = true) -> UIImage? {
        if imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(size, isOpaque, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
