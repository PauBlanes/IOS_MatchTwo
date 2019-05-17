//
//  AudioController.swift
//  Memory
//
//  Created by Pau Blanes on 11/4/19.
//  Copyright © 2019 Pau Blanes. All rights reserved.
//

import AVFoundation

class AudioController {
    
    let song = AVPlayer(url: Bundle.main.url(forResource: "awesomeness.wav", withExtension: nil)!)
    var volume:Float = 0
    
    private static let sharedAudioController = AudioController()
    static var shared: AudioController {
        return sharedAudioController
    }
    
    func play() {        
        song.play()
    }
    func pause() {
        song.pause()
    }
    func setVolume() {
        if Preferences.isSoundOn() {
            self.volume = 1
        }
        else {
            self.volume = 0
        }
        song.volume = self.volume
    }
}
