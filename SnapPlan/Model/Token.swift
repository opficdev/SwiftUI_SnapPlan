//
//  User.swift
//  SnapPlan
//
//  Created by opfic on 12/31/24.
//
//  구글 소셜 로그인에 사용되는 User 구조체

import Foundation

struct User {
    let idToken: String
    let accessToken: String
    var name: String?   //  이름은 설정 안할수도 있어서?
    
    mutating func changeName(newName: String) {
        name = newName
    }
}
