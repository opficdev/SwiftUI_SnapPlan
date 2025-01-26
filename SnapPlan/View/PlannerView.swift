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
                .applyBackgroundInteraction() // iOS 버전에 따라 다른 동작 적용
        }
    }
}

// iOS 버전에 따라 다른 동작을 적용하는 확장
extension View {
    @ViewBuilder
    func applyBackgroundInteraction() -> some View {
        if #available(iOS 17, *) {
            // iOS 17 이상: SwiftUI의 `.presentationBackgroundInteraction(.enabled)` 사용
            self.presentationBackgroundInteraction(.enabled)
        } else {
            // iOS 16: `introspect`를 사용하여 UIKit로 제어
            self.introspect(.sheet, on: .iOS(.v16)) { controller in
                if let sheet = controller as? UISheetPresentationController {
                    if let maxDetent = sheet.detents.max(by: { $0.identifier.rawValue < $1.identifier.rawValue }) {
                        sheet.largestUndimmedDetentIdentifier = maxDetent.identifier
                    }
                }
            }
        }
    }
}


#Preview {
    PlannerView()
        .environmentObject(LoginViewModel())
}

