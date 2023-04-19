//
//  ComputerViewController.swift
//  ComputerTest
//
//  Created by admin on 2023/4/6.
//

import UIKit

class ComputerViewController: UIViewController {

    @IBOutlet weak var mCollectionView: UICollectionView!
    @IBOutlet weak var numLabel: UILabel!
    @IBOutlet weak var calculateLabel: UILabel!
    
    private let viewModel = ComputerViewModel()
    private var mainValueObs: NSKeyValueObservation?
    private var collectionFrameObs: NSKeyValueObservation?
    private var calculateStrObs: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.changeBtnModel()
        setupCollectionView()
        addPanGesture()
        bind()
    }

//    deinit {
//        self.mainValueObs?.invalidate()
//        self.collectionFrameObs?.invalidate()
//    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
        }, completion: { [weak self] (UIViewControllerTransitionCoordinatorContext) -> Void in
            guard let `self` = self else { return }
            self.viewModel.changeBtnModel()
            self.viewModel.collectionFrame = self.mCollectionView.frame
        })
        super.viewWillTransition(to: size, with: coordinator)
    }

    private func setupCollectionView() {
        mCollectionView.delegate = self
        mCollectionView.dataSource = self
        mCollectionView.register(ComputerBtnCell.nib, forCellWithReuseIdentifier: "ComputerBtnCell")
    }
    
    private func addPanGesture() {
        let pan: UIPanGestureRecognizer = UIPanGestureRecognizer.init(target: target, action: Selector(("returnReviousResult:")))
        self.view.addGestureRecognizer(pan)
        pan.delegate = self
        self.view.addGestureRecognizer(pan)
    }

    private func bind() {
        mainValueObs = viewModel.observe(\.mainValue, options: [.old, .new]) { [weak self] (vm, change) in
            guard let `self` = self, let newValue = change.newValue else { return }
            self.numLabel.text = newValue
            let acToc = vm.acToC()
            if acToc.suc {
                guard let cell = self.mCollectionView.cellForItem(at: acToc.indexPath) as? ComputerBtnCell else { return }
                cell.configCell(type: vm.btnMainModel[acToc.indexPath.section][acToc.indexPath.item], vc: self)
            }
        }
        collectionFrameObs = viewModel.observe(\.collectionFrame, options: [.old, .new]) { [weak self] (vm, change) in
            guard let `self` = self else { return }
            self.mCollectionView.reloadData()
        }
        calculateStrObs = viewModel.observe(\.calculateInfo, options: [.old, .new]) { [weak self] (vm, change) in
            guard let `self` = self, let newValue = change.newValue else { return }
            if newValue.complete {
                self.calculateLabel.text = newValue.str
            } else {
                self.calculateLabel.text = ""
                self.numLabel.text = newValue.str
            }
        }
        addObserver(self, forKeyPath: "mainValue", options: [.new], context: nil)
        addObserver(self, forKeyPath: "collectionFrame", options: [.new], context: nil)
        addObserver(self, forKeyPath: "calculateStr", options: [.new], context: nil)
    }
}

extension ComputerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if self.viewModel.collectionFrame == .zero {
            self.viewModel.collectionFrame = collectionView.frame
        }
        return self.viewModel.btnMainModel.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.btnMainModel[section].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ComputerBtnCell", for: indexPath) as! ComputerBtnCell
        let type = viewModel.btnMainModel[indexPath.section][indexPath.item]
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
        let top = section == 0 ? viewModel.getTopInsetForSection() : 0
        let btm = section == viewModel.btnMainModel.count - 1 ? viewModel.getTopInsetForSection() + viewModel.getHSpace() : viewModel.getHSpace()
        return UIEdgeInsets(top: top, left: viewModel.getLeftInsetForSection(), bottom: btm, right: viewModel.getLeftInsetForSection())
    }
}

extension ComputerViewController: ComputerBtnCellProtocol {
    func clickCellBtn(_ type: ComputerBtnType) {
        viewModel.didClickComputerCellBtn(type)
    }
}

extension ComputerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        let movePoint: CGPoint = pan.translation(in: self.view)
        let absX: CGFloat = abs(movePoint.x)
        let absY: CGFloat = abs(movePoint.y)
        guard absX > absY, movePoint.x > 0 else { return false }
        self.viewModel.returnReviousResult()
        return true
    }
}
