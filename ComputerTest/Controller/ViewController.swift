//
//  ViewController.swift
//  ComputerTest
//
//  Created by admin on 2023/4/6.
//

import UIKit

class ViewController: UIViewController {

    var computerVc: ComputerViewController = ComputerViewController(nibName: "ComputerViewController", bundle: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        addVc()
    }

    func addVc() {
        self.addChild(computerVc)
        view.addSubview(computerVc.view)
        computerVc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            computerVc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            computerVc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            computerVc.view.topAnchor.constraint(equalTo: view.topAnchor),
            computerVc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        computerVc.didMove(toParent: self)
    }
}

