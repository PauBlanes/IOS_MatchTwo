//
//  preferences.swift
//  Memory
//
//  Created by Pau Blanes on 29/3/19.
//  Copyright © 2019 Pau Blanes. All rights reserved.
//

import Foundation

class Preferences {
    
    let k_SOUND_ON = "SOUND_ON"
    
    func isSoundOn() -> Bool {
        
        if let _ = UserDefaults.standard.object(forKey: k_SOUND_ON){ //existe ?
            //hay diferentes niveles de user defaults
            let soundOn = UserDefaults.standard.bool(forKey: k_SOUND_ON) //si existe y tiene valor true, yes, 1 devuelve true. Si no existe devuelve false
            return soundOn
        }
        return true //si no existe devolvemos true, para que al inicio sea true
        
    }
    func toggleSound() {
        let soundOn = isSoundOn()
        UserDefaults.standard.set(!soundOn, forKey: k_SOUND_ON) //si no existe creará a key
    }
}
