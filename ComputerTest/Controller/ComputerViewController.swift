//
//  ComputerViewController.swift
//  ComputerTest
//
//  Created by admin on 2023/4/6.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

class ComputerViewController: UIViewController {
    
    @IBOutlet weak var mCollectionView: UICollectionView!
    @IBOutlet weak var numLabel: UILabel!
    
    private let viewModel = ComputerViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.changeBtnModel()
        setupCollectionView()
        bind()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
        }, completion: { [weak self] (UIViewControllerTransitionCoordinatorContext) -> Void in
            guard let `self` = self else { return }
            self.viewModel.changeBtnModel()
            self.viewModel.collectionFrame.accept(self.mCollectionView.frame)
        })
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    private func setupCollectionView() {
        mCollectionView.delegate = self
        mCollectionView.dataSource = self
        mCollectionView.register(ComputerBtnCell.nib, forCellWithReuseIdentifier: "ComputerBtnCell")
    }
    
    private func bind() {
        let mainValueObserver: Binder<String> = Binder(self) { vc, str in
            vc.numLabel.text = str
            let acToc = vc.viewModel.acToC()
            if acToc.suc {
                guard let cell = self.mCollectionView.cellForItem(at: acToc.indexPath) as? ComputerBtnCell else { return }
                cell.configCell(type: self.viewModel.btnMainModel.value[acToc.indexPath.section][acToc.indexPath.item], vc: self)
            }
        }
        
        let collectionFrameObserver: Binder<CGRect> = Binder(self.mCollectionView) { collectionView, size in
            collectionView.reloadData()
        }
        
        viewModel.mainValue.bind(to: mainValueObserver).disposed(by: viewModel.disposeBag)
        viewModel.collectionFrame.bind(to: collectionFrameObserver).disposed(by: viewModel.disposeBag)
    }
}

extension ComputerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if self.viewModel.collectionFrame.value == .zero {
            self.viewModel.collectionFrame.accept(collectionView.frame)
        }
        return self.viewModel.btnMainModel.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.btnMainModel.value[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ComputerBtnCell", for: indexPath) as! ComputerBtnCell
        let type = viewModel.btnMainModel.value[indexPath.section][indexPath.item]
        cell.configCell(type: type, vc: self)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel.getCellSize(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return viewModel.getWSpace()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let top = section == 0 ? viewModel.getTopInsetForSection(): 0
        let btm = section == viewModel.btnMainModel.value.count - 1 ? viewModel.getTopInsetForSection() + viewModel.getHSpace(): viewModel.getHSpace()
        return UIEdgeInsets(top: top, left: viewModel.getLeftInsetForSection(), bottom: btm, right: viewModel.getLeftInsetForSection())
    }
}

extension ComputerViewController: ComputerBtnCellProtocol {
    func clickCellBtn(_ type: ComputerBtnType) {
        viewModel.didClickComputerCellBtn(type)
    }
}
