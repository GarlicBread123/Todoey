//
//  Category.swift
//  Todoey
//
//  Created by Shawn Jiang on 4/8/18.
//  Copyright © 2018 Shawn Jiang. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    let items = List<Item>()
}
