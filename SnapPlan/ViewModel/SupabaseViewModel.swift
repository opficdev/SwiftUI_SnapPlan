//
//  SupabaseViewModel.swift
//  SnapPlan
//
//  Created by opfic on 3/17/25.
//

import SwiftUI
import Combine
import AVKit
import Supabase
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices

@MainActor
final class SupabaseViewModel: ObservableObject {
    //  Supabase 클라이언트
    private let supabase: SupabaseClient
    private var userId: UUID? { supabase.auth.currentUser?.id }
    var email: String { supabase.auth.currentUser?.email ?? "" }
    
    @Published var signedIn: Bool? = nil
    @Published var is12TimeFmt: Bool = true
    @Published var screenMode: UIUserInterfaceStyle = .unspecified
    @Published var schedules: [String:ScheduleData] = [:]

    init() {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
              let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_KEY") as? String else {
            fatalError("No Supabase URL or Key")
        }
        supabase = SupabaseClient(supabaseURL: URL(string: url)!, supabaseKey: key)
        
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error as NSError?, error.code == -4 {    // -4: 로그인 세션이 만료된 경우
                self.signedIn = false
            }
            else if let error = error {
                print("Last Login Restore Error: \(error.localizedDescription)")
                return
            }

            if let _ = user {
                Task {
                    try await self.fetchScreenMode()
                    try await self.fetchTimeFormat()
                    self.signedIn = true
                }
            }
        }
    }
    

}

// MARK: - Google Sign In
extension SupabaseViewModel {
    func signInGoogle() async {
        do {
            try await signInGoogleHelper()
            signedIn = true
        } catch {
            print("Google SignIn Error: \(error)")
        }
    }
    
    func signOutGoogle() async {
        do {
            try await supabase.auth.signOut()
            GIDSignIn.sharedInstance.signOut()
            try await GIDSignIn.sharedInstance.disconnect()
            signedIn = false
        } catch {
            print("Google SignOut Error: \(error)")
        }
    }
    
    private func signInGoogleHelper() async throws {
        guard let topVC = topViewController() else {
            throw URLError(.cannotFindHost)
        }
        
        let gidSignIn = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let idToken = gidSignIn.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        
        let _ = try await supabase.auth.signInWithIdToken(
            credentials: .init(
                provider: .google,
                idToken: idToken
            )
        )
        
        try upsertUser(gidUser: gidSignIn.user)
    }

    
    private func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }

        let controller = controller ?? keyWindow?.rootViewController
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        
        if let tabController = controller as? UITabBarController, let selected = tabController.selectedViewController {
            return topViewController(controller: selected)
        }
        
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        
        return controller
    }
}

// MARK: - 유저 테이블 UD
extension SupabaseViewModel {
    func upsertUser(gidUser: GIDGoogleUser) throws {
        guard let uid = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        Task {
            do {
                let user = try supabase.from("User").upsert(
                    UserData(
                        uid: uid,
                        displayName: gidUser.profile?.name ?? "",
                        email: gidUser.profile?.email ?? "",
                        is12TimeFmt: is12TimeFmt,
                        name: gidUser.profile?.givenName ?? "",
                        screenMode: self.screenMode,
                        signedAt: Date())
                )
                
                let _ = try await user.execute()
            } catch {
                print("Save User Error: \(error)")
            }
        }
    }
    
    func deleteUser() throws {
        guard let uid = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        Task {
            do {
                let user = supabase.from("User").delete().eq("uid", value: uid)
                let _ = try await user.execute()
            } catch {
                print("Delete User Error: \(error)")
            }
        }
    }
    
    func updateScreenMode(mode: UIUserInterfaceStyle) async throws {
        guard let uid = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        do {
            let user = try supabase.from("User").update(["screenMode": mode.rawValue]).eq("uid", value: uid)
            let _ = try await user.execute()
        } catch {
            print("Save ScreenMode Error: \(error)")
        }
    }
    
    func fetchScreenMode() async throws {
        guard let uid = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        do {
            let userdata: [UserData] = try await supabase.from("User")
                .select()
                .eq("uid", value: uid)
                .execute()
                .value

            self.screenMode = userdata.first?.screenMode ?? .unspecified
            
        } catch {
            print("Fetch ScreenMode Error: \(error)")
        }
    }
    
    func updateTimeFormat(is12TimeFmt: Bool) async throws {
        guard let uid = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        do {
            let user = try supabase.from("User").update(["is12TimeFmt": is12TimeFmt]).eq("uid", value: uid)
            let _ = try await user.execute()
        } catch {
            print("Save TimeFormat Error: \(error)")
        }
    }
    
    func fetchTimeFormat() async throws {
        guard let uid = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        do {
            let userdata: [UserData] = try await supabase.from("User")
                .select()
                .eq("uid", value: uid)
                .execute()
                .value
            
            self.is12TimeFmt = userdata.first?.is12TimeFmt ?? true
        } catch {
            print("Fetch TimeFormat Error: \(error)")
        }
        
    }
}

// MARK: - 일정 테이블 CRUD
extension SupabaseViewModel {
    func fetchSchedule(from: Date, to: Date) async throws {
        guard let uid = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let startDay = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: from)!
        let endDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: to)!
        
        do {
            async let dailySchedulesTask: [CodableScheduleData] = supabase.from("Schedule")
                .select()
                .eq("uid", value: uid)
                .lte("startDate", value: endDay)
                .gte("endDate", value: startDay)
                .execute()
                .value
            
            async let recurringSchedulesTask: [CodableScheduleData] = supabase.from("Schedule")
                .select()
                .eq("uid", value: uid)
                .neq("cycleOption", value: "none")
                .execute()
                .value
            
            let (dailySchedules, recurringSchedules) = try await (dailySchedulesTask, recurringSchedulesTask)
            
            // 결과 합치기 및 중복 제거
            let allSchedules = dailySchedules + recurringSchedules
            
            let scheduleDict = Dictionary(
                uniqueKeysWithValues: allSchedules.map { schedule in
                    let scheduleData = ScheduleData(schedule: schedule)
                    return (scheduleData.id.uuidString, scheduleData)
                }
            )
                    
            self.schedules.merge(scheduleDict) { $1 }
            
        } catch {
            throw error
        }
    }

    func upsertSchedule(schedule: ScheduleData) async throws {
        guard let uid = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        do {
            let codableSchedule = CodableScheduleData(schedule: schedule)
            let schedule = try supabase.from("Schedule").upsert(codableSchedule).eq("uid", value: uid)
            let _ = try await schedule.execute()
        } catch {
            print("Upsert Schedule Error: \(error)")
        }
    }
    
    func deleteSchedule(schedule: ScheduleData) async throws {
        guard let uid = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        do {
            let sch = supabase.from("Schedule").delete().eq("uid", value: uid).eq("id", value: schedule.id)
            let _ = try await sch.execute()
            schedules.removeValue(forKey: schedule.id.uuidString)
        } catch {
            print("Delete Schedule Error: \(error)")
        }
    }
    
    func setSchedule(schedule: ScheduleData) {
        schedules[schedule.id.uuidString] = schedule
    }
    
    func removeSchedule(schedule: ScheduleData) {
        schedules.removeValue(forKey: schedule.id.uuidString)
    }
}

// MARK: - 일정 이미지 CRUD
extension SupabaseViewModel {
    func fetchPhotos(schedule: UUID) async throws -> [ImageAsset] {
        guard let user = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        do {
            let folderPath = "\(user.uuidString)/\(schedule.uuidString)"
            let fileList = try await supabase.storage.from("photos").list(path: folderPath)
            
            return try await withThrowingTaskGroup(of: ImageAsset?.self) { group in
                var imageAssets: [ImageAsset] = []
                imageAssets.reserveCapacity(fileList.count)
                
                for file in fileList {
                    group.addTask {
                        let filePath = "\(folderPath)/\(file.name)"
                        do {
                            let signedURL = try await self.supabase.storage.from("photos").createSignedURL(path: filePath, expiresIn: 120)
                            let (data, _) = try await URLSession.shared.data(from: signedURL)
                            if let image = UIImage(data: data) {
                                return ImageAsset(id: file.name, image: image)
                            }
                            return nil
                        } catch {
                            print("Fetch Image Error for \(file.name): \(error.localizedDescription)")
                            return nil
                        }
                    }
                }
                
                for try await asset in group {
                    if let asset = asset {
                        imageAssets.append(asset)
                    }
                }
                
                return imageAssets
            }
        } catch {
            print("Fetch Image Error: \(error.localizedDescription)")
            return []
        }
    }

    func upsertPhotos(id schedule: UUID, photos: [ImageAsset]) async throws {
        guard let user = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        await withTaskGroup(of: Void.self) { group in
            for photo in photos {
                group.addTask {
                    do {
                        guard let data = photo.image.jpegData(compressionQuality: 0.8) else { return }
                        
                        let fileName = "\(photo.id)" + (photo.id.contains(".jpg") ? "" : ".jpg")
                        let filePath = "\(user.uuidString)/\(schedule.uuidString)/\(fileName)"
                        
                        let _ = try await self.supabase.storage.from("photos").upload(
                            filePath,
                            data: data,
                            options: FileOptions(
                                contentType: "image/jpeg",
                                upsert: true
                            )
                        )
                    } catch {
                        print("Upsert Image Error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func deletePhotos(id schedule: UUID) async throws {
        guard let user = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        await withTaskGroup(of: Void.self) { group in
            do {
                let fileList = try await supabase.storage.from("photos").list(path: "\(user.uuidString)/\(schedule.uuidString)")
                
                for file in fileList {
                    let filePath = "\(user.uuidString)/\(schedule.uuidString)/\(file.name)"
                    
                    try await supabase.storage.from("photos").remove(paths: [filePath])
                }
                
            } catch {
                print("Delete Image Error: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - 음성 메모 CRUD
extension SupabaseViewModel {
    func fetchVoiceMemo(schedule: UUID) async throws -> AVAudioFile? {
        guard let user = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        do {
            let filePath = "\(user.uuidString)/\(schedule.uuidString)/voiceMemo.m4a"
            let signedURL = try await supabase.storage.from("voicememos").createSignedURL(path: filePath, expiresIn: 60)
            
            let (data, _) = try await URLSession.shared.data(from: signedURL)
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("voiceMemo.m4a")
            try data.write(to: url)
            
            return try AVAudioFile(forReading: url)
        } catch {
            if error.localizedDescription == "Object not found" {
                
            }
            else {
                print("Fetch VoiceMemo Error: \(error.localizedDescription)")
            }
        }
        
        return nil
    }
    
    func upsertVoiceMemo(id schedule: UUID, memo: AVAudioFile) async throws {
        guard let user = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        do {
            let filePath = "\(user.uuidString)/\(schedule.uuidString)/voiceMemo.m4a"
            let data = try Data(contentsOf: memo.url)
            
            let _ = try await supabase.storage.from("voicememos").upload(
                filePath,
                data: data,
                options: FileOptions(
                    contentType: "audio/m4a",
                    upsert: true
                )
            )
        } catch {
            print("Upsert VoiceMemo Error: \(error.localizedDescription)")
        }
    }
    
    func deleteVoiceMemo(id schedule: UUID) async throws {
        guard let user = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        do {
            let filePath = "\(user.uuidString)/\(schedule.uuidString)/voiceMemo.m4a"
            try await supabase.storage.from("voicememos").remove(paths: [filePath])
        } catch {
            print("Delete VoiceMemo Error: \(error.localizedDescription)")
        }
    }
}
