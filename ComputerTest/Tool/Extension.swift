//
//  Extension.swift
//  ComputerTest
//
//  Created by admin on 2023/4/6.
//

import UIKit

extension CGSize {
    
    func calculateOrientScaleWithSize(width: CGFloat, height: CGFloat, _ orient: UIDeviceOrientation = .portrait) -> CGSize {
        switch orient {
        case .landscapeLeft, .landscapeRight:
            let width = width / CGFloat(375)
            let widthResult = UIScreen.main.bounds.height * width
            let height = height / CGFloat(375)
            let heightResult = UIScreen.main.bounds.height * height
            return CGSize(width: widthResult, height: heightResult)
        default:
            let width = width / CGFloat(375)
            let widthResult = UIScreen.main.bounds.width * width
            let height = height / CGFloat(375)
            let heightResult = UIScreen.main.bounds.width * height
            return CGSize(width: widthResult, height: heightResult)
        }
    }
    func calculateWidthScaleWithSize(width: CGFloat, height: CGFloat) -> CGSize {
        let width = width / CGFloat(375)
        let widthResult = UIScreen.main.bounds.width * width
        let height = height / CGFloat(375)
        let heightResult = UIScreen.main.bounds.width * height
        return CGSize(width: widthResult, height: heightResult)
    }
}

extension Int {
    
    var toDouble: Double {
        return Double(self)
    }
    var toStr: String {
        return String(self)
    }
}

extension Double {
    
    var toStr: String {
        return String(self)
    }
    
    var toNumStr: String {
        return String(format: "%.0f", self)
    }
    
    var toString: String {
        if self.truncatingRemainder(dividingBy: 1) == 0 {
            if self >= 1e+15 || self <= 1e-15 {
                return self.toStr
            } else {
                return self.toNumStr
            }
        } else {
            return self.isNaN  ? "0" : self.toStr
        }
    }
}

extension String {
    
    /// 數字正則
    func toRegularExpression() -> String {
        // 去掉小數點後的0
        var result = self.replacingOccurrences(of: "([0-9]+(?:\\.[0-9]*[1-9])?)(?:\\.?0*)$", with: "$1", options: .regularExpression)
        // 去掉整數前的0
        result = result.replacingOccurrences(of: "^0*^0+", with: "$1", options: .regularExpression)

        if result.first == "." || result == "" {
            result.insert("0", at: result.startIndex)
        }
        return result
    }
    
    var numToExp: String {
        var integerPart = self.integer
        var decimalPart = self.decimal
        var exp = 0
        if self.integerPlaces >= 2 {
            while integerPart.count > 1 {
                let last: Character = integerPart.last ?? "0"
                integerPart.removeLast()
                decimalPart.insert(last, at: decimalPart.startIndex)
                exp += 1
            }
        } else if self.decimalPlaces >= 15 {
            while integerPart.last == "0" {
                let first: Character = decimalPart.first ?? "0"
                decimalPart.removeFirst()
                integerPart.append(first)
                exp -= 1
            }
        }
        let eStr = exp > 0 ? "e+\(exp)": "e\(exp)"
//        let decimalPart15 = decimalPart.count > 15 ? String(decimalPart.prefix(15)): decimalPart
        let resultRegularExpression = integerPart + (decimalPart.isEmpty ? "" : "." + decimalPart)
        let result = (self.hasPrefix("-") ? "-" : "") + resultRegularExpression.toRegularExpression() + (exp == 0 ? "" : eStr)
        print("afterE: \(exp >= 15 || exp <= -15 ? result.toRegularExpression(): self)")
        return exp >= 15 || exp <= -15 ? result.toRegularExpression(): self
    }
    
    var expToNum: String {
        let scientificNotation = self.replacingOccurrences(of: "^-", with: "", options: .regularExpression)
        let parts = scientificNotation.components(separatedBy: ["e", "E"])
        let base = String(parts[0])
        let exponent = parts.count == 2 ? String(parts[1]): "0"
        let baseComponents = base.split(separator: ".")
        var integerPart = String(baseComponents[0])
        var decimalPart = ""
        if baseComponents.count > 1 {
            decimalPart = String(baseComponents[1])
        }
        if let exp = Int(exponent) {
            if exp > 0 {
                // Pad decimal part with zeros if necessary
                while decimalPart.count < exp {
                    decimalPart += "0"
                }
                // Move decimal point to the right
                integerPart += decimalPart.prefix(exp)
                decimalPart = String(decimalPart.dropFirst(exp))
            } else if exp < 0 {
                // Pad integer part with zeros if necessary and add a leading zero
                while integerPart.count < abs(exp) {
                    integerPart = "0" + integerPart
                }
                integerPart = "0" + integerPart
                // Move decimal point to the left
                decimalPart = String(integerPart.suffix(abs(exp))) + decimalPart
                integerPart = String(integerPart.prefix(integerPart.count + exp))
            }
        }
        let result = (self.hasPrefix("-") ? "-" : "") + integerPart + (decimalPart.isEmpty ? "" : "." + decimalPart)
        return result
    }
    
    var toNumStr: String {
        return String(format: "%.0f", self)
    }
    
    var integer: String {
        let integer = self.split(separator: ".")[0]
        return String(integer).replacingOccurrences(of: "-", with: "")
    }
    
    var integerPlaces: Int {
        return integer.count
    }
    
    var decimal: String {
        let decimals = self.split(separator: ".")
        if decimals.count > 1 {
            return String(decimals[1])
        } else {
            return ""
        }
    }
    
    var decimalPlaces: Int {
        return decimal.count
    }
    
    var toDouble: Double {
        if let double = Double(self) {
            return double
        }
        return 0
    }
    
    var toInt: Int {
        if let int = Int(self) {
            return int
        }
        return 0
    }
}

extension UIButton {

    func blink() {
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.1
        flash.fromValue = 1
        flash.toValue = 0.2
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = 1

        layer.add(flash, forKey: nil)
    }

    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        let colorImage = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { _ in
          color.setFill()
          UIBezierPath(rect: CGRect(x: 0, y: 0, width: 1, height: 1)).fill()
        }
        setBackgroundImage(colorImage, for: state)
    }
}

extension UILabel {
    func setIsBottom() {
        let fontSize = self.font?.pointSize ?? 0
        let fontHeight = self.font?.lineHeight ?? fontSize
        let num = Int(self.frame.size.height / fontHeight)
        let newLinesToPad = num - self.numberOfLines
        self.numberOfLines = 0
        for _ in 0..<abs(newLinesToPad) {
            self.text = " \n" + (self.text ?? "")
        }
    }
    
    func calculateMaxLines() -> Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font!], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height / charSize))
        return linesRoundedUp
    }
}
