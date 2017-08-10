//
//  EnemyVehicle.swift
//  StreetRageProject
//
//  Created by David Willian Berri on 7/20/16.
//  Copyright © 2016 David Willian Berri. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

enum xPossiblePosition : CGFloat {
    
    case Left = 6.25 // vehicles on the left lane should be faster than others
    case Center = 2
    case Right = 1.2
    
}

public class EnemyVehicle: SKNode {
    
    var vehicleNode: SKSpriteNode!
    var vehicleTexture: SKTexture!
    
    let vehicleCategoryName = "vehicle"

    let playerCategory : UInt32 = 0x1 << 0
    let vehicleCategory : UInt32 = 0x1 << 1
    
    var isHit = false
    var isLaneChanger = false
    
    func configureVehicleOfType(type: VehicleType, atXPosition: CGFloat, speed: CGFloat, frame: CGRect) -> SKSpriteNode {
        
        let size = CGSize(width: frame.size.width / 4, height: frame.size.height / 4)
        
        if type == .Normal {
            
            vehicleTexture = SKTexture(imageNamed: "car")
            
        } else if type == .Cop {
            
            // load cop texture and so on
            vehicleTexture = SKTexture(imageNamed: "copCar")
            
        } else if type == .TheLaneChanger {
            
            // besides texture, also adds a property
            isLaneChanger = true
            
        }
        
        vehicleNode = SKSpriteNode(texture: vehicleTexture)
        
        let rand = GKRandomDistribution(lowestValue: 0, highestValue: 100)
        let ranNum = rand.nextInt()
        vehicleNode.name = String(format: "vehicleCategoryName%d", ranNum)
        
        vehicleNode.size = size
        vehicleNode.zPosition = 1
        
        let yPosition = frame.height + vehicleNode.frame.height / 2
        let position = CGPoint(x: atXPosition, y: yPosition)
        vehicleNode.position = position
        
        vehicleNode.physicsBody = SKPhysicsBody(texture: vehicleTexture, size: vehicleNode.size)
        vehicleNode.physicsBody?.usesPreciseCollisionDetection = true
        
        vehicleNode.physicsBody?.restitution = 0.0
        vehicleNode.physicsBody?.friction = 0.0
        vehicleNode.physicsBody?.angularDamping = 0.0
        vehicleNode.physicsBody?.linearDamping = 0.0
        
        vehicleNode.physicsBody?.categoryBitMask = vehicleCategory
        vehicleNode.physicsBody?.collisionBitMask = playerCategory
        vehicleNode.physicsBody?.contactTestBitMask = playerCategory
        
        vehicleNode.physicsBody?.velocity.dy = -speed
        
        if isLaneChanger {
            
            // do stuff here
            
        }
        
        return vehicleNode
    }
    
    func hit() {
        
        isHit = true
        explode()
    }
    
    func explode() {
        
    }
    
    

}
