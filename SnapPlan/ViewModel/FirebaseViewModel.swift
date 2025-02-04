//
//  FireStoreViewModel.swift
//  SnapPlan
//
//  Created by opfic on 1/17/25.
//

import Foundation
import FirebaseFirestore


final class FirebaseViewModel: ObservableObject {
    private let db = Firestore.firestore()
        
    /// 특정 날짜에 `ScheduleData`를 추가하는 메소드
    func addTimeData(for userId: String, date: String, schedule: ScheduleData, completion: @escaping (Error?) -> Void) {
        let docRef = db.collection("timeData").document(userId).collection("dates").document(date)
        
        docRef.getDocument { document, error in
            if let error = error {
                completion(error)
                return
            }
            
            var existingData: [[String: Any]] = []
            
            if let data = document?.data(), let entries = data["entries"] as? [[String: Any]] {
                existingData = entries
            }
            
            let newEntry: [String: Any] = [
                "title": schedule.title,
                "timeLine": schedule.timeLine,
                "cycleOption": schedule.cycleOption,
                "location": schedule.location,
                "description": schedule.description,
                "color": schedule.color
            ]
            
            existingData.append(newEntry)
            
            docRef.setData(["entries": existingData]) { error in
                completion(error)
            }
        }
    }
    
    /// 특정 날짜의 '`TimeData`를 불러오는 메소드
    func fetchTimeData(for userId: String, date: String, completion: @escaping ([ScheduleData]?, Error?) -> Void) {
        let docRef = db.collection("timeData").document(userId).collection("dates").document(date)
        
        docRef.getDocument { document, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data(), let entries = data["entries"] as? [[String: Any]] else {
                completion(nil, nil) // 데이터가 없으면 nil 반환
                return
            }
            
            let timeDataList: [ScheduleData] = entries.compactMap { entry in
                guard let title = entry["title"] as? String,
                      let timeLine = entry["timeLine"] as? (Date, Date),
                      let cycleOption = entry["cycleOption"] as? ScheduleData.CycleOption,
                      let location = entry["location"] as? String,
                      let description = entry["description"] as? String,
                      let color = entry["color"] as? Int else { return nil }
                return ScheduleData(
                    title: title,
                    timeLine: timeLine,
                    cycleOption: cycleOption,
                    location: location,
                    description: description,
                    color: color
                )
            }
            
            completion(timeDataList.isEmpty ? nil : timeDataList, nil)
        }
    }
}
