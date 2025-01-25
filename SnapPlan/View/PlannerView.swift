//
//  TimeView.swift
//  SnapPlan
//
//  Created by opfic on 12/31/24.
//

import SwiftUI
import SwiftUIIntrospect

struct PlannerView: View {
    @StateObject var plannerVM = PlannerViewModel()
    @StateObject var firebaseVM = FirebaseViewModel()
    @EnvironmentObject var loginVM: LoginViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            CalendarView()
                .environmentObject(plannerVM)
                .environmentObject(loginVM)
            TimeLineView()
                .environmentObject(plannerVM)
        }
        .sheet(isPresented: .constant(true)) {
            ScheduleView(schedules: .constant(nil))
                .presentationDetents([.fraction(0.1), .fraction(0.4), .fraction(0.99)])
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled(true)
                .applyBackgroundInteraction()
        }
    }
}

extension View {
    /// iOS 16.4 이상에서는 `.presentationBackgroundInteraction(.enabled)`,
    /// iOS 16.0~16.3에서는 `swiftui-introspect`를 사용하여 UIKit에서 직접 제어
    @ViewBuilder
    func applyBackgroundInteraction() -> some View {
        if #available(iOS 16.4, *) {
            self.presentationBackgroundInteraction(.enabled)
        }
        else {
            self.introspect(.sheet, on: .iOS(.v16)) { controller in //  controller: UIPresentationController
//                if let sheet = controller.sheetPresentationController {
//                    sheet.prefersGrabberVisible = true
//                    sheet.largestUndimmedDetentIdentifier = .medium
//                    controller.isModalInPresentation = true // 배경 터치 방지 (위로 드래그 제한)
//                }
                
                controller.largestUndimmedDetentIdentifier = .medium
                controller.isAccessibilityElement = true
            }
        }
    }
}
#Preview {
    PlannerView()
        .environmentObject(LoginViewModel())
}

