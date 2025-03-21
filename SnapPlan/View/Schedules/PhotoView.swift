//
//  PhotoView.swift
//  SnapPlan
//
//  Created by opfic on 3/4/25.
//

import SwiftUI
import PhotosUI

struct ImageView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var scheduleVM: ScheduleViewModel
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var savedPhotos: [UIImage] = []
    @State private var innerHeight = CGFloat.zero   //  ScrollView 내부 요소의 총 높이
    @State private var outerHeight = CGFloat.zero   //  ScrollView 자체 높이
    private let maxSelectedCount: Int
    private var disabled: Bool {
        scheduleVM.photoFiles.count >= maxSelectedCount
    }
    private var availableSelectedCount: Int {
        maxSelectedCount - scheduleVM.photoFiles.count
    }
    init(maxSelectedCount: Int = 6) {
        self.maxSelectedCount = maxSelectedCount
    }
    
    var body: some View {
        VStack {
            if !scheduleVM.photoFiles.isEmpty {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0)], spacing: 0) {
                        ForEach(scheduleVM.photoFiles, id: \.self) { image in
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
                                .onChange(of: scheduleVM.photoFiles) { _ in
                                    innerHeight = proxy.size.height
                            }
                        }
                    )
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
                    maxSelectionCount: availableSelectedCount,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Image(systemName: "plus")
                }
                .disabled(disabled)
                .onChange(of: selectedPhotos) { newValue in
                    Task {
                        scheduleVM.didChangedPhotosFromVM = true
                        scheduleVM.photos = await handleSelectedPhotos(newValue)
                    }
                }
            }
        }
        .navigationTitle("사진")

    }

    private func handleSelectedPhotos(_ newPhotos: [PhotosPickerItem]) async -> [UIImage] {
        var photos: [UIImage] = []
        
        for newPhoto in newPhotos {
            do {
                if let data = try await newPhoto.loadTransferable(type: Data.self) {
                    if let newImage = UIImage(data: data) {
                        photos.append(newImage)
                    }
                }
            } catch {
                print("Failed to load photo: \(error)")
            }
        }
        
        return photos
    }

}

#Preview {
    ImageView()
}
