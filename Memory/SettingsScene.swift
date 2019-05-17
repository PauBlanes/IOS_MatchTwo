//
//  SettingsScene.swift
//  Memory
//
//  Created by Pau Blanes on 12/3/19.
//  Copyright © 2019 Pau Blanes. All rights reserved.
//

import SpriteKit
import GameplayKit

class SettingsScene: SKScene, ImageButtonDelegate {
    
    weak var sceneControllerDelegate: SceneControllerDelegate?
    
    private var backButton = ImageButton(imageNamed: "back_icon")
    private var muteButton = ImageButton(imageNamed: "volume_icon")
    private var signOutButton = ImageButton(imageNamed: "logout_icon")
    private var muted = false
    
    override func didMove(to view: SKView) {
        
        //Background
        self.backgroundColor = UIColor(red: 1, green: 0.5, blue: 0.5, alpha: 1)
        
        muteButton.position = CGPoint(x: view.frame.width/2, y: view.frame.height * 0.75)
        muteButton.isUserInteractionEnabled = true
        muteButton.delegate = self
        muteButton.scaleOnTap = false
        muteButton.setScale(0.8)
        muteButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(muteButton)
        
        //GO BACK
        backButton.position = CGPoint(x: view.frame.width * 0.1, y: view.frame.height*0.95)
        backButton.isUserInteractionEnabled = true
        backButton.delegate = self
        backButton.setScale(0.5)
        backButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(backButton)
        
        //SIGN OUT
        signOutButton.position = CGPoint(x: view.frame.width * 0.5, y: view.frame.height*0.5)
        signOutButton.isUserInteractionEnabled = true
        signOutButton.delegate = self
        signOutButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(signOutButton)
        
        muted = !Preferences.isSoundOn()
        if muted {
            muteButton.texture = SKTexture(imageNamed: "mute_icon")
            Preferences.setSound(to: false)
        }
        else {
            muteButton.texture = SKTexture(imageNamed: "volume_icon")
        }
    }
    
    func onTap(sender: ImageButton) {
        if sender == muteButton {
            toggleMuted()
        }
        else if sender == backButton {
            sceneControllerDelegate?.goToMenu(sender: self)
        }
        else if sender == signOutButton {
            FirebaseManager.instance.logOut()
        }
    }
    
    func toggleMuted() {
        muted = !muted
        
        if muted {
            muteButton.texture = SKTexture(imageNamed: "mute_icon")
        }
        else {
            muteButton.texture = SKTexture(imageNamed: "volume_icon")
        }
        
        Preferences.setSound(to: !muted)
    }
}
