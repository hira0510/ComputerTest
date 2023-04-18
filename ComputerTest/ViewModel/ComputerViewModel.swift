//
//  ComputerViewModel.swift
//  ComputerTest
//
//  Created by admin on 2023/4/6.
//

import UIKit

class ComputerViewModel: NSObject {
    @objc dynamic var mainValue: String = ""
    @objc dynamic var collectionFrame: CGRect = .zero
    var btnMainModel: [[ComputerBtnType]] = []
    var orient: UIDeviceOrientation = .portrait
    private var equalTempData: ContinuousEqualData = .init()
    private var beforeValue: String = ""
    private var toolType: ComputerBtnType = .none

    func acToC() -> (indexPath: IndexPath, suc: Bool) {
        let mainValueIs0 = mainValue == "0"
        let section = 0
        let find: ComputerBtnType = mainValueIs0 ? .C : .Ac
        var btnModel = btnMainModel
        guard let findC = (btnModel[section].firstIndex { type in return type == find }) else { return (IndexPath.init(), false) }
        let changeTo: ComputerBtnType = mainValueIs0 ? .Ac : .C
        btnModel[section][findC] = changeTo
        btnMainModel = btnModel
        return (IndexPath(item: findC, section: section), true)
    }

    func didClickComputerCellBtn(_ type: ComputerBtnType) {
        var nowTitle = mainValue
        switch type {
        case .Ac:
            mainValue = "0"
            beforeValue = ""
            toolType = .none
            equalTempData.clear()
        case .C:
            mainValue = "0"
            equalTempData.clear()
        case .PlusOrMinus:
            if nowTitle.first == "-" {
                nowTitle.removeFirst()
                mainValue = nowTitle
            } else if mainValue != "0" {
                mainValue = "-" + nowTitle
            }
        case .Percent:
            let textDouble = nowTitle.toDouble / 100
            mainValue = textDouble.toString
        case .Div, .Add, .Sub, .Mult: tool(type)
        case .Equal:
            equalTool(true)
        case .Dot:
            if !mainValue.contains(".") {
                mainValue += "."
            }
        case .Num(let num):
            switch InputStatus.getType(main: mainValue, before: beforeValue, type: toolType) {
            case .NUM:
                mainValue = nowTitle == "0" || equalTempData.isContinuous() ? num : nowTitle + num
            case .NUM_FORMULA_NUM:
                mainValue = nowTitle == "0" ? num : nowTitle + num
            case .NUM_FORMULA:
                if equalTempData.isContinuous() {
                    toolType = .none
                } else if beforeValue.isEmpty {
                    beforeValue = nowTitle
                }
                mainValue = num
            }
            equalTempData.clear()
        case .Other(_), .none: break
        }
    }

    private func tool(_ toolType: ComputerBtnType) {
        self.toolType = toolType
        equalTempData.clear()

        guard toolType != .none else { return }
        switch InputStatus.getType(main: mainValue, before: beforeValue, type: toolType) {
        case .NUM: break
        case .NUM_FORMULA: break
        case .NUM_FORMULA_NUM: equalTool()
        }
    }

    private func equalTool(_ fromEqual: Bool = false) {
        guard equalTempData.isContinuous() || !beforeValue.isEmpty else { return }
        var firstValue = equalTempData.isContinuous() ? mainValue: beforeValue
        var secondValue = equalTempData.isContinuous() ? equalTempData.mainValue: mainValue
        let firstTestValue = "48646423897898943158468971867676454562"
        let secondTestValue = "7"
        firstValue = ArithmeticTool().isDEBUG ? firstTestValue: firstValue
        secondValue = ArithmeticTool().isDEBUG ? secondTestValue: secondValue
        
        let type = equalTempData.isContinuous() ? equalTempData.type: toolType
        var equal: Double = 0
        switch type {
        case .Div: equal = firstValue.toDouble / secondValue.toDouble
        case .Add: equal = firstValue.toDouble + secondValue.toDouble
        case .Sub: equal = firstValue.toDouble - secondValue.toDouble
        case .Mult: equal = firstValue.toDouble * secondValue.toDouble
        default: equal = 0.0
        }
        
        if fromEqual {
            self.equalTempData = ContinuousEqualData(type: type, main: secondValue)
            self.toolType = .none
        }
        self.beforeValue = ""
        if ArithmeticTool().isDEBUG || equal.isInfinite || equal.isNaN || (firstValue != "0" && secondValue != "0" && equal == 0) {
            self.mainValue = ArithmeticTool().factorial(firstValue, secondValue, type).numToExp
        } else {
            self.mainValue = equal.toString
        }
    }

    func changeBtnModel() {
        let orient = UIDevice.current.orientation
        self.orient = orient

        switch orient {
        case .landscapeLeft, .landscapeRight, .portrait, .portraitUpsideDown: break
        default:
            let mainBounds = UIScreen.main.bounds
            let isLandscape = mainBounds.width > mainBounds.height
            self.orient = isLandscape ? .landscapeLeft : .portrait
        }
        self.btnMainModel = ComputerBtnModel().getModel(self.orient)
    }

    func getColumn() -> Int {
        return btnMainModel.first?.count ?? 0
    }

    func getRow() -> Int {
        return btnMainModel.count
    }

    func getHSpace() -> CGFloat {
        switch orient {
        case .landscapeLeft, .landscapeRight: return 8
        default: return 10
        }
    }

    func getWSpace() -> CGFloat {
        switch orient {
        case .landscapeLeft, .landscapeRight: return 5
        default: return 10
        }
    }

    func calculateCellSize() -> (w: Double, h: Double) {
        let wSpace = getWSpace()
        let hSpace = getHSpace()
        //w
        let cellSpaceWidth = wSpace * (getColumn().toDouble - 1)
        let cellAllWidth = floor(collectionFrame.width) - cellSpaceWidth
        let cellMaxWidth = (cellAllWidth / getColumn().toDouble).rounded(.down)
        //h
        let cellSpaceHeight = hSpace * (getRow().toDouble - 1)
        let cellAllHeight = floor(collectionFrame.height) - cellSpaceHeight - 5
        let cellMaxHeight = (cellAllHeight / getRow().toDouble).rounded(.down)

        return (cellMaxWidth, cellMaxHeight)
    }

    func getCellSize(_ indexPath: IndexPath = IndexPath(item: 0, section: 0)) -> CGSize {
        let item = btnMainModel[indexPath.section][indexPath.item]
        let isLandscape = orient == .landscapeRight || orient == .landscapeLeft
        let cellSize = calculateCellSize()
        let portraitSize = cellSize.h > cellSize.w ? cellSize.w : cellSize.h

        switch item {
        case .Num("0"):
            let wSpace = getWSpace()
            let size = isLandscape ? CGSize(width: cellSize.w * 2 + wSpace, height: cellSize.h) : CGSize(width: portraitSize * 2 + wSpace, height: portraitSize)
            return size
        default:
            let size = isLandscape ? CGSize(width: cellSize.w, height: cellSize.h) : CGSize(width: portraitSize, height: portraitSize)
            return size
        }
    }

    func getLeftInsetForSection() -> CGFloat {
        let columnCellSpace = getWSpace() * (getColumn().toDouble - 1)
        let columnCellAllWidth = getCellSize().width * getColumn().toDouble
        let leftInset = (collectionFrame.width - columnCellSpace - columnCellAllWidth) / 2
        return leftInset > 0 ? leftInset : 0
    }

    func getTopInsetForSection() -> CGFloat {
        let rowCellSpace = getHSpace() * (getRow().toDouble - 1)
        let rowCellAllHeight = getCellSize().height * getRow().toDouble
        let topInset = (collectionFrame.height - rowCellSpace - rowCellAllHeight) / 2
        return topInset > 0 ? topInset : 0
    }
}
