//
//  Tween.swift
//  TweenDemo
//
//  Created by aleksey on 28.09.15.
//  Copyright © 2015 aleksey chernish. All rights reserved.
//

import Foundation
import QuartzCore
import UIKit

class Tween {
    private weak var layer: TweenLayer!
    
    let object: UIView
    let key: String
    
    var mapper: ((value: CGFloat) -> (AnyObject))?
    
    var timingFunction: CAMediaTimingFunction {
        set {
            layer.timingFunction = newValue
        }
        get {
            return layer.timingFunction
        }
    }
    
    init (object: UIView, key: String, from: CGFloat, to: CGFloat, duration: NSTimeInterval) {
        self.object = object
        self.key = key
        
        layer = {
            let layer = TweenLayer()
            layer.from = from
            layer.to = to
            layer.tweenDuration = duration
            layer.tween = self
            object.layer.addSublayer(layer)
            
            return layer
            }()
    }
    
    func start() {
        layer.startAnimation()
    }
}

extension Tween: TweenLayerDelegate {
    func tweenLayer(layer: TweenLayer, didSetAnimatableProperty to: CGFloat) {
        if let mapper = mapper {
            object.setValue(mapper(value: to), forKey: key)
        } else {
            object.setValue(to, forKey: key)
        }
    }
    
    func tweenLayerDidStopAnimation(layer: TweenLayer) {
        layer.removeFromSuperlayer()
    }
}

protocol TweenLayerDelegate: class {
    func tweenLayer(layer: TweenLayer, didSetAnimatableProperty to: CGFloat) -> Void
    func tweenLayerDidStopAnimation(layer: TweenLayer) -> Void
}

class TweenLayer: CALayer {
    @NSManaged private var animatableProperty: CGFloat
    var tween: TweenLayerDelegate?
    
    var from: CGFloat = 0
    var to: CGFloat = 0
    var tweenDuration: NSTimeInterval = 0
    var timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
    var delay: NSTimeInterval = 0
    
    override class func needsDisplayForKey(event: String) -> Bool {
        return event == "animatableProperty" ? true : super.needsDisplayForKey(event)
    }
    
    override func actionForKey(event: String) -> CAAction? {
        if event != "animatableProperty" {
            return super.actionForKey(event)
        }
        
        let animation = CABasicAnimation(keyPath: event)
        animation.timingFunction = timingFunction
        animation.fromValue = from
        animation.toValue = to
        animation.duration = tweenDuration
        animation.beginTime = CACurrentMediaTime() + delay
        animation.delegate = self
        
        return animation;
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        tween?.tweenLayerDidStopAnimation(self)
    }
    
    override func display() {
        if let value = presentationLayer()?.animatableProperty {
            tween?.tweenLayer(self, didSetAnimatableProperty: value)
        }
    }
    
    func startAnimation() {
        animatableProperty = to
    }
}
