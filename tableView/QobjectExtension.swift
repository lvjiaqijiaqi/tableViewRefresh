//
//  QobjectExtension.swift
//  tableView
//
//  Created by lvjiaqi on 16/5/3.
//  Copyright © 2016年 lvjiaqi. All rights reserved.
//

import UIKit

public
enum QPullDownRefreshState: Int {
    case Stopped
    case Dragging
    case Bounce
    case Loading
    case Complete
    case BackToStopped
    
    func isAnyOf(values: [QPullDownRefreshState]) -> Bool {
        return values.contains({ $0 == self })
    }
}


public extension UIGestureRecognizerState {
    func isAnyOf(values: [UIGestureRecognizerState]) -> Bool {
        return values.contains({ $0 == self })
    }
}


public extension NSObject {
    
    private struct safe_associatedKeys {
        static var safe_observersArray = "observers"
    }
    
    
    private var safe_observers: [[String : NSObject]] {
        get {
            if let observers = objc_getAssociatedObject(self, &safe_associatedKeys.safe_observersArray) as? [[String : NSObject]] {
                return observers
            } else {
                let observers = [[String : NSObject]]()
                self.safe_observers = observers
                return observers

            }
        } set {
            objc_setAssociatedObject(self, &safe_associatedKeys.safe_observersArray, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    
    public func safe_addObserver(observer: NSObject, forKeyPath keyPath: String) {
        let observerInfo = [keyPath : observer]
        
        if safe_observers.indexOf({ $0 == observerInfo }) == nil {
            safe_observers.append(observerInfo)
            addObserver(observer, forKeyPath: keyPath, options: .New, context: nil)
        }
    }
    
    public func safe_removeObserver(observer: NSObject, forKeyPath keyPath: String) {
        let observerInfo = [keyPath : observer]
        if let index = safe_observers.indexOf({ $0 == observerInfo}) {
            safe_observers.removeAtIndex(index)
            removeObserver(observer, forKeyPath: keyPath)
        }
    }
    
}



public extension UIScrollView {
    
    private struct Q_associatedKeys {
        static var pullDownRefreshView = "pullToRefreshView"
    }
    private var pullDownRefreshView: QPullDownRefreshView? {
        get {
            return objc_getAssociatedObject(self, &Q_associatedKeys.pullDownRefreshView ) as? QPullDownRefreshView
        }
        set {
            objc_setAssociatedObject(self, &Q_associatedKeys.pullDownRefreshView, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func Q_addPullDownRefreshWithActionHandler(actionHandler: () -> Void) {
        multipleTouchEnabled = false
        panGestureRecognizer.maximumNumberOfTouches = 1
        
        let pullDownRefreshView = QPullDownRefreshView()
        self.pullDownRefreshView = pullDownRefreshView
        pullDownRefreshView.actionHandler = actionHandler
        addSubview(pullDownRefreshView)
        pullDownRefreshView.observing = true
        
    }
    
    public func Q_removePullToRefresh() {
        pullDownRefreshView?.observing = false
        pullDownRefreshView?.removeFromSuperview()
    }
    
    public func Q_completeLoading() {
        self.pullDownRefreshView?.completeLoading()     
    }
 
}



