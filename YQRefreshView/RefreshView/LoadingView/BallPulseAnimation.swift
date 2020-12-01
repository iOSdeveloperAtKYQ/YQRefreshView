//
//  BallPulseAnimation.swift
//  SDK
//
//  Created by Ata on 2020/10/26.
//  Copyright © 2020 Swift. All rights reserved.
//

import UIKit

class BallPulseAnimation: BaseAnimation {
    
    override func setupAnimation(layer: CALayer, contentColor: UIColor, contentSize: CGSize) {
        let circlePadding: CGFloat = 5.0
        let circleSize: CGFloat = (contentSize.width - 2.0 * circlePadding) / 3.0
        let x = (layer.bounds.size.width - contentSize.width) / 2.0
        let y = (layer.bounds.size.height - circleSize) / 2.0
        let duration = 0.75
        let timeBegins = [0.12, 0.24, 0.36]
        let timingFunction = CAMediaTimingFunction.init(controlPoints: 0.2, 0.68, 0.18, 1.08)
        
        let animation = self.createKeyframeAnimation(keyPath: "transform")
        animation.values = [NSValue.init(caTransform3D: CATransform3DMakeScale(1.0, 1.0, 1.0)), NSValue.init(caTransform3D: CATransform3DMakeScale(0.3, 0.3, 1.0)), NSValue.init(caTransform3D: CATransform3DMakeScale(1.0, 1.0, 1.0))]
        animation.keyTimes = [0, 0.3, 1.0]
        animation.timingFunctions = [timingFunction, timingFunction]
        animation.duration = duration
        animation.repeatCount = HUGE
        for i in 0 ..< 3 {
            let circle = CALayer.init()
            circle.frame = .init(x: x + CGFloat(i) * circleSize + CGFloat(i) * circlePadding, y: y, width: circleSize, height: circleSize)
            circle.backgroundColor = contentColor.cgColor
            circle.cornerRadius = circle.bounds.size.width / 2
            animation.beginTime = timeBegins[i]
            circle.add(animation, forKey: "animation")
            layer.addSublayer(circle)
        }
    }
    
}
