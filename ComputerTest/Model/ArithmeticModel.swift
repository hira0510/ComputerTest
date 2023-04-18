//
//  ArithmeticModel.swift
//  ComputerTest
//
//  Created by admin on 2023/4/13.
//

import UIKit

class NumAryInfo {
    var ary: [Int] = []
    var isNegative: Bool = false
    var addDotIndex: Int = 0
    
    init(_ ary: [Int] = [], _ isNegative: Bool = false, _ addDotIndex: Int = 0) {
        self.ary = ary
        self.isNegative = isNegative
        self.addDotIndex = addDotIndex
    }
}
