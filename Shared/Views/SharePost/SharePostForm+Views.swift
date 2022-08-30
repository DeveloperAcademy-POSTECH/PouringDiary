//
//  SharePostForm+Views.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/08/12.
//

import SwiftUI

// MARK: Views
extension SharePostForm {

    @ViewBuilder func imagePreview(proxy: GeometryProxy, forData: Bool = false) -> some View {
        ZStack {
            ForEach(layers, content: drawLayer)
            Image("Logo")
                .resizable()
                .frame(
                    width: layerSize(proxy: proxy, scale: 0.1),
                    height: layerSize(proxy: proxy, scale: 0.1)
                )
                .clipShape(RoundedRectangle(cornerSize: .init(width: 8, height: 8)))
                .opacity(0.6)
                .offset(
                    x: layerSize(proxy: proxy, scale: -0.42),
                    y: layerSize(proxy: proxy, scale: -0.42)
                )
        }
        .frame(
            width: layerSize(proxy: proxy),
            height: layerSize(proxy: proxy)
        )
        .clipped()
        .border(forData ? Color.clear : Color.accentColor, width: 1)
    }

    @ViewBuilder var layerPreview: some View {
        GeometryReader { proxy in
            VStack {
                imagePreview(proxy: proxy)
                HStack {
                    ForEach(layers) { layer in
                        layer.filterButton {
                            toggleLayerHidden(layer: layer)
                        }
                    }
                }
                if photoAdded {
                    HStack(alignment: .center) {
                        Button {
                            selectPhoto()
                        } label: {
                            Text("share-form-change-photo")
                                .padding()
                        }
                        Button {
                            let view = imagePreview(proxy: proxy, forData: true).edgesIgnoringSafeArea(.all)
                            if let image = generatePreviewImage(view: view) {
                                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                            }
                        } label: {
                            Text("share-form-save-photo-app")
                                .padding()
                        }
                    }
                }
                Spacer()
            }
        }
    }

    @ViewBuilder
    private func imageLayer(uiImage: UIImage, index: Int) -> some View {
        Image(uiImage: uiImage)
            .resizable()
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

    @ViewBuilder
    private func coffeeBeanLayer(bean: CoffeeBean, index: Int) -> some View {
        Text("☕️  \(bean.name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")")
            .modifier(
                LayerBackground(
                    backgroundColor: .black,
                    textColor: .white,
                    alpha: 0.9
                )
            )
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

    @ViewBuilder
    private func flavorLayer(in diary: Diary, index: Int) -> some View {
        VStack(spacing: 12) {
            FlavorSummary(
                sum: diary.extractionSum,
                count: diary.flavorRecordArray.count,
                label: "flavor-record-picker-extraction",
                minLabel: "flavor-record-picker-extraction-under",
                maxLabel: "flavor-record-picker-extraction-over"
            )
            FlavorSummary(
                sum: diary.strengthSum,
                count: diary.flavorRecordArray.count,
                label: "flavor-record-picker-strength",
                minLabel: "flavor-record-picker-strength-under",
                maxLabel: "flavor-record-picker-strength-over"
            )
        }
        .modifier(
            LayerBackground(
                backgroundColor: .black,
                textColor: .white,
                alpha: 0.9
            )
        )
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

    @ViewBuilder
    private func recipeLayer(recipe: Recipe, index: Int) -> some View {
        Text(recipe.steps?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
            .modifier(
                LayerBackground(
                    backgroundColor: .black,
                    textColor: .white,
                    alpha: 0.9
                )
            )
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

    @ViewBuilder
    private func memoLayer(diary: Diary, index: Int) -> some View {
        Text(diary.memo?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
            .modifier(
                LayerBackground(
                    backgroundColor: .black,
                    textColor: .white,
                    alpha: 0.9
                )
            )
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

    @ViewBuilder
    func drawLayer(layer: ContentLayer) -> some View {
        let index = layers.firstIndex(where: { $0.id == layer.id })!
        let content = layer.content
        if layer.isHidden {
            EmptyView()
        } else {
            switch content {
            case .initial:
                Button {
                    selectPhoto()
                } label: {
                    Text("share-form-layer-image-placeholder")
                }
            case .image(let uiImage):
                imageLayer(uiImage: uiImage, index: index)
            case .coffeeBean(let bean):
                coffeeBeanLayer(bean: bean, index: index)
            case .flaverRecords(let diary):
                flavorLayer(in: diary, index: index)
            case .recipe(let recipe):
                recipeLayer(recipe: recipe, index: index)
            case .memo(let diary):
                memoLayer(diary: diary, index: index)
            }
        }
    }
}
