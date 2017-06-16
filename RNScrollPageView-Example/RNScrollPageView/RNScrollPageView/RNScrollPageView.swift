//
//  RNScrollPageView.swift
//  RNScrollPageView
//
//  Created by 罗伟 on 2017/5/31.
//  Copyright © 2017年 罗伟. All rights reserved.
//

import UIKit
public enum PageItemState {
    case normal
    case selected
}

@objc protocol RNScrollPageViewDelegate: NSObjectProtocol {
    @objc optional func scrollPageView(_ scrollPageView: RNScrollPageView, didShow viewController: UIViewController, at index: Int)
}

class RNScrollPageView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // viewController array
    open var viewControllers = [UIViewController]() {
        didSet {
            self.configScrollPage()
        }
    }
    // title array
    open var titles = [String]() {
        didSet {
            self.configScrollPage()
        }
    }
    
    @IBInspectable open var selectedIndex: Int = 0 // selected index, default is 0
    @IBInspectable open var pageItemWidth: CGFloat = 0 // pageItem's width, is dont set, default is adjust according to the number of titles
    @IBInspectable open var pageItemHeight: CGFloat = 40.0 // pageItem's height, default is 40.0
    @IBInspectable open var isHideSubLine: Bool = false // is hide the slidable subLine, default is false
    @IBInspectable open var subLineHeight: CGFloat = 2.0 // subLineView's height, default is 2.0
    @IBInspectable open var subLineWidth: CGFloat = 0 // if dont set, default is item width
    @IBInspectable open var itemTitleMargin: CGFloat = 20.0 // the margin between with the adjoining item, default is 20.0
    @IBInspectable open var subLineViewColor: UIColor = UIColor.red // subLineView's color, default is red
    @IBInspectable open var titleColorNormal: UIColor = UIColor.black // item's titleColor for normal, default is black
    @IBInspectable open var titleColorSelected: UIColor = UIColor.red // item's titleColor for selected, default is red
    @IBInspectable open var isZoomTitle: Bool = true // item's title zoom animation, default is true; if true, the titleFontSelected is does not work
    @IBInspectable open var maxItemScale: CGFloat = 1.2 // item's title max zoom scale, default is 1.2
    @IBInspectable open var splitLineViewHeight: CGFloat = 0.5 // bottom splitLine's height, default is 0.5
    @IBInspectable open var splitLineViewColor: UIColor = UIColor.white // the bottom splitLineView's background color, default is white
    @IBInspectable open var isHideSplit: Bool = true // is hide bottom splitLineView, default is true
    @IBInspectable open var titleFontSizeNormal: CGFloat = 14 {
        didSet {
            self.titleFontNormal = UIFont.systemFont(ofSize: titleFontSizeNormal)
        }
    } // titleFontSize for normal, default is system 14
    @IBInspectable open var titleFontSizeSelected: CGFloat = 16 {
        didSet {
            self.titleFontSelected = UIFont.systemFont(ofSize: titleFontSizeSelected)
        }
    } // item's titleFontSize for selected, default is system 16
    open var titleFontNormal: UIFont = UIFont.systemFont(ofSize: 14) // item's titleFont for normal, default is system 14
    open var titleFontSelected: UIFont = UIFont.systemFont(ofSize: 16) // item's titleFont for selected, default is system 16
    
    weak open var delegate: RNScrollPageViewDelegate?
    open var splitLineView: UIView = UIView()
    open var subLineView = UIView()
    open var currentSelectedIndex = 0
    
    private var expectedItemWidths = [CGFloat]()
    private var collectionView: UICollectionView?
    private var scrollView: UIScrollView?
    private var isPageItemActionScroll = false
    private var lastSelectedCell: PageItemCell?
    
    // MARK: - open method
    
    open func config(with viewControllers: [UIViewController], titles: [String]) {
        self.viewControllers = viewControllers
        self.titles = titles
    }
    
    
    open func setTitleFont(_ font: UIFont, for state: PageItemState) {
        switch state {
        case .selected:
            self.titleFontSelected = font
            
        case .normal:
            self.titleFontNormal = font
        }
    }
    
    open func setTitleColor(_ color: UIColor, for state: PageItemState) {
        switch state {
        case .selected:
            self.titleColorSelected = color
            
        case .normal:
            self.titleColorNormal = color
        }
    }
    
    open func titleFont(for state: PageItemState) -> UIFont {
        switch state {
        case .selected:
            return self.titleFontSelected
            
        case .normal:
            return self.titleFontNormal
        }
    }
    
    open func titleColor(for state: PageItemState) -> UIColor {
        switch state {
        case .selected:
            return self.titleColorSelected
            
        case .normal:
            return self.titleColorNormal
        }
    }
    
    // MARK: - private method
    
    private func configScrollPage() {
        guard self.titles.count > 0 else {
            return
        }
        
        guard self.viewControllers.count > 0 else {
            return
        }
        
        guard self.titles.count == self.viewControllers.count else {
            print("vc和标题数据源大小不匹配, 请检查")
            return
        }
        
        // fix cellForItem not call bug
        self.parentViewController?.automaticallyAdjustsScrollViewInsets = false
        self.layoutIfNeeded()
        
        if self.collectionView == nil {
            self.addPageItemsCollectionView()
            if !isHideSplit {
                self.addSplitLineView()
            }
        }
        
        if self.scrollView == nil {
            self.addContentScrollView()
        }
        
        self.expectedItemWidths = self.getPageItemWidths()
        
        // when the total itemWidth is less than pageViewWidth, itemWidth = pageViewWidth/itemCount
        if self.pageItemWidth == 0 {
            var maxWidth: CGFloat = 0
            let widths = self.expectedItemWidths.reduce(0) { (result, width) -> CGFloat in
                maxWidth = max(width, maxWidth)
                return result + width
            }
            let compareWidth = self.bounds.width/CGFloat(self.titles.count)
            if widths <= self.bounds.width, compareWidth >= maxWidth {
                self.pageItemWidth = compareWidth
            }
        }
        
        // set subLineView
        var subLineWidth: CGFloat = 0
        if self.subLineWidth == 0 {
            subLineWidth = self.expectedItemWidths[self.selectedIndex]
        } else {
            subLineWidth = self.subLineWidth
        }
        
        if subLineWidth > pageItemWidth, pageItemWidth > 0 {
            subLineWidth = pageItemWidth
        }
        
        var centerX: CGFloat = 0
        if self.pageItemWidth != 0 {
            centerX = pageItemWidth * CGFloat(self.selectedIndex) + pageItemWidth/2
        } else {
            for (index, width) in self.expectedItemWidths.enumerated() {
                if index < self.selectedIndex {
                    centerX += width
                } else if index == self.selectedIndex {
                    centerX += width/2
                }
            }
        }
        
        self.subLineView.center = CGPoint(x: centerX, y: pageItemHeight - subLineHeight + 1.0 + splitLineViewHeight) // 1.0 is collectionView's contentSize edgeInset
        self.subLineView.bounds = CGRect(x: 0, y: 0, width: subLineWidth, height: subLineHeight + 1.0 + splitLineViewHeight)
        self.subLineView.isHidden = self.isHideSubLine
        self.subLineView.backgroundColor = subLineViewColor
        self.collectionView?.addSubview(self.subLineView)
        
        self.currentSelectedIndex = self.selectedIndex
        
        self.collectionView?.reloadData()
        
        // handle default selectedIndex
        if self.selectedIndex <= self.viewControllers.count, self.selectedIndex <= self.titles.count, self.selectedIndex >= 0 {
            self.collectionView?.scrollToItem(at: IndexPath(item: self.selectedIndex, section: 0), at: .centeredHorizontally, animated: false)
            self.scrollView?.scrollRectToVisible(CGRect(x: self.scrollView!.bounds.width * CGFloat(self.selectedIndex), y: 0, width: self.scrollView!.bounds.width, height: self.scrollView!.bounds.width), animated: false)
        }
        
        // show default viewController
        self.showSelectedViewController(self.selectedIndex)
    }
    
    private func addPageItemsCollectionView() {
        // set collectionView
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        let frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.pageItemHeight)
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(PageItemCell.self, forCellWithReuseIdentifier: PageItemCell.description())
        collectionView.backgroundColor = UIColor.white
        self.addSubview(collectionView)
        
        self.collectionView = collectionView
    }
    
    private func addSplitLineView() {
        self.splitLineView.frame = CGRect(x: 0, y: self.pageItemHeight, width: self.bounds.width, height: splitLineViewHeight)
        self.splitLineView.backgroundColor = self.splitLineViewColor
        self.addSubview(splitLineView)
    }
    
    private func addContentScrollView() {
        let width = self.bounds.width
        var height = self.bounds.height - self.pageItemHeight
        if let _ = self.parentViewController?.navigationController {
            height = height - 64 // hard code
        }
        var y = self.pageItemHeight
        if !isHideSplit {
            height = height - splitLineViewHeight
            y = y + splitLineViewHeight
        }
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: y, width: width, height: height))
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: (width * CGFloat(self.viewControllers.count)), height: height)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        self.addSubview(scrollView)
        
        self.scrollView = scrollView
    }
    
    private func updateSubLineViewPosition(_ scrollView: UIScrollView) {
        let offSetX = scrollView.contentOffset.x
        guard 0 <= offSetX, offSetX <= scrollView.contentSize.width - scrollView.bounds.width else {
            return
        }
        
        let beforeIndex = floorf(Float(offSetX/self.bounds.width))
        let afterIndex = ceilf(Float(offSetX/self.bounds.width))
        guard let beforeCell = self.collectionView?.cellForItem(at: IndexPath(item: Int(beforeIndex), section: 0)) else {
            return
        }
        
        guard let afterCell = self.collectionView?.cellForItem(at: IndexPath(item: Int(afterIndex), section: 0)) else {
            return
        }
        
        let centerDistance = afterCell.center.x - beforeCell.center.x
        let scrollScale = offSetX.truncatingRemainder(dividingBy: scrollView.bounds.width)/scrollView.bounds.width
        
        let centerX = scrollScale * centerDistance + beforeCell.center.x
        
        if self.subLineWidth == 0 {
            let width = centerX >= self.subLineView.center.x ? afterCell.bounds.width : beforeCell.bounds.width
            UIView.animate(withDuration: 0.2, animations: {
                self.subLineView.bounds = CGRect(x: 0, y: 0, width: width, height: self.subLineHeight)
            })
        }
        self.subLineView.center.x = centerX
    }
    
    private func getPageItemWidths() -> [CGFloat] {
        let widths = self.titles.map { (title) -> CGFloat in
            let maxFont = max(self.titleFontNormal.pointSize, self.titleFontSelected.pointSize)
            let font = self.titleFontNormal.pointSize == maxFont ? self.titleFontNormal : self.titleFontSelected
            let rect = title.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: self.pageItemHeight), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
            return rect.width + self.itemTitleMargin
        }
        return widths
    }
    
    private func showSelectedViewController(_ selectedIndex: Int) {
        // add currentSelected viewController
        guard let parentViewController = self.parentViewController else {
            return
        }
        
        let width = self.scrollView!.bounds.width
        let height = self.scrollView!.bounds.height
        let selectedViewController = self.viewControllers[selectedIndex]
        if !parentViewController.childViewControllers.contains(selectedViewController) {
            self.parentViewController?.addChildViewController(selectedViewController)
            selectedViewController.view.frame = CGRect(x: width * CGFloat(selectedIndex), y: 0, width: width, height: height)
            self.scrollView?.addSubview(selectedViewController.view)
            self.parentViewController?.didMove(toParentViewController: selectedViewController)
        }
        
        self.delegate?.scrollPageView?(self, didShow: selectedViewController, at: selectedIndex)
    }
    
    private func updatePageItemState(_ index: Int, scrollView: UIScrollView) {
        // update pageItem titleLabel`
        
        //边界item不处理
        if scrollView.contentOffset.x > scrollView.contentSize.width - scrollView.bounds.width || scrollView.contentOffset.x < 0 {
            return
        }
        
        var progress = scrollView.contentOffset.x.truncatingRemainder(dividingBy: scrollView.bounds.width)/scrollView.bounds.width
        if progress == 0 {
            progress = 1
        }
        
        //get next index
        var nextIndex = index
        if scrollView.contentOffset.x > scrollView.bounds.width * CGFloat(index) {
            nextIndex += 1
        } else if scrollView.contentOffset.x < scrollView.bounds.width * CGFloat(index) {
            nextIndex -= 1
        }
        
        //update titleColor
        let currentCell = self.collectionView?.cellForItem(at: IndexPath(item: index, section: 0)) as? PageItemCell
        currentCell?.titleLabel?.textColor = self.titleColorSelected.transFormColorTo(self.titleColorNormal, progress: progress)
        
        let nextCell = self.collectionView?.cellForItem(at: IndexPath(item: nextIndex, section: 0)) as? PageItemCell
        nextCell?.titleLabel?.textColor = self.titleColorNormal.transFormColorTo(self.titleColorSelected, progress: progress)
        
        //update size or font
        
        if isZoomTitle {
            let currentItemScale = maxItemScale - (maxItemScale - 1) * progress
            let nextItemScale = 1 + (maxItemScale - 1) * progress
            currentCell?.transform = CGAffineTransform(scaleX: currentItemScale, y: currentItemScale)
            nextCell?.transform = CGAffineTransform(scaleX: nextItemScale, y: nextItemScale)
        } else {
            nextCell?.titleLabel?.font = self.titleFont(for: .selected)
            currentCell?.titleLabel?.font = self.titleFont(for: .normal)
        }
    }
    
    private func updatePageItemState(_ formIndex: Int, toIndex: Int) {
        //update titleColor
        let currentCell = self.collectionView?.cellForItem(at: IndexPath(item: formIndex, section: 0)) as? PageItemCell
        currentCell?.titleLabel?.textColor = self.titleColorNormal
        
        let nextCell = self.collectionView?.cellForItem(at: IndexPath(item: toIndex, section: 0)) as? PageItemCell
        nextCell?.titleLabel?.textColor = self.titleColorSelected
        
        //update size or font
        if isZoomTitle {
            currentCell?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            nextCell?.transform = CGAffineTransform(scaleX: maxItemScale, y: maxItemScale)
            
        } else {
            currentCell?.titleLabel?.font = self.titleFont(for: .normal)
            nextCell?.titleLabel?.font = self.titleFont(for: .selected)
        }
        
        // fix a bug
        if currentCell == nil {
            self.lastSelectedCell?.titleLabel?.textColor = self.titleColorNormal
            if isZoomTitle {
                self.lastSelectedCell?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            } else {
                self.lastSelectedCell?.titleLabel?.font = self.titleFont(for: .normal)
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewControllers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PageItemCell.description(), for: indexPath) as! PageItemCell
        cell.titleLabel?.text = self.titles[indexPath.item]
        
        if indexPath.item == self.currentSelectedIndex {
            self.lastSelectedCell = cell
            cell.titleLabel?.textColor = self.titleColor(for: .selected)
            if self.isZoomTitle {
                cell.transform = CGAffineTransform(scaleX: maxItemScale, y: maxItemScale)
                cell.titleLabel?.font = self.titleFont(for: .normal)
            } else {
                cell.titleLabel?.font = self.titleFont(for: .selected)
            }
            
        } else {
            cell.titleLabel?.textColor = self.titleColor(for: .normal)
            cell.titleLabel?.font = self.titleFont(for: .normal)
            cell.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.pageItemWidth == 0 {
            return CGSize(width: self.expectedItemWidths[indexPath.item], height: pageItemHeight)
        } else {
            return CGSize(width: self.pageItemWidth, height: pageItemHeight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let width = self.scrollView?.bounds.width ?? 0
        let height = self.scrollView?.bounds.height ?? 0
        
        self.isPageItemActionScroll = true
        let isAnimated = fabsf(Float(self.currentSelectedIndex - indexPath.item)) <= 2
        
        self.updatePageItemState(self.currentSelectedIndex, toIndex: indexPath.item)
        
        self.scrollView?.scrollRectToVisible(CGRect(x: width * CGFloat(indexPath.item), y: 0, width: width, height: height), animated: isAnimated)
        
        self.showSelectedViewController(indexPath.item)
        self.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        self.lastSelectedCell = collectionView.cellForItem(at: indexPath) as? PageItemCell
    }
    
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.isPageItemActionScroll = false
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.isMember(of: UIScrollView.self) {
            self.collectionView?.scrollToItem(at: IndexPath(item: self.currentSelectedIndex, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isMember(of: UIScrollView.self) {
            let offSetX = scrollView.contentOffset.x
            self.currentSelectedIndex = Int(offSetX/self.bounds.width)
            self.updateSubLineViewPosition(scrollView)
            if !self.isPageItemActionScroll {
                self.updatePageItemState(self.currentSelectedIndex, scrollView: scrollView)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.isMember(of: UIScrollView.self) {
            self.showSelectedViewController(self.currentSelectedIndex)
        }
    }
}

class PageItemCell: UICollectionViewCell {
    var titleLabel: UILabel?
    var state: PageItemState = .normal
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let label = UILabel.init(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        label.textAlignment = .center
        self.addSubview(label)
        self.titleLabel = label
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension RNScrollPageView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

extension UIColor {
    var redValue: CGFloat {return CIColor(color: self).red}
    var greenValue: CGFloat {return CIColor(color: self).green}
    var blueValue: CGFloat {return CIColor(color: self).blue}
    var alphaValue: CGFloat {return CIColor(color: self).alpha}
    
    func transFormColorTo(_ color: UIColor, progress: CGFloat) -> UIColor? {
        var progress = progress
        progress = progress >= 1 ? 1 : progress
        progress = progress <= 0 ? 0 : progress
        
        let newR = self.redValue * (1 - progress) + color.redValue * progress
        let newG = self.greenValue * (1 - progress) + color.greenValue * progress
        let newB = self.blueValue * (1 - progress) + color.blueValue * progress
        let alpha = self.alphaValue * (1 - progress) + color.alphaValue * progress
        
        let newColor = UIColor.init(colorLiteralRed: Float(newR), green: Float(newG), blue: Float(newB), alpha: Float(alpha))
        
        return newColor
    }
}
