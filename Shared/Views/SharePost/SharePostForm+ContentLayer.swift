//
//  SharePostForm+Content.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/08/13.
//

import SwiftUI
import UIKit

extension SharePostForm {
    struct LayerBackground: ViewModifier {
        var backgroundColor: Color
        var textColor: Color
        var alpha: Double
        var radius: CGFloat = 8
        func body(content: Content) -> some View {
            content
                .foregroundColor(textColor)
                .padding()
                .background(backgroundColor.opacity(alpha))
                .cornerRadius(radius)
        }
    }
    enum LayerContent {
        case initial
        case image(UIImage)
        case coffeeBean(CoffeeBean)
        case flaverRecords(Diary)
        case recipe(Recipe)
        case memo(Diary)

        var image: UIImage? {
            switch self {
            case .image(let image):
                return image
            default:
                return nil
            }
        }

        var note: String? {
            switch self {
            case .memo(let diary):
                return diary.memo
            default:
                return nil
            }
        }

        var bean: CoffeeBean? {
            switch self {
            case .coffeeBean(let bean):
                return bean
            default:
                return nil
            }
        }

        var isRecord: Bool {
            switch self {
            case .flaverRecords:
                return true
            default:
                return false
            }
        }

        var recipe: Recipe? {
            switch self {
            case .recipe(let recipe):
                return recipe
            default:
                return nil
            }
        }

    }
    struct ContentLayer: Identifiable {
        var id: UUID = UUID()
        private var scale: CGFloat
        private var scaleDelta: CGFloat = 0

        private var offset: CGSize
        private var offsetDelta: CGSize = .zero

        private let minScale: CGFloat
        private let maxScale: CGFloat

        var content: LayerContent = .initial
        var isHidden: Bool = true

        private var label: LocalizedStringKey {
            switch content {
            case .initial: return "share-form-layer-label-initial"
            case .image: return "share-form-layer-label-image"
            case .flaverRecords: return "share-form-layer-label-flavor"
            case .recipe: return "share-form-layer-label-recipe"
            case .coffeeBean: return "share-form-layer-label-bean"
            case .memo: return "share-form-layer-label-memo"
            }
        }

        @ViewBuilder
        func filterButton(onTap: @escaping () -> Void) -> some View {
            switch content {
            case .initial, .image:
                EmptyView()
            default:
                Button {
                    onTap()
                } label: {
                    Text(label)
                        .font(.caption2)
                        .foregroundColor(isHidden ? Color.accentColor : Color.white)
                        .padding(8)
                        .background(isHidden ? Color.clear : Color.accentColor)
                        .cornerRadius(8)
                }
            }
        }
        init() {
            self.scale = 1
            self.offset = .zero
            self.minScale = 0.5
            self.maxScale = 2.0
            self.isHidden = false
        }

        init(scale: CGFloat = 1, offset: CGSize = .zero, minScale: CGFloat = 0.5, maxScale: CGFloat = 2.0) {
            self.scale = scale
            self.offset = offset
            self.minScale = minScale
            self.maxScale = maxScale
        }

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
