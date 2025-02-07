//
//  SettingView.swift
//  SnapPlan
//
//  Created by opfic on 2/7/25.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var firebaseVM: FirebaseViewModel
    @Environment(\.dismiss) var dismiss
    @State private var logoutAlert = false
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .trailing, spacing: 0) {
                Button(action: {
                    dismiss()
                }) {
                    Text("닫기")
                }
                .padding(.trailing)
                List {
                    Section(header: Text("테마")) {
                        NavigationLink(destination: ThemeView()) {
                            Text("테마")
                        }
                    }
                    .listRowBackground(Color.timeLine)
                    Section() {
//                        NavigationLink(destination:) {
//                            Text("피드백 보내기")
//                        }
                        HStack {
                            Text("버전 정보")
                            Spacer()
                            Text(appVersion)
                        }
                        Button(role: .destructive, action: {
                            logoutAlert = true
                        }) {
                            Text("로그아웃")
                        }
                    }
                    .listRowBackground(Color.timeLine)
                }
                .scrollContentBackground(.hidden)
            }
            .background(Color.calendar)
            .alert("로그아웃", isPresented: $logoutAlert) {
                Button(role: .cancel, action: {
                    logoutAlert = false
                }) {
                    Text("취소")
                }
                Button(role: .destructive, action: {
                    Task {
                        await firebaseVM.signOutGoogle()
                    }
                }) {
                    Text("로그아웃")
                }
            } message: {
                Text("로그아웃하시겠습니까?")
            }
        }
    }
}

#Preview {
    SettingView()
        .environmentObject(FirebaseViewModel())
}
