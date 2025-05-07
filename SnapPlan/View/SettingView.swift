//
//  SettingView.swift
//  SnapPlan
//
//  Created by opfic on 2/7/25.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var firebaseVM: FirebaseViewModel
    @EnvironmentObject var uiVM: UIViewModel
    @Environment(\.dismiss) var dismiss
    @State private var logoutAlert = false
    @State private var deleteAlert = false
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .trailing, spacing: 0) {
                List {
                    Section(header: Text("계정")) {
                        Text(firebaseVM.email)
                    }
                    .listRowBackground(Color.timeLine)
//                    Section(header: Text("스타일")) {
//                        Button(action: {
//                            firebaseVM.calendarPagingStyle = 1
//                        }) {
//                            HStack {
//                                Text("1일")
//                                    .foregroundStyle(firebaseVM.calendarPagingStyle == 1 ? Color.primary : Color.gray)
//                                Spacer()
//                                if firebaseVM.calendarPagingStyle == 1 {
//                                    Image(systemName: "checkmark")
//                                }
//                            }
//                        }
//                        Button(action: {
//                            firebaseVM.calendarPagingStyle = 2
//                        }) {
//                            HStack {
//                                Text("2일")
//                                    .foregroundStyle(firebaseVM.calendarPagingStyle == 2 ? Color.primary : Color.gray)
//                                Spacer()
//                                if firebaseVM.calendarPagingStyle == 2 {
//                                    Image(systemName: "checkmark")
//                                }
//                            }
//                        }
//                        Button(action: {
//                            firebaseVM.calendarPagingStyle = 3
//                        }) {
//                            HStack {
//                                Text("3일")
//                                    .foregroundStyle(firebaseVM.calendarPagingStyle == 3 ? Color.primary : Color.gray)
//                                Spacer()
//                                if firebaseVM.calendarPagingStyle == 3 {
//                                    Image(systemName: "checkmark")
//                                }
//                            }
//                        }
//                    }
//                    .listRowBackground(Color.timeLine)
                    Section(header: Text("테마")) {
                        NavigationLink(destination: ThemeView()
                            .environmentObject(firebaseVM)
                        ) {
                            Text("테마")
                        }
                    }
                    .listRowBackground(Color.timeLine)
                    Section() {
                        HStack {
                            Text("버전 정보")
                            Spacer()
                            Text(appVersion)
                        }
                        if let ppurl = Bundle.main.object(forInfoDictionaryKey: "PRIVACY_POLICY_URL") as? String {
                            Link(destination: URL(string: ppurl)!) {
                                Text("개인정보 처리방침")
                                    .foregroundColor(Color.blue)
                            }
                        }
                        Button(action: {
                            if let url = URL(string: "itms-beta://") {
                                   UIApplication.shared.open(url, options: [:]) { success in
                                       if !success {
                                           if let appStoreURL = URL(string: "https://apps.apple.com/app/testflight/id899247664") {
                                               UIApplication.shared.open(appStoreURL)
                                           }
                                       }
                                   }
                               }
                        }) {
                            VStack(alignment:. leading) {
                                Text("베타 테스트 참여")
                                Text("신규 기능을 빠르게 만나볼 수 있습니다")
                                    .foregroundStyle(Color.gray)
                                    .font(.caption)
                            }
                        }
                        
                        Button(role: .destructive, action: {
                            logoutAlert = true
                        }) {
                            Text("로그아웃")
                        }
                    }
                    .listRowBackground(Color.timeLine)
                    HStack {
                        Spacer()
                        Button(role: .destructive, action: {
                            deleteAlert = true
                        }) {
                            Text("회원 탈퇴")
                                .font(.headline)
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.timeLine)
                }
                .scrollContentBackground(.hidden)
            }
            .background(Color.calendar)
            .onChange(of: firebaseVM.calendarPagingStyle) { newValue in
                Task {
                    try await firebaseVM.updateCalendarPagingStyle(pagingStyle: newValue)
                }
            }
            .alert("로그아웃", isPresented: $logoutAlert) {
                Button(role: .cancel, action: {
                    logoutAlert = false
                }) {
                    Text("취소")
                }
                Button(role: .destructive, action: {
                    Task {
                        try await firebaseVM.signOutGoogle()
                        uiVM.showSettingView = false
                    }
                }) {
                    Text("확인")
                }
            } message: {
                Text("로그아웃하시겠습니까?")
            }
            .alert("정말 탈퇴하시겠습니까?", isPresented: $deleteAlert) {
                Button(role: .cancel, action: {
                    deleteAlert = false
                }) {
                    Text("취소")
                }
                Button(role: .destructive, action: {
                    Task {
                        uiVM.showSettingView = false
                        try await firebaseVM.deleteUser()
                    }
                }) {
                    Text("탈퇴")
                }
            } message: {
                Text("회원 탈퇴가 진행되면 모든 데이터가 지워지고 복구할 수 없습니다.")
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("설정")
                        .bold()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("닫기")
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SettingView()
        .environmentObject(FirebaseViewModel())
        .environmentObject(UIViewModel())
}
