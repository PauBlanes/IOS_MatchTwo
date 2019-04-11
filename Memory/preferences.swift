//
//  preferences.swift
//  Memory
//
//  Created by Pau Blanes on 29/3/19.
//  Copyright © 2019 Pau Blanes. All rights reserved.
//

import Foundation

class Preferences {
    
    private static let k_SOUND_ON = "SOUND_ON"
    private static let k_DIFFICULTY = "K_DIFF"
    
    static func getDifficulty() -> Int {
        if let _ = UserDefaults.standard.object(forKey: k_DIFFICULTY){ //Existe
            return UserDefaults.standard.integer(forKey: k_DIFFICULTY)
        }
        setDifficulty(value: 0)
        return 0
    }
    static func setDifficulty(value: Int) {
        UserDefaults.standard.set(value, forKey: k_DIFFICULTY)
    }
    
    static func isSoundOn() -> Bool {
        
        if let _ = UserDefaults.standard.object(forKey: k_SOUND_ON){ //existe ?
            //hay diferentes niveles de user defaults
            let soundOn = UserDefaults.standard.bool(forKey: k_SOUND_ON) //si existe y tiene valor true, yes, 1 devuelve true. Si no existe devuelve false
            return soundOn
        }
        return true //si no existe devolvemos true, para que al inicio sea true
        
    }
    static func toggleSound() {
        let soundOn = isSoundOn()
        UserDefaults.standard.set(!soundOn, forKey: k_SOUND_ON) //si no existe creará a key
    }
}
