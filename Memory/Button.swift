//
//  Button.swift
//  Memory
//
//  Created by Pau Blanes on 12/3/19.
//  Copyright © 2019 Pau Blanes. All rights reserved.
//

import SpriteKit

protocol ButtonDelegate: class {
    func onTap(sender: Button)
}

class Button: SKShapeNode {
    weak var delegate: ButtonDelegate?
    private var textNode = SKLabelNode()
    
    private var originalColor = SKColor.white
    var highlightColor: SKColor?
    
    func setText(text: String) {
        if textNode.parent == nil {
            addChild(textNode)
            textNode.fontName = "Verdana"
            textNode.fontSize = 16
            textNode.verticalAlignmentMode = .center
            textNode.position = CGPoint(x: frame.width / 2.0, y: frame.height / 2.0)
        }
        textNode.text = text
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //let action = SKAction.scale(by: 0.9, duration: 0.1)
        //run(action)
        self.strokeColor = .yellow
        /*if let highlightColor = highlightColor {
            originalColor = fillColor
            fillColor = highlightColor
        }*/
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        /*let action = SKAction.scale(by: 1.0/0.9, duration: 0.1)
        run(action)
        if let _ = highlightColor {
            fillColor = originalColor
        }*/
        self.strokeColor = .white
        if let touch = touches.first, let parent = parent {
            
            if frame.contains(touch.location(in: parent)) {
                if let delegate = delegate {
                    delegate.onTap(sender: self)
                }
            }
            
        }
    }
}
