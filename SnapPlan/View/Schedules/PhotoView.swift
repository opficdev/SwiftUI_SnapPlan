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
    @State private var innerHeight = CGFloat.zero   //  ScrollView 내부 요소의 총 높이
    @State private var outerHeight = CGFloat.zero   //  ScrollView 자체 높이
    @State private var showSizeAlert = false
    @State private var phAssets: [PHAsset] = []
    @State private var removedByTap = false
    @State private var showPicker = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if !scheduleVM.photos.isEmpty {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 4), GridItem(.flexible(), spacing: 4)], spacing: 4) {
                            let photos = scheduleVM.photos.map { $0.image }
                            ForEach(Array(zip(photos.indices, photos)), id: \.0) { idx, image in
                                NavigationLink(destination: PhotoDetailView(image: image)) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: UIScreen.main.bounds.width / 2 - 28)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.white, lineWidth: 2)
                                        )
                                        .highPriorityGesture(
                                            LongPressGesture(minimumDuration: 0.5)
                                                .onEnded { _ in
                                                    scheduleVM.photos.remove(at: idx)
                                                    removedByTap = true
                                                }
                                        )
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
                    Button(action: {
                        showPicker = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationTitle("사진")
            .sheet(isPresented: $showPicker) {
                PhotoGridPicker(selectedImages: $scheduleVM.photos)
            }
        }
    }
}
