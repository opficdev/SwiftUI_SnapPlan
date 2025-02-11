//
//  ThemeView.swift
//  SnapPlan
//
//  Created by opfic on 2/7/25.
//

import SwiftUI

struct ThemeView: View {
    @EnvironmentObject var firebaseVM: FirebaseViewModel
    
    var body: some View {
        VStack {
            List {
                Button(action: {
                    setAppTheme(.unspecified)
                    Task {
                        try await firebaseVM.setScreenMode(mode: .unspecified)
                        firebaseVM.screenMode = .unspecified
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
                    setAppTheme(.light)
                    Task {
                        try await firebaseVM.setScreenMode(mode: .light)
                        firebaseVM.screenMode = .light
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
                    setAppTheme(.dark) // 다크 모드
                    Task {
                        try await firebaseVM.setScreenMode(mode: .dark)
                        firebaseVM.screenMode = .dark
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
//        .toolbarBackground(Color.timeLine, for: .navigationBar)
//        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func setAppTheme(_ style: UIUserInterfaceStyle) {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.forEach { window in
                    window.overrideUserInterfaceStyle = style
                }
            }
        }
    }
}
#Preview {
    ThemeView()
        .environmentObject(FirebaseViewModel())
}
