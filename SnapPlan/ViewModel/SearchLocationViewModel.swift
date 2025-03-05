//
//  SearchLocationViewModel.swift
//  SnapPlan
//
//  Created by opfic on 2/28/25.
//

import SwiftUI
import MapKit
import Combine

class SearchLocationViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var query = ""   // 사용자 입력 값
    @Published var suggestions: [MKLocalSearchCompletion] = []
    
    private var searchCompleter = MKLocalSearchCompleter()
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .pointOfInterest // 검색 타입 설정 (주소, POI 등)
        
        // @Published query 값이 변경될 때마다 검색 수행
        $query
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main) // 입력 지연 방지
            .sink { [weak self] newQuery in
                guard let self = self else { return }
                self.searchCompleter.queryFragment = newQuery
            }
            .store(in: &cancellables)
    }

    // 검색 결과 업데이트 시 호출됨
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.suggestions = completer.results
        }
    }
    
    // 검색 실패 시 호출됨
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("검색 실패: \(error.localizedDescription)")
    }
}
