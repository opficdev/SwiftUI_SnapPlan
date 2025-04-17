//
//  FirebaseViewModel.swift
//  SnapPlan
//
//  Created by opfic on 12/30/24.
//
//  Supabase 사용 예정으로 더이상 사용하지 않을 예정

import SwiftUI
import AVFoundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import FirebaseFunctions
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices
import CryptoKit

@MainActor
final class FirebaseViewModel: ObservableObject {
    private var userId: String? { Auth.auth().currentUser?.uid }
    private var appleSignInDelegate: AppleSignInDelegate?
    private let db = Firestore.firestore()
    private let functions = Functions.functions(region: "asia-northeast3")
    private let storage = Storage.storage()
    var email: String { Auth.auth().currentUser?.email ?? "" }  //  뷰에서 변경하지 않아서 published로 하지 않음
    @Published var signedIn: Bool? = nil
    @Published var is12TimeFmt: Bool = true
    @Published var screenMode: UIUserInterfaceStyle = .unspecified
    @Published var calendarPagingStyle: Int = 1
    @Published var schedules: [String:ScheduleData] = [:]
    
    init() {
        Task {
            if let _ = try? await GIDSignIn.sharedInstance.restorePreviousSignIn() {
                if let _ = Auth.auth().currentUser {
                    try await self.fetch12TimeFmt()
                    try await self.fetchScreenMode()
                    try await self.fetchCalendarPagingStyle()
                    self.signedIn = true
                }
                else {
                    try await signOutGoogle()
                }
            }
            else if let currentUser = Auth.auth().currentUser, currentUser.providerData.contains(where: { $0.providerID == "apple.com" }) {
                try await self.fetch12TimeFmt()
                try await self.fetchScreenMode()
                try await self.fetchCalendarPagingStyle()
                self.signedIn = true
            }
            else {
                try await self.signOutApple()
            }
        }
    }
}

// MARK: - Google Sign In/Out
extension FirebaseViewModel {
    func signInGoogle() async throws {
        do {
            try await signInGoogleHelper()
            signedIn = true
        } catch {
            print("Google SignIn Error: \(error)")
            throw error
        }
    }
    
    func signOutGoogle() async throws {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            try await GIDSignIn.sharedInstance.disconnect()
            signedIn = false
        } catch {
            print("Google SignOut Error: \(error)")
            throw error
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
        
        let accessToken = gidSignIn.user.accessToken.tokenString
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        let result = try await Auth.auth().signIn(with: credential)

        saveUser(user: result.user)
    }
    
    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
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

// MARK: - Apple Sign In/Out
extension FirebaseViewModel {
    func signInApple() async throws {
        do {
            try await signInAppleHelper()
            signedIn = true
        } catch {
            print("Apple SignIn Error: \(error)")
            throw error
        }
    }
    
    func signOutApple() async throws {
        do {
            try Auth.auth().signOut()
            signedIn = false
        } catch {
            print("Apple SignOut Error: \(error)")
            throw error
        }
    }
    
    private func signInAppleHelper() async throws {
        let nonce = UUID().uuidString
        let hashedNonce = SHA256.hash(data: Data(nonce.utf8)).map { String(format: "%02x", $0) }.joined()
        
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.email]
        request.nonce = hashedNonce
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        let authorization = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<ASAuthorization, Error>) in
            self.appleSignInDelegate = AppleSignInDelegate(continuation: continuation)
            controller.delegate = self.appleSignInDelegate
            controller.presentationContextProvider = self.appleSignInDelegate
            controller.performRequests()
        }
        
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let appleIDToken = credential.identityToken,
              let authorizationCode = credential.authorizationCode,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw URLError(.badServerResponse)
        }
        
        let firebaseCredential = OAuthProvider.credential(
            providerID: AuthProviderID.apple,
            idToken: idTokenString,
            rawNonce: nonce
        )
        
        let result = try await Auth.auth().signIn(with: firebaseCredential)
        
        saveUser(user: result.user)
        try await getAppleRefreshToken(authorizationCode: authorizationCode)
    }
    
    private func getAppleRefreshToken(authorizationCode: Data) async throws {
        guard let userId = userId, let authorizationCode = String(data: authorizationCode, encoding: .utf8) else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let getFuction = functions.httpsCallable("getAppleRefreshToken")
        
        let params: [String: Any] = [
            "authorizationCode": authorizationCode,
            "userId": userId
        ]
            
        do {
            let _ = try await getFuction.call(params)
        } catch {
            print("Error get Apple Refresh Token: \(error.localizedDescription)")
            throw error
        }
    }
    
    // 애플 액세스 토큰 재발급 메서드
    func refreshAppleAccessToken() async throws -> String {
        guard let _ = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let refreshFunction = functions.httpsCallable("refreshAppleAccessToken")
        
        do {
            let result = try await refreshFunction.call()
            
            if let data = result.data as? [String: Any], let accessToken = data["token"] as? String {
                return accessToken
            }
            return ""
        } catch {
            print("Error refresh Apple Token: \(error.localizedDescription)")
            throw error
        }
    }
    
    // 애플 액세스 토큰 취소 메서드
    func revokeAppleAccessToken(token: String) async throws -> Bool {
        guard let _ = userId else {
            throw URLError(.userAuthenticationRequired)
        }
       
        let revokeFunction = functions.httpsCallable("revokeAppleAccessToken")
        
        do {
            let _ = try await revokeFunction.call(["token": token])
            return true
        } catch {
            print("Error revoke Apple Token: \(error.localizedDescription)")
            throw error
        }
    }
}

// MARK: - User 데이터
extension FirebaseViewModel {
    private func saveUser(user: User) {
        let userRef = db.collection(user.uid).document("info")
        let userInfo: [String: Any] = [
            "uid": user.uid,    //  uid
            "email": user.email ?? "",  //  이메일
            "is12TimeFmt": true,    //  12시간제 포맷 여부
            "screenMode": "unspecified",    //  화면 모드
            "signedAt": FieldValue.serverTimestamp(), //  가입 시간
            "calendarPagingStyle": 1    //  캘린더 페이지 스타일
        ]
        
        userRef.setData(userInfo, merge: true) { error in
            if let error = error {
                print("Error saving user: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteUser() async throws {
        guard let user = Auth.auth().currentUser, let userId = userId else { return }
        self.signedIn = false
        
        do {
            try await deleteStorageDirectory(path: "photos/\(userId)")
            try await deleteStorageDirectory(path: "voiceMemos/\(userId)")
        } catch {
            print("Error deleting Storage: \(error.localizedDescription)")
        }
        
        let batch = db.batch()
        // 1. info 문서만 삭제
        let infoDocRef = db.collection(userId).document("info")
        batch.deleteDocument(infoDocRef)
        
        // 2. schedules/data 컬렉션의 문서들 삭제
        let scheduleDocs = try await db.collection(userId).document("schedules").collection("data").getDocuments()
        for doc in scheduleDocs.documents {
            batch.deleteDocument(doc.reference)
        }
        
        // 공급자 확인
        let hasAppleProvider = user.providerData.contains { $0.providerID == "apple.com" }
        let hasGoogleProvider = user.providerData.contains { $0.providerID == "google.com" }

        // 두 공급자가 모두 있는 경우
        if hasAppleProvider && hasGoogleProvider {
            // Apple 토큰 처리 후 마지막 로그아웃 전에 batch.commit()
            let appleToken = try await refreshAppleAccessToken()
            if try await revokeAppleAccessToken(token: appleToken) {
                try await batch.commit()
                try await signOutApple()
            }
            
            // Google은 나중에 로그아웃
            try await signOutGoogle()
        }
        // Apple 공급자만 있는 경우
        else if hasAppleProvider {
            let appleToken = try await refreshAppleAccessToken()
            if try await revokeAppleAccessToken(token: appleToken) {
                try await batch.commit()
                try await signOutApple()
            }
        }
        // Google 공급자만 있는 경우
        else if hasGoogleProvider {
            try await batch.commit()
            try await signOutGoogle()
        }
       
        try await user.delete()
    }
    
    func fetch12TimeFmt() async throws {
        guard let userId = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let docRef = db.collection(userId).document("info")
        
        do {
            let document = try await docRef.getDocument()
            let timeFmt = document.data()?["is12TimeFmt"] as? Bool
            self.is12TimeFmt = timeFmt ?? true
        } catch {
            throw error
        }
    }
    
    func updateTimeFormat(is12TimeFmt: Bool) async throws {
        guard let userId = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let docRef = db.collection(userId).document("info")
        
        do {
            try await docRef.setData(["is12TimeFmt": is12TimeFmt], merge: true)
        } catch {
            throw error
        }
    }
    
    func fetchScreenMode() async throws {
        guard let userId = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let docRef = db.collection(userId).document("info")
        
        do {
            let document = try await docRef.getDocument()
            let screenMode = document.data()?["screenMode"] as? String ?? "unspecified"
            self.screenMode = UIUserInterfaceStyle(stringValue: screenMode)
        } catch {
            throw error
        }
    }
    
    func updateScreenMode(mode: UIUserInterfaceStyle) async throws {
        guard let userId = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let docRef = db.collection(userId).document("info")
        
        do {
            try await docRef.setData(["screenMode": mode.rawValue], merge: true)
        } catch {
            throw error
        }
    }
    
    func fetchCalendarPagingStyle() async throws {
        guard let userId = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let docRef = db.collection(userId).document("info")
        
        do {
            let document = try await docRef.getDocument()
            let pagingStyle = document.data()?["calendarPagingStyle"] as? Int
            self.calendarPagingStyle = pagingStyle ?? 1
        } catch {
            throw error
        }
    }

    func updateCalendarPagingStyle(pagingStyle: Int) async throws {
        guard let userId = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let docRef = db.collection(userId).document("info")
        
        do {
            try await docRef.setData(["calendarPagingStyle": pagingStyle], merge: true)
        } catch {
            throw error
        }
    }
}

// MARK: - 스케줄
extension FirebaseViewModel {
    func fetchSchedule(from: Date, to: Date) async throws {
        guard let userId = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let startDay = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: from)!
        let endDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: to)!
        
        let dbRef = db.collection(userId).document("schedules").collection("data")
        
        do {
            async let snapshot1 = dbRef
                .whereField("startDate", isGreaterThanOrEqualTo: startDay)
                .whereField("startDate", isLessThanOrEqualTo: endDay)
                .getDocuments()
            
            async let snapshot2 = dbRef
                .whereField("endDate", isGreaterThanOrEqualTo: startDay)
                .whereField("endDate", isLessThanOrEqualTo: endDay)
                .getDocuments()
            
            async let snapshot3 = dbRef
                .whereField("cycleOption", isNotEqualTo: "none")
                .getDocuments()
            
            let (result1, result2, result3) = try await (snapshot1, snapshot2, snapshot3)
            
            var dict: [String:ScheduleData] = [:]
 
            let results = [result1, result2, result3]
            
            for result in results {
                for document in result.documents {
                    var data = document.data()
                    data["id"] = document.documentID; data["isChanging"] = false
                    if let schedule = try? Firestore.Decoder().decode(CodableScheduleData.self, from: data) {
                        dict[schedule.id.uuidString] = ScheduleData(schedule: schedule)
                    }
                }
            }
            self.schedules = dict
        } catch {
            print("Fetch Schedule Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func upsertSchedule(schedule: ScheduleData) async throws {
        guard let userId = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let docRef = db.collection(userId).document("schedules").collection("data").document(schedule.id.uuidString)
        
        do {
            let newEntry: [String: Any] = [
                "title": schedule.title,
                "startDate": schedule.startDate,
                "endDate": schedule.endDate,
                "isAllDay": schedule.isAllDay,
                "cycleOption": schedule.cycleOption.rawValue,
                "color": schedule.color,
                "location": schedule.location,
                "address": schedule.address,
                "description": schedule.description
            ]
            
            try await docRef.setData(newEntry, merge: true)
        } catch {
            print("Schedule Upsert Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func deleteSchedule(schedule: ScheduleData) async throws {
        guard let userId = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        do {
            try await db.collection(userId).document("schedules").collection("data").document(schedule.id.uuidString).delete()
            schedules.removeValue(forKey: schedule.id.uuidString)
        } catch {
            print("Schedule Delete Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func setSchedule(schedule: ScheduleData) {
        schedules[schedule.id.uuidString] = schedule
    }
    
    func removeSchedule(schedule: ScheduleData) {
        schedules.removeValue(forKey: schedule.id.uuidString)
    }

}

// MARK: - 사진
extension FirebaseViewModel {
    func fetchPhotos(schedule: UUID) async throws -> [ImageAsset] {
        guard let userId = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        do {
            let filePath = "/photos/\(userId)/\(schedule.uuidString)"
            let fileRef = Storage.storage().reference().child(filePath)
            
            let list = try await fileRef.listAll()
            
            return try await withThrowingTaskGroup(of: ImageAsset?.self) { group in
                var imageAssets: [ImageAsset] = []
                
                for item in list.items {
                    group.addTask {
                        return await withCheckedContinuation { continuation in
                            item.getData(maxSize: 5 * 1024 * 1024) { data, error in
                                if let error = error {
                                    print("Too Big Size: \(error.localizedDescription)")
                                    continuation.resume(returning: nil)
                                    return
                                }
                                
                                guard let data = data, let image = UIImage(data: data) else {
                                    continuation.resume(returning: nil)
                                    return
                                }
                                
                                let imageAsset = ImageAsset(id: item.name, image: image)
                                continuation.resume(returning: imageAsset)
                            }
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
            print("Fetch Photos Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func upsertPhotos(id schedule: UUID, photos: [ImageAsset]) async throws {
        guard let userId = userId else {
            throw URLError(.userAuthenticationRequired)
        }

        await withThrowingTaskGroup(of: Void.self) { group in
            for photo in photos {
                group.addTask {
                    do {
                        guard let data = photo.image.jpegData(compressionQuality: 0.8) else { return }

                        let fileName = "\(photo.id)" + (photo.id.contains(".jpg") ? "" : ".jpg")
                        let filePath = "/photos/\(userId)/\(schedule.uuidString)/\(fileName)"

                        let storageRef = await self.storage.reference().child("\(filePath)")

                        let _ = try await storageRef.putDataAsync(data, metadata: StorageMetadata(dictionary: ["contentType": "image/jpeg"]))
                        
                    } catch {
                        print("Upsert Image Error: \(error.localizedDescription)")
                        throw error
                    }
                }
            }
        }
    }
    
    func deletePhotos(id schedule: UUID) async throws {
        guard let userId = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            do {
                let filePath = "photos/\(userId)/\(schedule.uuidString)"
                let fileRef = storage.reference().child(filePath)
                
                let list = try await fileRef.listAll()
                
                for item in list.items {
                    try await item.delete()
                }
            } catch {
                print("Delete Photos Error: \(error.localizedDescription)")
                throw error
            }
        }
    }
}

// MARK: - 음성 메모
extension FirebaseViewModel {
    func fetchVoiceMemo(schedule: UUID) async throws -> AVAudioFile? {
        guard let userId = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        do {
            let filePath = "voiceMemos/\(userId)/\(schedule.uuidString)/voiceMemo.m4a"
            let fileRef = Storage.storage().reference().child(filePath)
            
            let _ = try await fileRef.getMetadata() // 파일 존재 여부 확인
            
            let url = try await fileRef.downloadURL()
            let localURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(schedule.uuidString).m4a")
            
            let data = try await URLSession.shared.data(from: url).0
            try data.write(to: localURL)
            
            return try AVAudioFile(forReading: localURL)
        } catch let error as StorageError {
            if error.errorCode == StorageErrorCode.objectNotFound.rawValue {
                return nil
            }
        }
        catch {
            print("Fetch Voice Memo Error: \(error.localizedDescription)")
            throw error
        }
        return nil
    }
    
    func upsertVoiceMemo(id schedule: UUID, voiceMemo: AVAudioFile) async throws {
        guard let userId = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        do {
            let fileName = "voiceMemo.m4a"
            let filePath = "voiceMemos/\(userId)/\(schedule.uuidString)/\(fileName)"
            
            let storageRef = storage.reference().child("\(filePath)")
            
            let _ = try await storageRef.putFileAsync(from: voiceMemo.url, metadata: StorageMetadata(dictionary: ["contentType": "audio/m4a"]))
        } catch {
            print("Upsert Voice Memo Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func deleteVoiceMemo(id schedule: UUID) async throws {
        guard let userId = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        do {
            let filePath = "voiceMemos/\(userId)/\(schedule.uuidString)"
            let fileRef = storage.reference().child(filePath).child("voiceMemo.m4a")
            
            let _ = try await fileRef.getMetadata()
            
            try await fileRef.delete()
        } catch let error as StorageError {
            if error.errorCode == StorageErrorCode.objectNotFound.rawValue {
                return
            }
        } catch {
            print("Delete Voice Memo Error: \(error.localizedDescription)")
            throw error
        }
    }
}

extension FirebaseViewModel {
    private func deleteStorageDirectory(path: String) async throws {
        let storageRef = storage.reference().child(path)
        
        do {
            // 해당 경로의 모든 항목 조회
            let result = try await storageRef.listAll()
            
            // 파일 삭제
            for item in result.items {
                try await item.delete()
            }
            
            // 재귀적으로 하위 디렉토리 삭제
            for prefix in result.prefixes {
                try await deleteStorageDirectory(path: prefix.fullPath)
            }
        } catch let error as StorageError {
            if error.errorCode == StorageErrorCode.objectNotFound.rawValue {
                // 경로가 존재하지 않는 경우 무시
                return
            } else {
                print("Error deleting Storage \(path): \(error.localizedDescription)")
                throw error
            }
        }
    }
}



