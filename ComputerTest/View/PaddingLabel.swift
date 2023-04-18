//
//  PaddingLabel.swift
//  ComputerTest
//
//  Created by admin on 2023/4/18.
//

import UIKit

@IBDesignable class CustomView: UIView {
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commit()
    }
    
    func commit() {
        self.addSubview(dynamicFontLabel)
        
        NSLayoutConstraint.activate([
            dynamicFontLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            dynamicFontLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            dynamicFontLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10),
            dynamicFontLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
            dynamicFontLabel.topAnchor.constraint(equalTo: self.topAnchor),
            dynamicFontLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    @IBInspectable var text: String = "" {
        didSet {
            dynamicFontLabel.text = "texttexttexttexttexttexttexttexttexttexttext"
            self.setNeedsLayout()
        }
    }
    
    // MARK: - UI
    let dynamicFontLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 55)
        label.textAlignment = .right
        label.textColor = .white
//        label.numberOfLines = 3
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setIsBottom()
        return label
    }()
}
