//
//  Task.swift
//  taskapp
//
//  Created by Taishi Kamiya on 2020/06/07.
//  Copyright © 2020 taishi.kamiya. All rights reserved.
//

import RealmSwift

class Task: Object {
    //管理用ID プライマリーキー
    @objc dynamic var id = 0
    
    //title
    @objc dynamic var title = ""
    
    //category 
    @objc dynamic var category = ""
    
    //内容
    @objc dynamic var contents = ""
    
    //日時
    @objc dynamic var date = Date()
    
    //idをプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
}
