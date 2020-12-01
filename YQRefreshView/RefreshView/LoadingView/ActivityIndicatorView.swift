//
//  ActivityIndicatorView.swift
//  SDK
//
//  Created by DJ on 2020/5/28.
//  Copyright © 2020 Swift. All rights reserved.
//

import UIKit

enum Type: Int {
    case BallPulse
    case BallClipRotatePulse
}

class ActivityIndicatorView: UIView {
    var _animationLayer: CALayer?
    var _animating: Bool?
    
    
    var type: Type?
    var contentColor: UIColor?
    var contentSize: CGSize?
    
    
    convenience init(type: Type, contentColor: UIColor, contentSize: CGSize) {
        self.init()

        self.type = type
        self.contentColor = contentColor
        self.contentSize = contentSize
        
        self.commonInit()
        
    }

    func commonInit() {
        _animationLayer = CALayer.init()
        _animationLayer!.frame = self.layer.bounds
        self.layer.addSublayer(_animationLayer!)
        self.setContentHuggingPriority(.required, for: .horizontal)
        self.setContentHuggingPriority(.required, for: .vertical)
    }
    

    
    func setupAnimation() {
        _animationLayer!.sublayers = nil
        let animation = self.activityIndicatorAnimationForAnimationType(type: self.type!)
        animation.setupAnimation(layer: _animationLayer!, contentColor: self.contentColor!, contentSize: self.contentSize!)
            _animationLayer?.speed = 0.0
    }
    
    
    func activityIndicatorAnimationForAnimationType(type: Type) -> BaseAnimation {
        switch type {
        case .BallPulse:
            return BallPulseAnimation.init()
        case .BallClipRotatePulse:
            return BallClipRotatePulseAnimation.init()
        }
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _animationLayer!.frame = self.bounds
        if (_animating == true) {
            self.stopAnimation()
        }
        self.setupAnimation()
        if (_animating == false) {
            self.startAnimation()
        }
    }
    
    func startAnimation() {
        if (_animationLayer!.sublayers == nil) {
            self.setupAnimation()
        }
        _animationLayer?.speed = 1.0
        _animating = true
    }
    
    func stopAnimation() {
        _animationLayer?.speed = 0.0
        _animating = false
    }

}
