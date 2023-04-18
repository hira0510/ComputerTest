//
//  ComputerViewModel.swift
//  ComputerTest
//
//  Created by admin on 2023/4/6.
//

import UIKit
import RxSwift
import RxCocoa

class ComputerViewModel: NSObject {

    var disposeBag = DisposeBag()
    var mainValue: BehaviorRelay<String> = BehaviorRelay(value: "0")
    var btnMainModel: BehaviorRelay<[[ComputerBtnType]]> = BehaviorRelay(value: [])
    var orient: UIDeviceOrientation = .portrait
    var collectionFrame: BehaviorRelay<CGRect> = BehaviorRelay(value: CGRect.zero)
    private var equalTempData: ContinuousEqualData = .init()
    private var beforeValue: BehaviorRelay<String> = BehaviorRelay(value: "")
    private var toolType: BehaviorRelay<ComputerBtnType> = BehaviorRelay(value: .none)

    func acToC() -> (indexPath: IndexPath, suc: Bool) {
        let mainValueIs0 = mainValue.value == "0"
        let section = 0
        let find: ComputerBtnType = mainValueIs0 ? .C : .Ac
        var btnModel = btnMainModel.value
        guard let findC = (btnModel[section].firstIndex { type in return type == find }) else { return (IndexPath.init(), false) }
        let changeTo: ComputerBtnType = mainValueIs0 ? .Ac : .C
        btnModel[section][findC] = changeTo
        btnMainModel.accept(btnModel)
        return (IndexPath(item: findC, section: section), true)
    }

    func didClickComputerCellBtn(_ type: ComputerBtnType) {
        var nowTitle = mainValue.value
        switch type {
        case .Ac:
            mainValue.accept("0")
            beforeValue.accept("")
            toolType.accept(.none)
            equalTempData.clear()
        case .C:
            mainValue.accept("0")
            equalTempData.clear()
        case .PlusOrMinus:
            if nowTitle.first == "-" {
                nowTitle.removeFirst()
                mainValue.accept(nowTitle)
            } else if mainValue.value != "0" {
                mainValue.accept("-" + nowTitle)
            }
        case .Percent:
            let textDouble = nowTitle.toDouble / 100
            mainValue.accept(textDouble.toString)
        case .Div, .Add, .Sub, .Mult: tool(type)
        case .Equal:
            equalTool(true)
        case .Dot:
            if !mainValue.value.contains(".") {
                mainValue.accept(mainValue.value + ".")
            }
        case .Num(let num):
            switch InputStatus.getType(main: mainValue.value, before: beforeValue.value, type: toolType.value) {
            case .NUM:
                mainValue.accept(nowTitle == "0" || equalTempData.isContinuous() ? num : nowTitle + num)
            case .NUM_FORMULA_NUM:
                mainValue.accept(nowTitle == "0" ? num : nowTitle + num)
            case .NUM_FORMULA:
                if equalTempData.isContinuous() {
                    toolType.accept(.none)
                } else if beforeValue.value.isEmpty {
                    beforeValue.accept(nowTitle)
                }
                mainValue.accept(num)
            }
            equalTempData.clear()
        case .Other(_), .none: break
        }
    }

    private func tool(_ toolType: ComputerBtnType) {
        self.toolType.accept(toolType)
        equalTempData.clear()

        guard toolType != .none else { return }
        switch InputStatus.getType(main: mainValue.value, before: beforeValue.value, type: toolType) {
        case .NUM: break
        case .NUM_FORMULA: break
        case .NUM_FORMULA_NUM: equalTool()
        }
    }

    private func equalTool(_ fromEqual: Bool = false) {
        guard equalTempData.isContinuous() || !beforeValue.value.isEmpty else { return }
        let firstValue = equalTempData.isContinuous() ? mainValue.value: beforeValue.value
        let secondValue = equalTempData.isContinuous() ? equalTempData.mainValue.value: mainValue.value
        let type = equalTempData.isContinuous() ? equalTempData.type.value: toolType.value
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
            self.toolType.accept(.none)
        }
        self.beforeValue.accept("")
        if equal.isInfinite || equal.isNaN || (firstValue != "0" && secondValue != "0" && equal == 0) {
            self.mainValue.accept(ArithmeticTool().factorial(firstValue, secondValue, type).numToExp)
        } else {
            self.mainValue.accept(equal.toString)
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
        self.btnMainModel.accept(ComputerBtnModel().getModel(self.orient))
    }

    func getColumn() -> Int {
        return btnMainModel.value.first?.count ?? 0
    }

    func getRow() -> Int {
        return btnMainModel.value.count
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
        let cellAllWidth = floor(collectionFrame.value.width) - cellSpaceWidth
        let cellMaxWidth = (cellAllWidth / getColumn().toDouble).rounded(.down)
        //h
        let cellSpaceHeight = hSpace * (getRow().toDouble - 1)
        let cellAllHeight = floor(collectionFrame.value.height) - cellSpaceHeight - 5
        let cellMaxHeight = (cellAllHeight / getRow().toDouble).rounded(.down)

        return (cellMaxWidth, cellMaxHeight)
    }

    func getCellSize(_ indexPath: IndexPath = IndexPath(item: 0, section: 0)) -> CGSize {
        let item = btnMainModel.value[indexPath.section][indexPath.item]
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
        let leftInset = (collectionFrame.value.width - columnCellSpace - columnCellAllWidth) / 2
        return leftInset > 0 ? leftInset : 0
    }

    func getTopInsetForSection() -> CGFloat {
        let rowCellSpace = getHSpace() * (getRow().toDouble - 1)
        let rowCellAllHeight = getCellSize().height * getRow().toDouble
        let topInset = (collectionFrame.value.height - rowCellSpace - rowCellAllHeight) / 2
        return topInset > 0 ? topInset : 0
    }
}
