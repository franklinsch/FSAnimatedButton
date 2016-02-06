//
//  StrokeAnimator.swift
//  DrawTextAnimationDemo
//
//  Created by Franklin Schrans on 30/08/2015.
//  Copyright (c) 2015 Franklin Schrans. All rights reserved.
//

import Foundation
import UIKit

func performStrokeAnimation(text text: String, font: CTFont, characterSpacing: CGFloat = 20.0, wordSpacing: CGFloat = 40.0, duration: CFTimeInterval = 1.0, borderWidth: CGFloat = 1.0, borderColor: CGColor = UIColor.blackColor().CGColor, inView view: UIView) {
    let textGroups = text.characters.split { $0 == " "}.map { String($0) }
    var groupLayers: [CALayer] = []
    
    for textGroup in textGroups {
        groupLayers.append(getGroupLayer(textGroup, font: font, borderColor: borderColor, borderWidth: borderWidth, characterSpacing: characterSpacing))
    }
    
    let textView = createViewFromLayers(groupLayers, wordSpacing: wordSpacing)
    
    textView.frame.origin.x = (view.frame.width - textView.frame.size.width) / 2
    textView.frame.origin.y = (view.frame.height - textView.frame.size.height) / 2
    
    view.addSubview(textView)
    
    let animation = CABasicAnimation(keyPath: "strokeEnd")
    animation.duration = duration
    animation.fromValue = 0
    animation.toValue = 1
    
    animateSublayers(textView.layer, animation: animation)
}

private func getGroupLayer(textGroup: String, font: CTFont, borderColor: CGColor, borderWidth: CGFloat, characterSpacing: CGFloat) -> CALayer {
    var unichars = [UniChar](textGroup.utf16)
    var glyphs = [CGGlyph](count: unichars.count, repeatedValue: 0)
    let gotGlyphs = CTFontGetGlyphsForCharacters(font, &unichars, &glyphs, unichars.count)
    var layers: [CALayer] = []
    if gotGlyphs {
        for i in 0..<glyphs.count {
            let cgpath = CTFontCreatePathForGlyph(font, glyphs[i], nil)
            
            let layer = CAShapeLayer()
            layer.path = cgpath
            layer.bounds = CGPathGetBoundingBox(cgpath)
            layer.geometryFlipped = true
            layer.strokeColor = borderColor
            layer.fillColor = UIColor.clearColor().CGColor
            layer.lineWidth = borderWidth
            layers.append(layer)
        }
    }
    
    let groupLayer = CAShapeLayer()
    
    let letterHeight = getLetterHeight(font: font)
    
    for i in 0..<layers.count {
        let offset = i == 0 ? 0 : CGRectGetMaxX(layers[i-1].frame) + characterSpacing
        let yPos = letterHeight - layers[i].bounds.height
        layers[i].frame.origin = CGPoint(x: offset, y: yPos)
        groupLayer.addSublayer(layers[i])
    }
    groupLayer.bounds = CGRectMake(layers.first!.frame.origin.x, layers.first!.frame.origin.y, CGRectGetMaxX(layers.last!.frame), layers.first!.frame.size.height)
    
    groupLayer.frame.origin = CGPoint(x: 0, y: 0)
    
    return groupLayer
}

private func createViewFromLayers(layers: [CALayer], wordSpacing: CGFloat) -> UIView {
    let textView = UIView()
    
    let digitHeight = layers.last!.frame.size.height
    
    for i in 0..<layers.count {
        let xPos = i == 0 ? 0 : CGRectGetMaxX(layers[i-1].frame) + wordSpacing
        layers[i].frame.origin.x = xPos
        layers[i].frame.origin.y = (digitHeight - layers[i].frame.height) / 2
        textView.layer.addSublayer(layers[i])
    }
    
    textView.frame = CGRectMake(0, 0, CGRectGetMaxX(layers.last!.frame), digitHeight)
    
    return textView
    
}

private func animateSublayers(layer: CALayer, animation: CAAnimation) {
    let sublayers = layer.sublayers!
    for sublayer in sublayers {
        if sublayer.sublayers != nil {
            animateSublayers(sublayer, animation: animation)
        } else {
            sublayer.addAnimation(animation, forKey: "textAppear")
        }
    }
}

private func getLetterHeight(font font: CTFont) -> CGFloat {
    var unichars = [UniChar]("l".utf16)
    var glyphs = [CGGlyph](count: unichars.count, repeatedValue: 0)
    _ = CTFontGetGlyphsForCharacters(font, &unichars, &glyphs, unichars.count)
    let cgpath = CTFontCreatePathForGlyph(font, glyphs[0], nil)
    
    return CGPathGetBoundingBox(cgpath).height
}