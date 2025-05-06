//
//  ThemeView.swift
//  SnapPlan
//
//  Created by opfic on 2/7/25.
//

import SwiftUI

struct ThemeView: View {
    @EnvironmentObject var firebaseVM: FirebaseViewModel
    @EnvironmentObject var uiVM: UIViewModel
    
    var body: some View {
        VStack {
            List {
                Button(action: {
                    uiVM.setAppTheme(.unspecified)
                    firebaseVM.screenMode = .unspecified
                    Task {
                        try await firebaseVM.updateScreenMode(mode: .unspecified)
                    }
                }) {
                    HStack {
                        Text("자동")
                            .foregroundStyle(Color.primary)
                        Spacer()
                        if firebaseVM.screenMode == .unspecified {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .listRowBackground(Color.timeLine)
                Button(action: {
                    firebaseVM.screenMode = .light
                    uiVM.setAppTheme(.light)
                    Task {
                        try await firebaseVM.updateScreenMode(mode: .light)
                    }
                }) {
                    HStack {
                        Text("라이트 모드")
                            .foregroundStyle(Color.primary)
                        Spacer()
                        if firebaseVM.screenMode == .light {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .listRowBackground(Color.timeLine)
                Button(action: {
                    firebaseVM.screenMode = .dark
                    uiVM.setAppTheme(.dark) // 다크 모드
                    Task {
                        try await firebaseVM.updateScreenMode(mode: .dark)
                    }
                }) {
                    HStack {
                        Text("다크 모드")
                            .foregroundStyle(Color.primary)
                        Spacer()
                        if firebaseVM.screenMode == .dark {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .listRowBackground(Color.timeLine)
            }
            .scrollContentBackground(.hidden)
            .background(Color.calendar)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("테마")
                    .bold()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
#Preview {
    ThemeView()
        .environmentObject(FirebaseViewModel())
}
