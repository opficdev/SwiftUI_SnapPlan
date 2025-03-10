//
//  File.swift
//  SnapPlan
//
//  Created by opfic on 3/10/25.
//

import MapKit

// MARK: @retroactive - extension으로 똑같은 프로토콜을 conform하면 컴파일 에러가 발생하는데,
// MARK: 애플에 의해서 아무잘못 없는 내 코드가 컴파일 에러가 나면 너무 유연성이 없어지므로 애플은 아래처럼 컴파일 에러 대신 경고메시지를 출력하도록 함
// MARK: 이를 해결하기 위해 @retroactive 키워드를 사용하여 extension으로 conform하는 것을 허용함

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
