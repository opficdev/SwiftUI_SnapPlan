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
                    //  MARK: NavigationLink를 통해 표시되는 ThemeView는 부모 뷰(SettingView)의 환경 객체를 상속받기 때문에 별도로 환경 객체를 주입하지 않아도 오류 발생 X
                    Section(header: Text("테마")) {
                        NavigationLink(destination: ThemeView()) {
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
                            Link(destination:
                                    URL(string: ppurl)!,
                                 label: {
                                Text("개인정보 처리방침")
                                    .foregroundColor(Color.blue)
                            })
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
                    .alert("정말 탈퇴하시겠습니까?", isPresented: $deleteAlert) {
                        Button(role: .cancel, action: {
                            deleteAlert = false
                        }) {
                            Text("취소")
                        }
                        Button(role: .destructive, action: {
                            Task {
                                try await firebaseVM.deleteUser()
                            }
                        }) {
                            Text("탈퇴")
                        }
                    } message: {
                        Text("회원 탈퇴가 진행되면 모든 데이터가 지워지고 복구할 수 없습니다.")
                    }
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
                    }
                }) {
                    Text("확인")
                }
            } message: {
                Text("로그아웃하시겠습니까?")
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
}
