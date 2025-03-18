//
//  SettingView.swift
//  SnapPlan
//
//  Created by opfic on 2/7/25.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var supabaseVM: SupabaseViewModel
    @Environment(\.dismiss) var dismiss
    @State private var logoutAlert = false
    @State private var deleteAlert = false
    @State private var days = "1"
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .trailing, spacing: 0) {
                List {
                    Section(header: Text("계정")) {
                        Text(supabaseVM.email)
                    }
                    .listRowBackground(Color.timeLine)
                    Section(header: Text("일정")) {
                        Button(action: {
                            days = "1"
                        }) {
                            HStack {
                                Text("1일")
                                    .foregroundStyle(Color.primary)
                                Spacer()
                                if days == "1" {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        Button(action: {
                            days = "2"
                        }) {
                            HStack {
                                Text("2일")
                                    .foregroundStyle(.gray)
                                Spacer()
                                if days == "2" {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        .disabled(true)
                        .foregroundStyle(.gray)
                        Button(action: {
                            days = "3"
                        }) {
                            HStack {
                                Text("3일")
                                    .foregroundStyle(.gray)
                                Spacer()
                                if days == "3" {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        .disabled(true)
                        .foregroundStyle(.gray)
                    }
                    .listRowBackground(Color.timeLine)
                    
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
                                try supabaseVM.deleteUser()
                            }
                        }) {
                            Text("탈퇴")
                        }
                    } message: {
                        Text("이 작업은 되돌릴 수 없습니다.")
                    }
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
                        await supabaseVM.signOutGoogle()
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
        .environmentObject(SupabaseViewModel())
}
