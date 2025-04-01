//
//  PhotoView.swift
//  SnapPlan
//
//  Created by opfic on 3/4/25.
//

import SwiftUI
import PhotosUI

struct PhotoView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var scheduleVM: ScheduleViewModel
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var savedPhotos: [UIImage] = []
    @State private var innerHeight = CGFloat.zero   //  ScrollView 내부 요소의 총 높이
    @State private var outerHeight = CGFloat.zero   //  ScrollView 자체 높이
    @State private var errMsg = ""
    private let maxSelectedCount: Int
    init(selectedItems: [ImageAsset], maxSelectedCount: Int = 5) {
        self._selectedPhotos = State(initialValue: selectedItems.map { PhotosPickerItem(itemIdentifier: $0.id) })
        self.maxSelectedCount = maxSelectedCount
    }
    
    var body: some View {
        VStack {
            if !scheduleVM.photos.isEmpty {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 4), GridItem(.flexible(), spacing: 4)], spacing: 4) {
                        let photos = scheduleVM.photos.map { $0.image }
                        ForEach(Array(zip(photos.indices, photos)), id: \.0) { idx, image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width / 2 - 28)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                                .onTapGesture {
                                    selectedPhotos.remove(at: idx)
                                    scheduleVM.photos.remove(at: idx)
                                }
                        }
                    }
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    innerHeight = proxy.size.height
                                }
                                .onChange(of: scheduleVM.photos) { _ in
                                    innerHeight = proxy.size.height
                                }
                        }
                    )
                    .padding(.horizontal, 4)
                }
                .padding(.horizontal)
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
                    maxSelectionCount: maxSelectedCount,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Image(systemName: "plus")
                }
                .disabled(scheduleVM.photos.count >= maxSelectedCount)
                .onChange(of: selectedPhotos) { newValue in
                    Task {
                        scheduleVM.photos = await handleSelectedPhotos(newValue)
                    }
                }
            }
        }
        .navigationTitle("사진")
        .alert("알림", isPresented: .constant(!errMsg.isEmpty)) {
            Button("확인", role: .cancel) {
                errMsg = ""
            }
        } message: {
            Text(errMsg)
        }

    }

    private func handleSelectedPhotos(_ newPhotos: [PhotosPickerItem]) async -> [ImageAsset] {
        var imageAssets: [ImageAsset] = []
        
        for newPhoto in newPhotos {
            do {
                if let data = try await newPhoto.loadTransferable(type: Data.self) {
                    if 20 * 1024 * 1024 <= data.count {
                        errMsg = "20MB 이하의 사진만 추가해주세요!"
                        self.selectedPhotos.removeAll(where: { $0 == newPhoto })
                        continue
                    }
                            
                    if var id = newPhoto.itemIdentifier, let image = UIImage(data: data) {
                        let lastIndex = id.firstIndex(of: "/") ?? id.endIndex
                        id = String(id[..<lastIndex])
                        let asset = ImageAsset(id: id, image: image)
                        imageAssets.append(asset)
                    }
                }
            } catch {
                print("Failed to load photo: \(error)")
            }
        }
        
        return imageAssets
    }

}
