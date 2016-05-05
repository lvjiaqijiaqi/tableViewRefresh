//
//  LoadingSharpLayer.swift
//  tableView
//
//  Created by lvjiaqi on 16/5/3.
//  Copyright © 2016年 lvjiaqi. All rights reserved.
//

import UIKit


public
enum QloadingViewState: Int {
    
    case Stopped
    case Dragging
    case Bounce
    case Loading
    case Complete
    
}


class LoadingSharpLayer: CAShapeLayer {
    
    var  loadingLayerState:QloadingViewState = .Stopped{
        didSet{
            switch loadingLayerState {
            case .Stopped: self.hidden = true
            case .Dragging:
                if oldValue == .Stopped {
                    self.hidden = false
                    self.opacity = 0
                    let center:CGPoint = CGPointMake(25, 25)
                    let uPath:UIBezierPath = UIBezierPath(arcCenter: center, radius: 15 , startAngle: 0 , endAngle: 5.5 , clockwise: true)
                    self.path = uPath.CGPath
                    self.fillColor = UIColor.clearColor().CGColor
                    self.strokeColor = UIColor(red: 135.0/256, green: 206.0/256, blue: 250.0/256, alpha: 1).CGColor
                    self.lineWidth = 5
                    self.strokeStart = 0
                    self.strokeEnd = 0
                }
            case .Loading:
                if oldValue == .Bounce {
                    self.loadingAnimationSwitch = true
                }
            case .Bounce:
                if oldValue == .Dragging {
                    self.transform = CATransform3DMakeRotation( 0 , 0 , 0 , 1 )
                }
            case .Complete:
                if oldValue == .Loading {
                    self.loadingAnimationSwitch = false
                    let uPath:UIBezierPath = UIBezierPath()
                    uPath.moveToPoint(CGPointMake(7.5, 28))
                    uPath.addLineToPoint(CGPointMake(20,42.5))
                    uPath.addLineToPoint(CGPointMake(42.5, 18))
                    self.path = uPath.CGPath
                    self.fillColor = UIColor.clearColor().CGColor
                    self.strokeColor = UIColor(red: 135.0/256, green: 206.0/256, blue: 250.0/256, alpha: 1).CGColor
                    self.lineWidth = 6
                    self.strokeStart = 0
                    self.strokeEnd = 1
                    
                }
            }
        }
    }
    
    
    
    var loadingAnimationSwitch:Bool = false{
        didSet{
            if  self.loadingAnimationSwitch {
                let loadingAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
                loadingAnimation.fromValue = 0
                loadingAnimation.toValue = 2 * M_PI
                loadingAnimation.duration = 1
                loadingAnimation.repeatCount = 100
                loadingAnimation.speed = 1
                self.addAnimation(loadingAnimation, forKey: "loadingTransform")
            }else{
                self.removeAnimationForKey("loadingTransform")
            }
        }
    }
    
    
    override init() {
         super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(layer: AnyObject) {
        super.init(layer: layer)
    }
    
    func updateLoadingView(process:CGFloat){
        self.strokeEnd = process < 1 ? process : 1
        self.opacity = Float(process)
        self.transform = CATransform3DMakeRotation( CGFloat(M_PI) * 2 * process , 0, 0, 1)
    }
   
}