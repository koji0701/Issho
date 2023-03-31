//
//  GradientHorizontalProgressBar.swift
//  Issho-New
//
//  Created by Koji Wong on 3/15/23.
//


import Foundation
import UIKit


class GradientHorizontalProgressBar: UIView {
    var color: UIColor = .systemPink {
        didSet { setNeedsDisplay() }
    }
    var gradientColor: UIColor = .white {
        didSet { setNeedsDisplay() }
    }
    
    

    var progress: CGFloat = 0 {
        didSet {
            if (progress > 1) {
                progress = 1
            }
            if (progress < 0) {
                progress = 0
            }
            setNeedsDisplay()
            
        }
    }

    private let progressLayer = CALayer()
    private let gradientLayer = CAGradientLayer()
    private let backgroundMask = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        //createRepeatingAnimation()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
        //createRepeatingAnimation()
    }

    private func setupLayers() {
        layer.addSublayer(gradientLayer)
        
        gradientLayer.mask = progressLayer
        gradientLayer.locations = [0.35, 0.5, 0.65]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
    }

    func createRepeatingAnimation() {
        
            gradientLayer.colors = [color.cgColor, gradientColor.cgColor, color.cgColor]

            let flowAnimation = CABasicAnimation(keyPath: "locations")
            flowAnimation.fromValue = [-0.3, -0.15, 0]
            flowAnimation.toValue = [1, 1.15, 1.3]

            flowAnimation.isRemovedOnCompletion = false
            flowAnimation.repeatCount = Float.infinity
            flowAnimation.duration = 2

            gradientLayer.add(flowAnimation, forKey: "flowAnimation")
        
        
    }
    
    func resetAnimation() {
        
        gradientLayer.removeAnimation(forKey: "flowAnimation")
        gradientLayer.colors = [color.cgColor, color.cgColor, color.cgColor]
    }
    
    
    func createSingleAnimation() {
        gradientLayer.colors = [color.cgColor, gradientColor.cgColor, color.cgColor]
        
        CATransaction.begin()
        
        CATransaction.setCompletionBlock({
            self.gradientLayer.colors = [self.color.cgColor, self.color.cgColor, self.color.cgColor]

        })
        let alreadyAnimating = (gradientLayer.animation(forKey: "flowAnimation") != nil)
        print(alreadyAnimating)
        if (gradientLayer.animation(forKey: "flowAnimation") == nil) {
            let flowAnimation = CABasicAnimation(keyPath: "locations")
            flowAnimation.fromValue = [-0.3, -0.15, 0]
            flowAnimation.toValue = [1, 1.15, 1.3]

            flowAnimation.isRemovedOnCompletion = false
            flowAnimation.repeatCount = 1
            flowAnimation.duration = 1
            gradientLayer.add(flowAnimation, forKey: "flowAnimation")
        }
        
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.2
        pulse.fromValue = 0.95
        pulse.toValue = 1.03
        pulse.autoreverses = true
        pulse.damping = 0.5
        layer.add(pulse, forKey: "pulse")
        
        CATransaction.commit()
        
        
    }
    
    func pulseAnimation() {
        CATransaction.begin()
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.2
        pulse.fromValue = 0.95
        pulse.toValue = 1.03
        pulse.autoreverses = true
        pulse.damping = 0.5
        layer.add(pulse, forKey: "pulse")
        CATransaction.commit()
        
    }
    

    override func draw(_ rect: CGRect) {
        
        
        backgroundMask.path = UIBezierPath(roundedRect: rect, cornerRadius: rect.height * 0.25).cgPath
        layer.mask = backgroundMask

        let progressRect = CGRect(origin: .zero, size: CGSize(width: rect.width * progress, height: rect.height))

        progressLayer.frame = progressRect
        progressLayer.backgroundColor = UIColor.black.cgColor

        gradientLayer.frame = rect
        gradientLayer.colors = [color.cgColor, color.cgColor, color.cgColor]
        gradientLayer.endPoint = CGPoint(x: progress, y: 0.5)
    }
}


