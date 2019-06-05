//
//  RankingsScene.swift
//  Memory
//
//  Created by Pau Blanes on 14/5/19.
//  Copyright © 2019 Pau Blanes. All rights reserved.
//

import SpriteKit
import GameplayKit

class RankingsScene: SKScene, ImageButtonDelegate {
    
    weak var sceneControllerDelegate: SceneControllerDelegate?
    
    private var backButton = ImageButton(imageNamed: "back_icon")
    
    let loadingLabel = SKLabelNode(fontNamed: "Verdana")
    
    override func didMove(to view: SKView) {
        
        //Background
        self.backgroundColor = UIColor(red: 1, green: 0.5, blue: 0.5, alpha: 1)
        
        //GO BACK
        backButton.position = CGPoint(x: view.frame.width * 0.1, y: view.frame.height*0.95)
        backButton.isUserInteractionEnabled = true
        backButton.delegate = self
        backButton.setScale(0.4)
        backButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(backButton)
        
        //Downloading.. text
        loadingLabel.fontSize = 22
        loadingLabel.text = "Downloading Rankings..."
        loadingLabel.position = CGPoint(x: frame.width/2,y: frame.height/2)
        loadingLabel.alpha = 0
        addChild(loadingLabel)
        let fadeInOutSequence = SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.75),
            SKAction.wait(forDuration: 1),
            SKAction.fadeOut(withDuration: 0.5)])
        loadingLabel.run(SKAction.repeatForever(fadeInOutSequence))
        
        //RANKINGS TITLE TEXT
        let rankingsTitle = SKLabelNode(fontNamed: "Verdana")
        rankingsTitle.fontSize = 48
        rankingsTitle.text = "RANKINGS"
        rankingsTitle.position = CGPoint(x: frame.width/2,y: frame.height*0.75)
        addChild(rankingsTitle)
        
        //Download rankings
        FirebaseManager.instance.getTop10Scores(completionHadler: showRankings)
    }
    
    func showRankings(rankings: [(name: String, score: Int)]) {
        
        var labelY = frame.height*0.65
        let horizontalSeparation:CGFloat = 50
        
        var index = 1
        
        loadingLabel.removeFromParent()
        
        for persona in rankings {
            let nameLabel = SKLabelNode(fontNamed: "Verdana")
            nameLabel.fontSize = 22
            nameLabel.text = "\(index). \(persona.name): \(persona.score) points"
            nameLabel.position = CGPoint(
                x: frame.width/2,
                y: labelY)
            
            addChild(nameLabel)
            
            labelY = nameLabel.position.y - nameLabel.frame.height - horizontalSeparation
            index += 1
        }
    }
    
    //Input
    func onTap(sender: ImageButton) {
        if sender == backButton {
            sceneControllerDelegate?.goToMenu(sender: self)
        }
    }
}
