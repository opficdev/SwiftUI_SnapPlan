//
//  ImageView.swift
//  SnapPlan
//
//  Created by opfic on 3/4/25.
//

import SwiftUI
import PhotosUI

struct ImageView: View {
    @State private var selectedPhotos: [PhotosPickerItem]
    @Binding private var selectedImages: [UIImage]
    @Binding private var isPresentedError: Bool
    private let maxSelectedCount: Int
    private var disabled: Bool {
      selectedImages.count >= maxSelectedCount
    }
    private var availableSelectedCount: Int {
      maxSelectedCount - selectedImages.count
    }
    private let matching: PHPickerFilter
    private let photoLibrary: PHPhotoLibrary
    
    public init(
      selectedPhotos: [PhotosPickerItem] = [],
      selectedImages: Binding<[UIImage]>,
      isPresentedError: Binding<Bool> = .constant(false),
      maxSelectedCount: Int = 5,
      matching: PHPickerFilter = .images,
      photoLibrary: PHPhotoLibrary = .shared()
    ) {
      self.selectedPhotos = selectedPhotos
      self._selectedImages = selectedImages
      self._isPresentedError = isPresentedError
      self.maxSelectedCount = maxSelectedCount
      self.matching = matching
      self.photoLibrary = photoLibrary
      
    }
    
    public var body: some View {
      PhotosPicker(
        selection: $selectedPhotos,
        maxSelectionCount: availableSelectedCount,
        matching: matching,
        photoLibrary: photoLibrary
      ) {
      
      }
      .disabled(disabled)
      .onChange(of: selectedPhotos) { newValue in
        handleSelectedPhotos(newValue)
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
                    isPresentedError = true
                }
            }
        }
      
      selectedPhotos.removeAll()
    }

}
