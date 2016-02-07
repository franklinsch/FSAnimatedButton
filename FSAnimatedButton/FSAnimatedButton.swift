//
//  FSAnimatedButton.swift
//  FSAnimatedButton
//
//  Created by Franklin Schrans on 05/02/2016.
//  Copyright © 2016 Franklin Schrans. All rights reserved.
//

import UIKit

@IBDesignable
class FSAnimatedButton: UIButton {
    
    @IBInspectable var cornerRadius: Float = 2 {
        didSet {
            layer.cornerRadius = CGFloat(cornerRadius)
//            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    var borderAnimationFinished = false
    var isTouchUp = false
    
    var borderView = UIView()
    var topBorderLayer: CAShapeLayer!
    var bottomBorderLayer: CAShapeLayer!
    
    let borderStrokeAnimationDuration = 0.25
    let borderStrokeWidth = CGFloat(2.5)
    let selectedAlpha = CGFloat(0.85)

    let topStroke = (start: CGFloat(0.0), end: CGFloat(0.5))
    let bottomStroke = (start: CGFloat(0.5), end: CGFloat(1.0))
    
    private func setupBorders() {
        let borderPath = UIBezierPath(roundedRect: CGRectMake(0, 0, layer.frame.size.width, layer.frame.size.height), cornerRadius: CGFloat(self.cornerRadius)).CGPath
        topBorderLayer = CAShapeLayer(layer: layer)
        topBorderLayer.path = borderPath
        
        topBorderLayer.fillColor = UIColor.clearColor().CGColor
        topBorderLayer.strokeColor = self.backgroundColor?.darkerColor(0.2).CGColor
        topBorderLayer.lineWidth = borderStrokeWidth
        topBorderLayer.strokeEnd = 0
        layer.addSublayer(topBorderLayer)
        
        bottomBorderLayer = CAShapeLayer(layer: layer)
        bottomBorderLayer.path = borderPath
        
        bottomBorderLayer.fillColor = UIColor.clearColor().CGColor
        bottomBorderLayer.strokeColor = self.backgroundColor?.darkerColor(0.2).CGColor
        bottomBorderLayer.lineWidth = borderStrokeWidth
        bottomBorderLayer.strokeStart = 1.0
        bottomBorderLayer.strokeEnd = 1.0
        layer.addSublayer(bottomBorderLayer)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        setupBorders()
    }
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        isTouchUp = false
        performBorderDrawing()
        return super.beginTrackingWithTouch(touch, withEvent: event)
    }
    
    private func performBorderDrawing() {
        self.topBorderLayer.strokeStart = self.topStroke.start
        self.topBorderLayer.strokeEnd = self.topStroke.start
        self.bottomBorderLayer.strokeStart = self.bottomStroke.start
        self.bottomBorderLayer.strokeEnd = self.bottomStroke.end
        
        self.borderAnimationFinished = false
        
        UIView.animateWithDuration(borderStrokeAnimationDuration, delay: 0.0, options: .CurveEaseInOut , animations: {
            self.alpha = self.selectedAlpha
            self.topBorderLayer.strokeEnd = self.topStroke.end
            self.bottomBorderLayer.strokeStart = self.bottomStroke.start
            }, completion: { _ in
                self.borderAnimationFinished = true
                if self.isTouchUp {
                    self.performBorderUndrawing()
                }
        })
    }
    
    private func performBorderUndrawing() {
        self.topBorderLayer.strokeStart = self.topStroke.end
        self.topBorderLayer.strokeEnd = self.topStroke.end
        self.bottomBorderLayer.strokeStart = self.bottomStroke.end
        self.bottomBorderLayer.strokeEnd = self.bottomStroke.start
        
        UIView.animateWithDuration(borderStrokeAnimationDuration * 0.75, delay: 0.0, options: .TransitionNone, animations: {
            self.alpha = 1.0
            self.topBorderLayer.strokeEnd = self.topStroke.start
            self.bottomBorderLayer.strokeStart = self.bottomStroke.end
        }, completion: nil)
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        if self.borderAnimationFinished {
            performBorderUndrawing()
        }
        isTouchUp = true
    }
}
