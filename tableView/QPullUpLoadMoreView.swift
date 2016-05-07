//
//  QPullUpLoadMoreView.swift
//  tableView
//
//  Created by lvjiaqi on 16/5/5.
//  Copyright © 2016年 lvjiaqi. All rights reserved.
//

import UIKit


public
enum pullUpLoadMoreState: Int {
    case Default
    case Dragging
    case Trigger
    case Failure
}

class QPullUpLoadMoreView: UIView {
    
    var actionHandler: (() -> Void)!
    var labelMsg:UILabel = UILabel()
    
    var state:pullUpLoadMoreState = .Default{
        didSet{
            switch state {
            case .Default: self.hidden = false;
            case .Dragging: break;
            case .Trigger: self.actionHandler!()
            case .Failure: self.labelMsg.text = "load fail , please up again"  ; self.state = .Default
            }
        }
       
    }
    
    private var scrollView:UIScrollView!{
        get{
            return superview as! UIScrollView
        }
    }
    
    var observing: Bool = false {
        didSet {
            guard let scrollView = self.scrollView else { return }
            if observing {
                scrollView.safe_addObserver(self, forKeyPath: QTableViewRefreshConfig.KeyPaths.ContentOffset)
                scrollView.safe_addObserver(self, forKeyPath: QTableViewRefreshConfig.KeyPaths.contentSize)
            } else {
                scrollView.safe_removeObserver(self, forKeyPath: QTableViewRefreshConfig.KeyPaths.ContentOffset)
                scrollView.safe_removeObserver(self, forKeyPath: QTableViewRefreshConfig.KeyPaths.contentSize)
            }
        }
    }
   
    init(){
        super.init(frame: CGRectZero)
        
        self.labelMsg.frame = CGRectMake(0, 0, 0, 0)
        self.labelMsg.text = "loading ... "
        self.labelMsg.font = UIFont(name: "ljq", size: 10.0)
        self.labelMsg.textAlignment = NSTextAlignment.Center
        self.addSubview(self.labelMsg)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        var contentInset = self.scrollView!.contentInset
        contentInset.bottom =  QTableViewRefreshConfig.LoadingMoreOffset
        self.scrollView!.contentInset = contentInset
    }
    
    func completeLoading() {
        if state == .Default {
            return
        }
        state = .Default
    }
    
    func failLoading() {
        if state == .Failure {
            return
        }
        state = .Failure
    }
    
    override  func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == QTableViewRefreshConfig.KeyPaths.ContentOffset {
            if let scrollView = self.scrollView  where scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height  {
                if scrollView.contentOffset.y != 0 {
                    if self.state == .Default{
                        self.state = .Trigger
                        self.labelMsg.text = "loading ... "
                    }else if state == .Trigger{
                        
                    }
                }
            }
        }else if keyPath == QTableViewRefreshConfig.KeyPaths.contentSize{
            if let scrollView = self.scrollView where scrollView.contentSize.height != 0 {
                 self.frame = CGRectMake(0, self.scrollView!.contentSize.height, self.scrollView!.contentSize.width, QTableViewRefreshConfig.LoadingMoreOffset)
                 self.labelMsg.frame = CGRectMake(0, QTableViewRefreshConfig.LoadingMoreOffset/4, self.scrollView!.contentSize.width, QTableViewRefreshConfig.LoadingMoreOffset/2)
                self.state = .Default
            }
        }
    }

    
    
    
}