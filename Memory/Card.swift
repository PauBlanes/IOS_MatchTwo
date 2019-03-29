//
//  Card.swift
//  Memory
//
//  Created by Pau Blanes on 21/3/19.
//  Copyright © 2019 Pau Blanes. All rights reserved.
//

import Foundation

enum CardState {
    case covered,uncovered,matched, turning
}

class Card {
    var id:Int = -1
    var pairId:Int = -1
    var state:CardState = CardState.covered    
}
