//
//  ArithmeticTool.swift
//  ComputerTest
//
//  Created by admin on 2023/4/14.
//

import UIKit

class ArithmeticTool: NSObject {

    var newType: ComputerBtnType = .none
    var firstInfo: NumAryInfo = .init()
    var secondInfo: NumAryInfo = .init()
    var isDEBUG: Bool = false

    /// 取得數字資訊(String轉變為[Int])
    private func numAryInfo(_ numStr: String, maxInt: Int, maxDec: Int) -> NumAryInfo {
        let addDot = maxDec - numStr.decimal.count
        let numIsNegative = numStr.contains("-")
        let numIntegerStr = String(repeating: "0", count: max(0, maxInt - numStr.integer.count)) + numStr.integer
        let numDecimalStr = numStr.decimal + String(repeating: "0", count: max(0, addDot))
        let allStr = numIntegerStr + numDecimalStr
        let allAry: [Int] = allStr.map { String($0).toInt }
        return NumAryInfo(allAry, numIsNegative, addDot)
    }

    /// 重新定義加法減法
    private func typeIsSub(_ type: ComputerBtnType) -> ComputerBtnType {
        if type == .Add {
            return (firstInfo.isNegative != secondInfo.isNegative) ? .Sub : .Add
        } else if type == .Sub {
            return (firstInfo.isNegative != secondInfo.isNegative) ? .Add : .Sub
        } else {
            return type
        }
    }

    func factorial(_ firstValue: String, _ secondValue: String, _ type: ComputerBtnType) -> String {
        let firstStr = firstValue.expToNum
        let secondStr = secondValue.expToNum
        let maxInt = max(firstStr.integerPlaces, secondStr.integerPlaces)
        let maxDec = max(firstStr.decimalPlaces, secondStr.decimalPlaces)
        firstInfo = numAryInfo(firstStr, maxInt: maxInt, maxDec: maxDec)
        secondInfo = numAryInfo(secondStr, maxInt: maxInt, maxDec: maxDec)

        var resultArray: [Int] = []
        var dotIndex: Int = 0
        var isNegative: Bool = false
        newType = typeIsSub(type)
        
        print("\(firstStr) \(type.stringValue) \(secondStr)")

        switch newType {
        case .Div:
            guard secondStr.toRegularExpression() != "0" else { return "0" }
            let divResult = div()
            resultArray = divResult.ary
            isNegative = firstInfo.isNegative != secondInfo.isNegative
            dotIndex = divResult.add
        case .Add:
            resultArray = add()
            isNegative = firstInfo.isNegative
            dotIndex = maxDec
        case .Sub:
            let subResult = sub()
            resultArray = subResult.resultAry
            isNegative = subResult.isNegative
            dotIndex = maxDec
        case .Mult:
            resultArray = mult()
            isNegative = firstInfo.isNegative != secondInfo.isNegative
            let addDot = max(secondInfo.addDotIndex, firstInfo.addDotIndex)
            dotIndex = firstStr.decimalPlaces + secondStr.decimalPlaces + addDot
        default: resultArray = []
        }

        var resultStrArray = resultArray.map { $0.toStr }
        if dotIndex != 0 {
            resultStrArray.insert(".", at: resultArray.endIndex.advanced(by: -dotIndex))
        }
        let aryResult = resultStrArray.joined()

        // 去掉前後0
        var result = aryResult.toRegularExpression()
        if isNegative && result.first != "-" {
            result.insert("-", at: result.startIndex)
        }
        print("result: \(result)")
        return result
    }

    /// 加法
    func add() -> [Int] {
        let resultArray = numCarry(digits: firstInfo.ary.count)
        return resultArray
    }

    /// 乘法
    func mult() -> [Int] {
        let resultArray = numCarry(digits: firstInfo.ary.count + secondInfo.ary.count)
        return resultArray
    }

    /// 除法
    func div() -> (ary: [Int], add: Int) {
        var firstAry = firstInfo.ary
        var secondAry = secondInfo.ary
        guard firstAry.count == secondAry.count else { return ([], 0) }

        var resultArray: [Int] = []
        var digits = 0
        var maxDigits: Int?
        var resultDecimalCount: Int = 0

        while !((firstAry.filter { $0 != 0 }).count == 0 || resultArray.count > (maxDigits ?? 0) + 16) {
            let isFirst = maxDigits == nil
            if !findBigAry(firstAry, secondAry).firstMoreThanSecond || isFirst {
                let findMaxSec = findMaxDigits(isFirst, digits - 1)
                digits = findMaxSec.add
                secondAry = findMaxSec.ary
                if isFirst { maxDigits = digits }
            }
            if digits < 0 {
                firstAry.append(0)
                resultDecimalCount += 1
            }
            guard let maxDigits = maxDigits else { continue }
            while findBigAry(firstAry, secondAry).firstMoreThanSecond || firstAry == secondAry {
                firstAry = sub(firstAry, secondAry, true).resultAry
                if digits >= 0 {
                    while resultArray.count < maxDigits + 1 {
                        resultArray.append(0)
                    }
                    resultArray[maxDigits - digits] += 1
                } else {
                    while resultArray.count < maxDigits + abs(digits) + 1 {
                        resultArray.append(0)
                    }
                    resultArray[maxDigits + abs(digits)] += 1
                }
                if (firstAry.filter { $0 != 0 }).count == 0 {
                    break
                }
            }
        }

        return (resultArray, resultDecimalCount)
    }

    /// 減法
    func sub(_ first: [Int] = [], _ second: [Int] = [], _ fromDiv: Bool = false) -> (resultAry: [Int], isNegative: Bool) {
        var firstAry = first.isEmpty ? firstInfo.ary : first
        var secondAry = second.isEmpty ? secondInfo.ary : second
        guard firstAry.count == secondAry.count else { return ([], false) }

        let digits = firstAry.count
        var resultArray: [Int] = Array.init(repeating: 0, count: digits)

        // first是否是最大Ary
        var firstMoreThanSecond: Bool = false

        if let borrow = borrow(firstAry, secondAry) {
            borrow.firstMoreThanSecond ? (firstAry = borrow.bigAry) : (secondAry = borrow.bigAry)
            firstMoreThanSecond = borrow.firstMoreThanSecond
        }

        resultArray = numCarry(firstAry, secondAry, fromDiv, digits: digits)

        var isNegative: Bool = false
        // 把複數都改成正數
        for (i, result) in resultArray.enumerated() {
            resultArray[i] = abs(result)
        }

        // 判斷結果是否是負數
        if ((!firstMoreThanSecond && !firstInfo.isNegative) || (firstMoreThanSecond && firstInfo.isNegative)) && firstAry != secondAry {
            isNegative = true
        }

        return (resultArray, isNegative)
    }

    func findMaxDigits(_ findMax: Bool = false, _ add: Int = 0) -> (ary: [Int], add: Int) {
        var ary = secondInfo.ary
        var mAdd = 0
        if findMax {
            while (ary.first == 0) {
                ary.remove(at: 0)
                ary.append(0)
                mAdd += 1
            }
        } else if add == 0 {
            return (ary, 0)
        } else if add > 0 {
            while add != mAdd {
                ary.removeFirst()
                ary.append(0)
                mAdd += 1
            }
        } else if add < 0 {
            while add != mAdd {
                ary.insert(0, at: 0)
                mAdd -= 1
            }
        }
        return (ary, mAdd)
    }

    // 判斷哪個Ary比較大
    func findBigAry(_ firstAry: [Int] = [], _ secondAry: [Int] = []) -> (firstMoreThanSecond: Bool, findMax: Bool, maxIndex: Int) {
        // first是否是最大Ary
        var firstMoreThanSecond: Bool = false
        // 最大Ary最大數的index(Ex: [321]:[301] -> index = 1)
        var maxIndex = 0
        // 是否有找到最大Ary最大數的index了
        var findMaxValue = false

        // 判斷哪個Ary比較大，找出數字比另個Ary大的index位置
        while !findMaxValue {
            if firstAry == secondAry {
                break
            } else if firstAry[maxIndex] > secondAry[maxIndex] {
                firstMoreThanSecond = true
                findMaxValue = true
            } else if firstAry[maxIndex] < secondAry[maxIndex] {
                findMaxValue = true
            } else if firstAry.count - 1 > maxIndex {
                maxIndex += 1
            }
        }
        return (firstMoreThanSecond, findMaxValue, maxIndex)
    }

    // 借位
    func borrow(_ firstAry: [Int] = [], _ secondAry: [Int] = []) -> (bigAry: [Int], firstMoreThanSecond: Bool)? {
        // 先判斷哪個Ary比較大，找出數字比另個Ary大的index位置，數字大的要先借位
        let findBigAry = findBigAry(firstAry, secondAry)
        // first是否是最大Ary
        let firstMoreThanSecond: Bool = findBigAry.firstMoreThanSecond
        // 最大Ary最大數的index(Ex: [321]:[301] -> index = 1)
        let maxIndex = findBigAry.maxIndex
        // 是否有找到最大Ary最大數的index了
        let findMaxValue = findBigAry.findMax

        // 使用先借位的方式
        if findMaxValue {
            var bigAry = firstMoreThanSecond ? firstAry : secondAry
            for (i, value) in bigAry.enumerated() {
                guard i >= maxIndex else { continue }
                if i == maxIndex && value > 0 {
                    if i == bigAry.count - 1 { break } //如果只有一位數字就不用借位了
                    bigAry[i] -= 1
                } else if (i == bigAry.count - 1) {
                    bigAry[i] += 10
                } else {
                    bigAry[i] += 9
                }
            }
            return (bigAry, firstMoreThanSecond)
        }
        return nil
    }

    /// 每種算式的計算以及進位
    func numCarry(_ firstArray: [Int] = [], _ secondArray: [Int] = [], _ fromDiv: Bool = false, digits: Int) -> [Int] {
        let firstAry = firstArray.isEmpty ? firstInfo.ary : firstArray
        let secondAry = secondArray.isEmpty ? secondInfo.ary : secondArray
        guard firstAry.count == secondAry.count else { return [] }
        var resultArray: [Int] = Array.init(repeating: 0, count: digits)
        var carryIndex: Int = digits - 1
        let type: ComputerBtnType = fromDiv ? .Sub : newType

        // 每種算式的計算
        for (index, firstInt) in firstAry.enumerated() {
            switch type {
            case .Div: break
            case .Add:
                resultArray[index] = firstInt + secondAry[index]
            case .Sub:
                resultArray[index] = firstInt - secondAry[index]
            case .Mult:
                let firstLocation = firstAry.count - 1 - index
                for secondInt in 0..<secondAry.count {
                    let secondLocation = secondAry.count - 1 - secondInt
                    let resultIndex = firstLocation + secondLocation + 1
                    let numResult = firstAry[firstLocation] * secondAry[secondLocation]
                    resultArray[resultIndex] += numResult
                }
            default: resultArray = []
            }
        }

        // 每種算式的進位
        switch type {
        case .Div: break
        case .Add:
            while carryIndex > 0 {
                resultArray[carryIndex - 1] += resultArray[carryIndex] / 10
                resultArray[carryIndex] %= 10
                carryIndex -= 1
                if carryIndex == 0 && resultArray[carryIndex] >= 10 {
                    let index0 = resultArray[carryIndex]
                    resultArray[carryIndex] %= 10
                    resultArray.insert(index0 / 10, at: 0)
                }
            }
        case .Sub, .Mult:
            while carryIndex > 0 {
                resultArray[carryIndex - 1] += resultArray[carryIndex] / 10
                resultArray[carryIndex] %= 10
                carryIndex -= 1
            }
        default: resultArray = []
        }

        return resultArray
    }
}
