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
    @Binding var isLoading: Bool
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
            parent.isLoading = true
            var resultCount = 0
            for result in results {
                resultCount += 1
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] reading, _ in
                    if let image = reading as? UIImage, let data = image.jpegData(compressionQuality: 0.7) {
                        self?.parent.images.append(data)
                    }
                    if resultCount == results.count {
                        self?.parent.isLoading = false
                        self?.parent.isPresented = false
                    }
                }
            }
        }
    }
}
