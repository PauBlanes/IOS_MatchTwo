//
//  ImageButtton.swift
//  Memory
//
//  Created by Pau Blanes on 12/3/19.
//  Copyright © 2019 Pau Blanes. All rights reserved.
//

import SpriteKit

protocol ImageButtonDelegate: class {
    func onTap(sender: ImageButton)
}

class ImageButton: SKSpriteNode {
    weak var delegate: ImageButtonDelegate?
    
    var scaleOnTap = true
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if scaleOnTap {
            let action = SKAction.scale(by: 0.9, duration: 0.1)
            run(action)
        }        
        /*if let highlightColor = highlightColor {
            originalColor = fillColor
            fillColor = highlightColor
        }*/
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if scaleOnTap {
            let action = SKAction.scale(by: 1.0/0.9, duration: 0.1)
            run(action)
        }
        
        /*if let _ = highlightColor {
            fillColor = originalColor
        }*/
        if let touch = touches.first, let parent = parent {
            
            if frame.contains(touch.location(in: parent)) {
                if let delegate = delegate {
                    delegate.onTap(sender: self)
                }
            }
            
        }
    }
}
