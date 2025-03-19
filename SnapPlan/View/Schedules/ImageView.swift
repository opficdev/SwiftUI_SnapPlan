//
//  ImageView.swift
//  SnapPlan
//
//  Created by opfic on 3/4/25.
//

import SwiftUI
import PhotosUI

struct ImageView: View {
    @State private var selectedImages: [UIImage]
    @State private var selectedPhotos: [PhotosPickerItem]
    @State private var innerHeight = CGFloat.zero   //  ScrollView 내부 요소의 총 높이
    @State private var outerHeight = CGFloat.zero   //  ScrollView의 높이
    private let maxSelectedCount: Int
    private var disabled: Bool {
        selectedImages.count >= maxSelectedCount
    }
    private var availableSelectedCount: Int {
        maxSelectedCount - selectedImages.count
    }
    private let matching: PHPickerFilter
    private let photoLibrary: PHPhotoLibrary
    
    init(
        selectedPhotos: [PhotosPickerItem] = [],
        selectedImages: [UIImage] = [],
        maxSelectedCount: Int = 5,
        matching: PHPickerFilter = .images,
        photoLibrary: PHPhotoLibrary = .shared()
    ) {
        self._selectedPhotos = State(initialValue: selectedPhotos)
        self._selectedImages = State(initialValue: selectedImages)
        self.maxSelectedCount = maxSelectedCount
        self.matching = matching
        self.photoLibrary = photoLibrary
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
//                PhotosPicker(
//                    selection: $selectedPhotos,
//                    maxSelectionCount: availableSelectedCount,
//                    matching: matching,
//                    photoLibrary: photoLibrary
//                ) {
//                    Image(systemName: "plus.circle.fill")
//                        .symbolRenderingMode(.palette)
//                        .foregroundStyle(Color.white, Color.gray.opacity(0.2))
//                        .font(.system(size: 30))
//                }
//                .disabled(disabled)
//                .onChange(of: selectedPhotos) { newValue in
//                    handleSelectedPhotos(newValue)
//                }
            }
            if selectedImages.count > 0 {
                ScrollView {
                    LazyVStack {
                        ForEach(selectedImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                    }
                }
                .background(
                    GeometryReader { proxy in
                        Color.clear.onAppear {
                            outerHeight = proxy.size.height
                        }
                    }
                )
            }
            else {
                VStack {
                    Text("저장된 사진이 없습니다.")
                    Text("우측 상단 + 버튼을 눌러 사진을 추가해보세요.")
                }
                    .foregroundStyle(Color.gray)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                PhotosPicker(
                    selection: $selectedPhotos,
                    maxSelectionCount: availableSelectedCount,
                    matching: matching,
                    photoLibrary: photoLibrary
                ) {
                    Image(systemName: "plus")
                        .foregroundStyle(Color.primary)
                }
                .disabled(disabled)
                .onChange(of: selectedPhotos) { newValue in
                    handleSelectedPhotos(newValue)
                }
            }
        }
    }
    
    private func handleSelectedPhotos(_ newPhotos: [PhotosPickerItem]) {
        for newPhoto in newPhotos {
            newPhoto.loadTransferable(type: Data.self) { result in
                switch result {
                case .success(let data):
                    if let data = data, let newImage = UIImage(data: data) {
                        if !selectedImages.contains(where: { $0.pngData() == newImage.pngData() }) {
                            DispatchQueue.main.async {
                                selectedImages.append(newImage)
                            }
                        }
                    }
                case .failure:
                    break
                }
            }
        }
      
      selectedPhotos.removeAll()
    }

}

#Preview {
    ImageView()
}
