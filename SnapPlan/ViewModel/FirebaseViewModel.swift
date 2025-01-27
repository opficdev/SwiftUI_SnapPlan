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
    
    @Published var isScheduleExist = true
       
   func checkScheduleExist(for userId: String?, date: Date) {
       guard let userId = userId else {
           self.isScheduleExist = false
           return
       }
       
       let dateFormatter = DateFormatter()
       dateFormatter.dateFormat = "yyyy-MM-dd"
       let dateString = dateFormatter.string(from: date)
       
       fetchTimeData(for: userId, date: dateString) { timeDataArr, error in
           DispatchQueue.main.async {
               if let error = error {
                   print("Error fetching time data: \(error.localizedDescription)")
                   self.isScheduleExist = false
                   return
               }
               
               if let timeDataArr = timeDataArr, !timeDataArr.isEmpty {
                   self.isScheduleExist = true
               }
               else {
                   self.isScheduleExist = false
               }
           }
       }
   }
        
    /// 특정 날짜에 `TimeData`를 추가하는 메소드
    func addTimeData(for userId: String, date: String, timeData: TimeData, completion: @escaping (Error?) -> Void) {
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
                "id": timeData.id.uuidString,
                "time": timeData.time,
                "timePeriod": timeData.timePeriod
            ]
            
            existingData.append(newEntry)
            
            docRef.setData(["entries": existingData]) { error in
                completion(error)
            }
        }
    }
    
    /// 특정 날짜의 '`TimeData`를 불러오는 메소드
    func fetchTimeData(for userId: String, date: String, completion: @escaping ([TimeData]?, Error?) -> Void) {
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
            
            let timeDataList: [TimeData] = entries.compactMap { entry in
//                guard let idString = entry["id"] as? String,
                guard let _ = entry["id"] as? String,
//                      let id = UUID(uuidString: idString),
                      let time = entry["time"] as? String,
                      let timePeriod = entry["timePeriod"] as? String else { return nil }
                
                return TimeData(time: time, timePeriod: timePeriod)
            }
            
            completion(timeDataList.isEmpty ? nil : timeDataList, nil)
        }
    }
}
