//
//  PhotoGridPicker.swift
//  SnapPlan
//
//  Created by opfic on 5/3/25.
//

import SwiftUI
import PhotosUI
import Photos
import UIKit

struct PhotoGridPicker: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedImages: [ImageAsset]
    @State private var photos: [PHAsset] = []   //  앨범에서 불러온 사진들
    @State private var selectedAssets: [PHAsset] = []   //  사용자가 선택한 사진들
    @State private var showingSizeAlert = false
    @State private var showingLimitAlert = false
    
    let maxFileSize: Int = 10 * 1024 * 1024 // 10MB
    let maxSelectionCount: Int = 10
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    selectedAssets.removeAll()
                    dismiss()
                }) {
                    Text("취소")
                        .foregroundColor(.blue)
                }
                Spacer()
                
                Text("사진 선택 (\(selectedImages.count + selectedAssets.count)/\(maxSelectionCount))")
                    .font(.headline)
                    .padding()
                
                Spacer()
                Button(action: {
                    selectedImages += updateSelectedImages()
                    selectedAssets.removeAll()
                    dismiss()
                }) {
                    Text("완료")
                        .foregroundColor(.blue)
                }
            }
            .padding([.top, .horizontal])
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 2)], spacing: 2) {
                    ForEach(photos, id: \.localIdentifier) { asset in
                        AssetThumbnailView(
                            asset: asset,
                            isSelected: selectedAssets.contains(where: { $0.localIdentifier == asset.localIdentifier })
                        )
                        .aspectRatio(1, contentMode: .fill)
                        .onTapGesture {
                            handleAssetSelection(asset)
                        }
                    }
                }
                .padding(2)
            }
        }
        .onAppear {
            requestPhotoLibraryAuthorization()
        }
        .alert("이미지 크기 초과", isPresented: $showingSizeAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("선택한 이미지 크기가 너무 큽니다.")
        }
        .alert("최대 선택 개수", isPresented: $showingLimitAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("최대 \(maxSelectionCount)개까지 선택 가능합니다.")
        }
    }
    
    private func handleAssetSelection(_ asset: PHAsset) {
        // 이미 선택된 경우 제거
        if let index = selectedAssets.firstIndex(where: { $0.localIdentifier == asset.localIdentifier }) {
            selectedAssets.remove(at: index)
            return
        }
        
        // 최대 개수 체크
        if self.selectedImages.count + selectedAssets.count >= maxSelectionCount {
            showingLimitAlert = true
            return
        }
        
        // 사이즈 체크
        checkAssetSize(asset) { isAcceptable in
            DispatchQueue.main.async {
                if isAcceptable {
                    selectedAssets.append(asset)
                } else {
                    showingSizeAlert = true
                }
            }
        }
    }
    
    private func checkAssetSize(_ asset: PHAsset, completion: @escaping (Bool) -> Void) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .default,
            options: options
        ) { image, _ in
            guard let image = image else {
                completion(false)
                return
            }
            
            // 80% JPEG 압축으로 데이터 크기 확인
            guard let data = image.jpegData(compressionQuality: 0.8) else {
                completion(false)
                return
            }
            
            completion(data.count <= maxFileSize)
        }
    }
    
    private func updateSelectedImages() -> [ImageAsset] {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = true
        
        var imageAssets: [ImageAsset] = []
        
        for asset in selectedAssets {
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .default,
                options: options
            ) { image, _ in
                if let image = image {
                    imageAssets.append(ImageAsset(id: asset.localIdentifier, image: image))
                }
            }
        }
        
        return imageAssets
    }
    
    private func requestPhotoLibraryAuthorization() {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                DispatchQueue.main.async {
                    loadPhotos()
                }
            }
        }
    }
    
    private func loadPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        photos = (0..<fetchResult.count).compactMap { fetchResult[$0] }
    }
}

extension PhotoGridPicker {
    struct AssetThumbnailView: View {
        let asset: PHAsset
        let isSelected: Bool
        
        var body: some View {
            ZStack {
                Color.black
                GeometryReader { geometry in
                    AssetThumbnail(asset: asset, size: geometry.size)
                }
                
                if isSelected {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .background(Circle().fill(.white))
                                .padding(4)
                        }
                        Spacer()
                    }
                }
            }
        }
    }
    
    struct AssetThumbnail: UIViewRepresentable {
        let asset: PHAsset
        let size: CGSize
        
        func makeUIView(context: Context) -> UIView {
            let view = UIView()
            view.backgroundColor = .systemGray6
            
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: view.topAnchor),
                imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            
            return view
        }
        
        func updateUIView(_ uiView: UIView, context: Context) {
            guard let imageView = uiView.subviews.first as? UIImageView else { return }
            
            let options = PHImageRequestOptions()
            options.deliveryMode = .opportunistic
            
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: CGSize(width: size.width * UIScreen.main.scale, height: size.height * UIScreen.main.scale),
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                imageView.image = image
            }
        }
    }
}
