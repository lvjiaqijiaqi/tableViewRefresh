//
//  File.swift
//  tableView
//
//  Created by lvjiaqi on 16/4/29.
//  Copyright © 2016年 lvjiaqi. All rights reserved.
//

import CoreGraphics

public struct QTableViewRefreshConfig {
    
    struct KeyPaths {
        static let ContentOffset = "contentOffset"
        static let ContentInset = "contentInset"
        static let contentSize = "contentSize"
        static let Frame = "frame"
        static let PanGestureRecognizerState = "panGestureRecognizer.state"
    }
    
    public static var TriggerOffsetToPull: CGFloat = 95.0
    public static var LoadingOffset: CGFloat = 50.0
    
    public static var TriggerOffsetToLoadMore: CGFloat = 50.0
    public static var LoadingMoreOffset: CGFloat = 50.0
    
}