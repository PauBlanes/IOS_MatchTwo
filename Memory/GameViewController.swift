//
//  GameViewController.swift
//  Memory
//
//  Created by Pau Blanes on 12/3/19.
//  Copyright © 2019 Pau Blanes. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, MenuSceneDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as? SKView {
            // Load the SKScene from 'GameScene.sks'
            let scene = MenuScene(size: view.frame.size)
            scene.menuDelegate = self
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            view.presentScene(scene)
            
            //            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func goToAbout(sender: MenuScene) {
        
    }
    
    func goToGame(sender: MenuScene, grid:Grid) {
        if let view = self.view as? SKView {
            let scene = GameScene(size: view.frame.size)
            scene.grid.columns = grid.columns
            scene.grid.rows = grid.rows
            
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            view.presentScene(scene, transition: .crossFade(withDuration: 0.2))
        }
    }
    
    func goToSettings(sender: MenuScene) {
        if let view = self.view as? SKView {
            let scene = SettingsScene(size: view.frame.size)
            //scene.aboutDelegate = self
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            view.presentScene(scene, transition: .crossFade(withDuration: 0.2))
        }
    }
    
    
}
