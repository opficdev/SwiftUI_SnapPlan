//
//  ImageView.swift
//  SnapPlan
//
//  Created by opfic on 3/4/25.
//

import SwiftUI
import PhotosUI

struct ImageView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var supabaseVM: SupabaseViewModel
    @State private var selectedImages: [UIImage]
    @State private var selectedPhotos: [PhotosPickerItem]
    @State private var innerHeight = CGFloat.zero   //  ScrollView 내부 요소의 총 높이
    @State private var outerHeight = CGFloat.zero   //  ScrollView 자체 높이
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
        maxSelectedCount: Int = 6,
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
            if !selectedImages.isEmpty {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0)], spacing: 0) {
                        ForEach(selectedImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width / 2)
                                .clipped()
                                .overlay (
                                    Rectangle()
                                        .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 1)
                                )
                        }
                            
                    }
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    innerHeight = proxy.size.height
                                }
                                .onChange(of: selectedImages) { _ in
                                    innerHeight = proxy.size.height
                            }
                        }
                    )
                }
                .background(
                    GeometryReader { proxy in
                        Color.clear.onAppear {
                            outerHeight = proxy.size.height
                        }
                    }
                )
                .scrollDisabled(innerHeight <= outerHeight)
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
                }
                .disabled(disabled)
                .onChange(of: selectedPhotos) { newValue in
                    handleSelectedPhotos(newValue)
                }
            }
        }
        .navigationTitle("사진")
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
