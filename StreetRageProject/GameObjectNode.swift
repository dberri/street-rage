//
//  GameObjectNode.swift
//  StreetRageProject
//
//  Created by David Willian Berri on 7/19/16.
//  Copyright © 2016 David Willian Berri. All rights reserved.
//

import SpriteKit

struct CollisionCategoryBitMask {
    static let Player: UInt32 = 0x00
    static let Vehicles: UInt32 = 0x01
}

enum PlayerType: Int {
    case Normal = 0
}


class GameObjectNode: SKNode {
    
    func collisionWithPlayer(player: SKNode) -> Bool {
        return false
    }
    
    func checkNodeRemoval(playerY: CGFloat) {
        if playerY > self.position.y + 300.0 {
            self.removeFromParent()
        }
    }
}

class VehicleNode: GameObjectNode {
    
    var vehicleType : VehicleType!
    //var starSound = SKAction.playSoundFileNamed("StarPing.wav", waitForCompletion: false)
    
    override func collisionWithPlayer(player: SKNode) -> Bool {
        
        self.removeFromParent()
        // Boost the player up
        //player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: 400.0)
        
//        // remove the star
//        runAction(starSound, completion: {
//            self.removeFromParent()
//        })
        
        //GameState.sharedInstance.score += (starType == .Normal ? 20 : 100)
        //GameState.sharedInstance.stars += (starType == .Normal ? 1 : 5)
        
        // the hud needs updating to show the new stars and score
        return true
    }
}