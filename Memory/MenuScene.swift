//
//  MenuScene.swift
//  Memory
//
//  Created by Pau Blanes on 12/3/19.
//  Copyright © 2019 Pau Blanes. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol MenuSceneDelegate: class {
    func goToGame(sender: MenuScene)
    func goToAbout(sender: MenuScene)
    func goToSettings(sender: MenuScene)
}

class MenuScene: SKScene, ButtonDelegate, ImageButtonDelegate {
    
    weak var menuDelegate: MenuSceneDelegate?
    
    private var label : SKLabelNode = SKLabelNode(fontNamed: "Futura")
    private var difficultyLabel : SKLabelNode = SKLabelNode(fontNamed: "Verdana")
    
    //private var playButton = ImageButton(imageNamed: "play_icon-1")
    //private var prova:Button! //NO hacer esto
    private var settingsButton = ImageButton(imageNamed: "settings_icon")
    private var rankingsButton = ImageButton(imageNamed: "leaderboard_icon")
    
    private var leftArrowButton = ImageButton(imageNamed: "left_arrow")
    private var rightArrowButton = ImageButton(imageNamed: "right_arrow")
    private var difficultyButton = Button(rect: CGRect(x: 0, y: 0, width: 200, height: 200), cornerRadius: 10)
    private var difficultyIndex = 0
    
    /*private var gameButton = Button(rect: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight), cornerRadius: 10)*/
    
    
    override func didMove(to view: SKView) {
        
        //Background
        self.backgroundColor = UIColor(red: 1, green: 0.5, blue: 0.5, alpha: 1)
        
        //Set the butons
        /*playButton.position = CGPoint(x: view.frame.width/2, y: view.frame.height * 0.45)
        playButton.isUserInteractionEnabled = true
        playButton.delegate = self
        playButton.setScale(1.2)
        playButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(playButton)*/
        
        rankingsButton.position = CGPoint(x: view.frame.width/2, y: view.frame.height * 0.15)
        rankingsButton.isUserInteractionEnabled = true
        rankingsButton.delegate = self
        rankingsButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(rankingsButton)
        
        settingsButton.position = CGPoint(x: view.frame.width*0.1, y: view.frame.height * 0.90)
        settingsButton.isUserInteractionEnabled = true
        settingsButton.delegate = self
        settingsButton.setScale(0.5)
        settingsButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(settingsButton)
        
        //TRIAR DIFICULTAT
        difficultyButton.setText(text: "12 Diferent Pairs!")
        difficultyButton.fillColor = SKColor(red: 0.3, green: 0.4, blue: 0.5, alpha: 1.0)
        difficultyButton.isUserInteractionEnabled = true
        difficultyButton.delegate = self
        
        difficultyButton.position = CGPoint(x: (view.frame.width / 2.0) - (difficultyButton.frame.width / 2.0), y: view.frame.height * 0.30)
        addChild(difficultyButton)
        
        addChild(difficultyLabel)
        difficultyLabel.text = "EASY"
        difficultyLabel.fontSize = 22
        difficultyLabel.position = CGPoint(x: view.center.x, y: difficultyButton.position.y + difficultyButton.frame.height + 5)
        
        leftArrowButton.position = CGPoint(x: view.frame.width * 0.1, y: difficultyButton.position.y + difficultyButton.frame.height/2)
        leftArrowButton.isUserInteractionEnabled = true
        leftArrowButton.delegate = self
        leftArrowButton.setScale(0.5)
        leftArrowButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(leftArrowButton)
        rightArrowButton.position = CGPoint(x: view.frame.width * 0.9, y: difficultyButton.position.y + difficultyButton.frame.height/2)
        rightArrowButton.isUserInteractionEnabled = true
        rightArrowButton.delegate = self
        rightArrowButton.setScale(0.5)
        rightArrowButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(rightArrowButton)
        
        /*gameButton.setText(text: "Game")
        gameButton.fillColor = SKColor(red: 0.3, green: 0.4, blue: 0.5, alpha: 1.0)
        gameButton.isUserInteractionEnabled = true
        gameButton.delegate = self
        gameButton.position = CGPoint(x: (view.frame.width / 2.0) - (MenuScene.buttonWidth / 2.0), y: view.frame.height * 0.5)
        gameButton.highlightColor = .yellow
        gameButton.strokeColor = .red
        addChild(gameButton)*/
        
        //Title
        addChild(label)
        label.text = "MATCH TWO!"
        label.fontSize = 36
        label.position = CGPoint(x: view.center.x, y: view.frame.height * 0.75)
        label.alpha = 0.0
        label.run(SKAction.repeatForever(
            SKAction.sequence([
            SKAction.fadeIn(withDuration: 1.5),
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeOut(withDuration: 1)
                ])))
    }
    
    func onTap(sender: Button) {
        if sender == difficultyButton {
            menuDelegate?.goToGame(sender: self)
        }
    }
    func onTap(sender: ImageButton) {
        if sender == settingsButton {
            menuDelegate?.goToSettings(sender: self)
        }
        else if sender == rankingsButton {
            print("le han dado a rankings")
        }else if sender == leftArrowButton {
            difficultyIndex -= 1
            if difficultyIndex < 0 {
                difficultyIndex = 2
            }
            setDifficuty()
        }
        else if sender == rightArrowButton {
            difficultyIndex = (difficultyIndex + 1)%3
            setDifficuty()
        }
    }
    
    func setDifficuty () {
        if difficultyIndex == 0 {
            difficultyButton.setText(text: "12 Diferent Pairs!")
            difficultyLabel.text = "EASY"
        }
        else if difficultyIndex == 1 {
            difficultyButton.setText(text: "24 Diferent Pairs!")
            difficultyLabel.text = "MEDIUM"
        }
        else if difficultyIndex == 2 {
            difficultyButton.setText(text: "36 Diferent Pairs!")
            difficultyLabel.text = "HARD"
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}