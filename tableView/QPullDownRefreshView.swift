//
//  QTableViewRefresh.swift
//  tableView
//
//  Created by lvjiaqi on 16/4/29.
//  Copyright © 2016年 lvjiaqi. All rights reserved.
//

import UIKit

public class QPullDownRefreshView: UIView {
    
    
    var actionHandler: (() -> Void)!
    
    var loadingSharpLayer:LoadingSharpLayer?
    
    private var scrollView:UIScrollView!{
        get{
             return superview as! UIScrollView
        }
    }
    
    private var currentHeight:CGFloat{
        get{
            guard let scrollView = self.scrollView else { return 0.0 }
            return max(-originalContentInsetTop - scrollView.contentOffset.y, 0)
        }
    }
    
    private  var actualContentOffsetY:CGFloat{
        get{
            guard let scrollView = self.scrollView else { return 0.0 }
            return max(-scrollView.contentInset.top - scrollView.contentOffset.y, 0)
        }
    }
    
    
    private var originalContentInsetTop: CGFloat = 0.0 { didSet { layoutSubviews() } }
    
    private(set) var state: QPullDownRefreshState = .Stopped{
         didSet{
            switch state {
            case .Stopped:
                self.observing = true
                self.loadingSharpLayer?.loadingLayerState = .Stopped
            case .Dragging: self.loadingSharpLayer?.loadingLayerState = .Dragging
            case .Bounce:
                if oldValue == .Dragging {
                    self.loadingSharpLayer?.loadingLayerState = .Bounce
                    self.observing = false
                    updateScrollViewContentInset(self.currentHeight, animated: false, completion: { [unowned self]() -> () in
                            self.state = .Loading
                        })
                }
            case .Loading:
                updateScrollViewContentInset(QTableViewRefreshConfig.TriggerOffsetToPull, animated: true, completion: { [unowned self]() -> () in
                    self.loadingSharpLayer?.loadingLayerState = .Loading
                    self.actionHandler()
                    })
            case .Complete: self.loadingSharpLayer?.loadingLayerState = .Complete
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {[unowned self]() -> () in self.state = .BackToStopped
                             })
            case .BackToStopped:
                updateScrollViewContentInset(0, animated: true, completion: { [unowned self]() -> () in
                    self.state = .Stopped
                    })
            }
         }
    }
    
    var observing: Bool = false {
        didSet {
            guard let scrollView = self.scrollView else { return }
            if observing {
                scrollView.safe_addObserver(self, forKeyPath: QTableViewRefreshConfig.KeyPaths.ContentOffset)
                scrollView.safe_addObserver(self, forKeyPath: QTableViewRefreshConfig.KeyPaths.ContentInset)
                scrollView.safe_addObserver(self, forKeyPath: QTableViewRefreshConfig.KeyPaths.Frame)
                scrollView.safe_addObserver(self, forKeyPath: QTableViewRefreshConfig.KeyPaths.PanGestureRecognizerState)
            } else {
                scrollView.safe_removeObserver(self, forKeyPath: QTableViewRefreshConfig.KeyPaths.ContentOffset)
                scrollView.safe_removeObserver(self, forKeyPath: QTableViewRefreshConfig.KeyPaths.ContentInset)
                scrollView.safe_removeObserver(self, forKeyPath: QTableViewRefreshConfig.KeyPaths.Frame)
                scrollView.safe_removeObserver(self, forKeyPath: QTableViewRefreshConfig.KeyPaths.PanGestureRecognizerState)
            }
        }
    }

    init() {
        super.init(frame: CGRectZero)
        self.loadingSharpLayer = LoadingSharpLayer()
        self.loadingSharpLayer!.frame = CGRectMake(0, 0, 50, 50)
        self.loadingSharpLayer!.anchorPoint = CGPointMake(0.5, 0.5)
        self.layer.addSublayer(self.loadingSharpLayer!)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == QTableViewRefreshConfig.KeyPaths.ContentOffset {
            if let scrollView = self.scrollView  where scrollView.contentOffset.y < -self.originalContentInsetTop  {
                if state == .Stopped && scrollView.dragging {
                    self.loadingSharpLayer?.loadingLayerState = .Dragging
                    state = .Dragging
                }
            }
            updateLoadingView()
            
        } else if keyPath == QTableViewRefreshConfig.KeyPaths.ContentInset {
            if let newContentInsetTop = change?[NSKeyValueChangeNewKey]?.UIEdgeInsetsValue().top {
                originalContentInsetTop = newContentInsetTop
            }
            updateLoadingView()
        } else if keyPath == QTableViewRefreshConfig.KeyPaths.Frame {
                updateLoadingView()
        } else if keyPath == QTableViewRefreshConfig.KeyPaths.PanGestureRecognizerState {
            
            if let gestureState = scrollView?.panGestureRecognizer.state where gestureState.isAnyOf([.Ended, .Cancelled, .Failed]) {
                 if state == .Dragging  {
                    if self.actualContentOffsetY  >= QTableViewRefreshConfig.TriggerOffsetToPull {
                        state = .Bounce
                     } else {
                        state = .Stopped
                     }
                }
            }
        }
    }
    
    private func updateScrollViewContentInset(contentInsetTop:CGFloat , animated: Bool, completion: (() -> ())?) {
        

        var contentInset = self.scrollView.contentInset
        contentInset.top = originalContentInsetTop
        contentInset.top += contentInsetTop
        
        let animationBlock = {
            self.scrollView.contentInset = contentInset ;
        }

        if animated {
            UIView.animateWithDuration(0.4, animations: animationBlock, completion: { _ in
                completion!()
            })
        } else {
            animationBlock()
            completion!()
        }
    }
    
    func completeLoading() {
        if state == .Complete {
            return
        }
        state = .Complete
    }
    
    
    public func updateLoadingView() {
        
        if let scrollView = self.scrollView{
            let width = scrollView.bounds.width
            let heightY = self.currentHeight
            let height = heightY > QTableViewRefreshConfig.TriggerOffsetToPull ?  QTableViewRefreshConfig.TriggerOffsetToPull : heightY
            self.frame = CGRect(x: 0.0, y: -height, width: width, height: height)
            
            if let loadingLayer = self.loadingSharpLayer{ 
                CATransaction.begin();
                CATransaction.setDisableActions(true)
                loadingLayer.position = CGPointMake(width/2, height/2)
                loadingLayer.updateLoadingView(self.currentHeight/QTableViewRefreshConfig.TriggerOffsetToPull)
                CATransaction.commit();
            }
            
        }
        self.setNeedsLayout()
    }

    
}


