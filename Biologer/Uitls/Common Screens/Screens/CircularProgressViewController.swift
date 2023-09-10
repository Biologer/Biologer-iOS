//
//  CircularProgressViewController.swift
//  Biologer
//
//  Created by Nikola Popovic on 12.7.21..
//

import UIKit

@IBDesignable class CircularProgressView: UIView {
    
    @IBInspectable var lineWidthRatio: CGFloat = 0.12
    @IBInspectable var basicColor: UIColor = UIColor.gray
    @IBInspectable var progressColor: UIColor = UIColor.biologerGreenColor
    @IBInspectable var startPoint: CGFloat = 0
    @IBInspectable var endPoint: CGFloat = 1
    
    public var isAnimating: Bool = false
    private var progressLayer = CAShapeLayer()
    private var backgroundLayer = CAShapeLayer()
    
    private let inAnimation: CAAnimation = {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = 1.0
        animation.timingFunction =  CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        return animation
    }()
    
    private let outAnimation: CAAnimation = {
        let animation = CABasicAnimation(keyPath: "strokeStart")
        animation.beginTime = 0.5
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        return animation
    }()
    
    private let rotationAnimation: CAAnimation = {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0.0
        animation.toValue = 2 * Double.pi
        animation.duration = 2.0
        animation.repeatCount = MAXFLOAT
        
        return animation
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - progressLayer.lineWidth / 2
        
        let arcPath = UIBezierPath(arcCenter: CGPoint.zero, radius: radius, startAngle: .pi/2, endAngle: .pi/2 + (2 * .pi), clockwise: true)
        
        progressLayer.position = center
        progressLayer.path = arcPath.cgPath
        backgroundLayer.position = center
        backgroundLayer.path = arcPath.cgPath
        progressLayer.strokeColor = progressColor.cgColor
        backgroundLayer.strokeColor = basicColor.cgColor
    }
    
    // MARK: - Instance methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: - Public methods
    
    public func setProgress(value: CGFloat) {
        progressLayer.strokeEnd = value
    }
    
    public func startInfinitAnimation() {
        progressLayer.strokeEnd = 1
        let strokeAnimationGroup = CAAnimationGroup()
        strokeAnimationGroup.duration = 1.0 + outAnimation.beginTime
        strokeAnimationGroup.repeatCount = Float(CGFloat.greatestFiniteMagnitude)
        strokeAnimationGroup.animations = [inAnimation, outAnimation]
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.add(strokeAnimationGroup, forKey: "strokeAnimation")
        progressLayer.add(rotationAnimation, forKey: "rotateAnimation")
        isAnimating = true
    }
    
    public func stopAnimation() {
        progressLayer.removeAllAnimations()
        progressLayer.strokeEnd = 0
        isAnimating = false
    }

    
    // MARK: - Private methods
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didBecomeActive),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willResignActive),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
    }
    
    @objc private func didBecomeActive() {
        startInfinitAnimation()
    }
    
    @objc private func willResignActive() {
        stopAnimation()
    }
    
    private func commonInit() {
        addObservers()
        let lineWidth = lineWidthRatio * frame.width
        let radius = min(bounds.width, bounds.height) / 2 - progressLayer.lineWidth / 2
        let circularPath = UIBezierPath(arcCenter: CGPoint.zero, radius: radius, startAngle: .pi/2, endAngle: .pi/2 + (2 * .pi), clockwise: true)
        circularPath.close()

        progressLayer.lineWidth = lineWidth
        backgroundLayer.lineWidth = lineWidth
        progressLayer.fillColor = nil
        backgroundLayer.fillColor = nil
        progressLayer.strokeEnd = 0
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(progressLayer)
    }
    
}

