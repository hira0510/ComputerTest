//
//  ComputerModel.swift
//  ComputerTest
//
//  Created by admin on 2023/4/6.
//

import UIKit
import RxCocoa
import RxSwift

enum ComputerBtnType {
    case none
    case Ac
    case C
    /// ±
    case PlusOrMinus
    /// %
    case Percent
    /// 除
    case Div
    /// 加
    case Add
    /// 減
    case Sub
    /// 乘
    case Mult
    /// 等於
    case Equal
    case Dot
    case Num(_ num: String)
    case Other(_ str: String)

    var stringValue: String {
        switch self {
        case .Ac: return "AC"
        case .C: return "C"
        case .PlusOrMinus: return "±"
        case .Percent: return "%"
        case .Div: return "÷"
        case .Add: return "+"
        case .Sub: return "-"
        case .Mult: return "x"
        case .Equal: return "="
        case .Dot: return "."
        case .Num(let num): return num
        case .Other(let str): return str
        case .none: return ""
        }
    }

    static func == (lhs: ComputerBtnType, rhs: ComputerBtnType) -> Bool {
        return lhs.stringValue == rhs.stringValue
    }

    static func != (lhs: ComputerBtnType, rhs: ComputerBtnType) -> Bool {
        return lhs.stringValue != rhs.stringValue
    }

    var style: (title: String, txtColor: UIColor, highlightTxtColor: UIColor, bgColor: UIColor, highlightBgColor: UIColor) {
        switch self {
        case .Ac, .C, .PlusOrMinus, .Percent:
            let text = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            let bg = #colorLiteral(red: 0.6274509804, green: 0.6274509804, blue: 0.6274509804, alpha: 1)
            let highlightBg = #colorLiteral(red: 0.8509803922, green: 0.8470588235, blue: 0.8470588235, alpha: 1)
            return (title: stringValue, txtColor: text, highlightTxtColor: text, bgColor: bg, highlightBgColor: highlightBg)
        case .Div, .Add, .Sub, .Mult, .Equal:
            let text = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            let highlightTxt = #colorLiteral(red: 0.9725490196, green: 0.6235294118, blue: 0.04705882353, alpha: 1)
            let bg = #colorLiteral(red: 0.9647058824, green: 0.6, blue: 0.01568627451, alpha: 1)
            let highlightBg = #colorLiteral(red: 0.9803921569, green: 0.7803921569, blue: 0.5529411765, alpha: 1)
            return (title: stringValue, txtColor: text, highlightTxtColor: highlightTxt, bgColor: bg, highlightBgColor: highlightBg)
        case .Dot:
            let text = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            let bg = #colorLiteral(red: 0.1921568627, green: 0.1921568627, blue: 0.1921568627, alpha: 1)
            let highlightBg = #colorLiteral(red: 0.6274509804, green: 0.6274509804, blue: 0.6274509804, alpha: 1)
            return (title: stringValue, txtColor: text, highlightTxtColor: text, bgColor: bg, highlightBgColor: highlightBg)
        case .Num(let num):
            let text = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            let bg = #colorLiteral(red: 0.1921568627, green: 0.1921568627, blue: 0.1921568627, alpha: 1)
            let highlightBg = #colorLiteral(red: 0.4509803922, green: 0.4470588235, blue: 0.4509803922, alpha: 1)
            return (title: num, txtColor: text, highlightTxtColor: text, bgColor: bg, highlightBgColor: highlightBg)
        case .Other(let str):
            let text = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            let bg = #colorLiteral(red: 0.1176470588, green: 0.1176470588, blue: 0.1176470588, alpha: 1)
            let highlightBg = #colorLiteral(red: 0.3019607843, green: 0.2980392157, blue: 0.3019607843, alpha: 1)
            return (title: str, txtColor: text, highlightTxtColor: text, bgColor: bg, highlightBgColor: highlightBg)
        case .none:
            return (title: "", txtColor: .clear, highlightTxtColor: .clear, bgColor: .clear, highlightBgColor: .clear)
        }
    }
}

enum InputStatus {
    case NUM
    case NUM_FORMULA
    case NUM_FORMULA_NUM
    
    static func getType(main: String, before: String, type: ComputerBtnType) -> InputStatus {
        if type == .none {
            return .NUM
        } else {
            if before.isEmpty || main == "0" {
                return .NUM_FORMULA
            } else {
                return .NUM_FORMULA_NUM
            }
        }
    }
}

class ContinuousEqualData {
    var type: ComputerBtnType = .none
    var mainValue: String = ""
    
    init(type: ComputerBtnType = .none, main: String = "") {
        self.type = type
        self.mainValue = main
    }
    
    func clear() {
        self.type = .none
        self.mainValue = ""
    }
    
    func isContinuous() -> Bool {
        return self.type != .none && !self.mainValue.isEmpty
    }
}

class ComputerBtnModel {
    let portraitModel: [[ComputerBtnType]] = [
        [.Ac, .PlusOrMinus, .Percent, .Div],
        [.Num("7"), .Num("8"), .Num("9"), .Mult],
        [.Num("4"), .Num("5"), .Num("6"), .Sub],
        [.Num("1"), .Num("2"), .Num("3"), .Add],
        [.Num("0"), .Dot, .Equal]
    ]

    let landscapeModel: [[ComputerBtnType]] = [
        [.Other("a"), .Other("b"), .Other("c"), .Other("d"), .Other("e"), .Other("f"), .Ac, .PlusOrMinus, .Percent, .Div],
        [.Other("g"), .Other("h"), .Other("i"), .Other("j"), .Other("k"), .Other("l"), .Num("7"), .Num("8"), .Num("9"), .Mult],
        [.Other("m"), .Other("n"), .Other("o"), .Other("p"), .Other("q"), .Other("r"), .Num("4"), .Num("5"), .Num("6"), .Sub],
        [.Other("s"), .Other("t"), .Other("u"), .Other("v"), .Other("w"), .Other("x"), .Num("1"), .Num("2"), .Num("3"), .Add],
        [.Other("y"), .Other("z"), .Other("!"), .Other("@"), .Other("#"), .Other("$"), .Num("0"), .Dot, .Equal]
    ]
    
    func getModel(_ orient: UIDeviceOrientation) -> [[ComputerBtnType]] {
        switch orient {
        case .landscapeLeft, .landscapeRight:
            return landscapeModel
        case .portrait, .portraitUpsideDown:
            return portraitModel
        default: return []
        }
    }
}
