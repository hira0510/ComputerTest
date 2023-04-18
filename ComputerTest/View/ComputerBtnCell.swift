//
//  ComputerBtnCell.swift
//  ComputerTest
//
//  Created by admin on 2023/4/6.
//

import UIKit

protocol ComputerBtnCellProtocol: AnyObject {
    func clickCellBtn(_ type: ComputerBtnType)
}

class ComputerBtnCell: UICollectionViewCell {

    @IBOutlet weak var mButton: UIButton!
    
    private weak var delegate: ComputerBtnCellProtocol?
    private var mType: ComputerBtnType = .Ac
    
    static var nib: UINib {
        return UINib(nibName: "ComputerBtnCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mButton.addTarget(self, action: #selector(didClickBtn), for: .touchUpInside)
    }
    
    func configCell(type: ComputerBtnType, vc: ComputerBtnCellProtocol) {
        self.mType = type
        self.delegate = vc
        self.layer.cornerRadius = self.frame.height / 2
        self.mButton.setTitle(type.style.title, for: .normal)
        self.mButton.setTitleColor(type.style.txtColor, for: .normal)
        self.mButton.setTitleColor(type.style.highlightTxtColor, for: .highlighted)
        self.mButton.setBackgroundColor(type.style.bgColor, for: .normal)
        self.mButton.setBackgroundColor(type.style.highlightBgColor, for: .highlighted)
    }
    
    @objc func didClickBtn() {
        delegate?.clickCellBtn(mType)
    }
}
