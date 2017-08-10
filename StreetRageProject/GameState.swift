//
//  GameState.swift
//  StreetRageProject
//
//  Created by David Willian Berri on 7/18/16.
//  Copyright © 2016 David Willian Berri. All rights reserved.
//

import Foundation

class GameState {
    var score : Int
    var highScore : Int
    var coins : Int
    
    class var sharedInstance : GameState {
        struct Singleton {
            static let instance = GameState()
        }
        
        return Singleton.instance
    }
    
    init() {
        score = 0
        highScore = 0
        coins = 0
        
        // load game state
        let defaults = NSUserDefaults.standardUserDefaults()
        
        highScore = defaults.integerForKey("BestScore")
    }
    
    func saveState() {
        highScore = max(score, highScore)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(highScore, forKey: "BestScore")
        defaults.setInteger(coins, forKey: "Coins")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}