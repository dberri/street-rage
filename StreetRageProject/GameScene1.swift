//
//  GameScene.swift
//  StreetRageProject
//
//  Created by David Willian Berri on 7/13/16.
//  Copyright (c) 2016 David Willian Berri. All rights reserved.
//

import SpriteKit
import GameplayKit

enum Properties1 : Int {
    case Left, Center, Right
    
    var xRelativePosition : CGFloat {
        switch self {
        case .Left:
            return CGFloat(6.25)
        case .Center:
            return CGFloat(2)
        case .Right:
            return CGFloat(1.2)
        }
    }
}

enum VehicleType: Int {
    case Normal = 0
    case Cop
    case TheLaneChanger
}

class GameScene1: SKScene, SKPhysicsContactDelegate {
    
    var street : SKSpriteNode!
    var player : SKSpriteNode!
    var vehicles = [SKSpriteNode]()
    
    var hudNode : SKNode!
    
    let playerCategoryName = "player"
    let vehicleCategoryName = "vehicle"
    let streetCategoryName = "street"
    
    let playerCategory : UInt32 = 0x1 << 0
    let vehicleCategory : UInt32 = 0x1 << 1
    
    var playerRelativePosition = Properties.Right.xRelativePosition
    var possibleXPositions : [CGFloat]!
    
    let background1 = SKSpriteNode(imageNamed: "asphalt")
    let background2 = SKSpriteNode(imageNamed: "asphalt")
    
    var newXPosition : CGFloat!
    let moveDuration = 0.3
    var moveAction : SKAction!
    let rotationAngle : CGFloat = 0.5
    
    var gameOver = false
    
    var lblScore : SKLabelNode!
    var lblHighScore : SKLabelNode!
    
    var pausedNode : SKNode!
    var pauseButton : SKSpriteNode!
    
    override func didMoveToView(view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        // Adding the swipe reconizers
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipedRight))
        swipeRight.direction = .Right
        view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipedLeft))
        swipeLeft.direction = .Left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipedUp))
        swipeUp.direction = .Up
        view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipedDown))
        swipeDown.direction = .Down
        view.addGestureRecognizer(swipeDown)
        
        // add music here
        
        background1.size = self.frame.size
        background2.size = self.frame.size
        
        createStreet()
        createPlayer()
        initCars()
        
        hudNode = createHUD()
        addChild(hudNode)
        
        self.physicsWorld.gravity = CGVectorMake(0,0)
        
        possibleXPositions = [(self.frame.size.width / Properties.Left.xRelativePosition), (self.frame.size.width / Properties.Center.xRelativePosition), (self.frame.size.width / Properties.Right.xRelativePosition)]
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
    }
    
    func createStreet() {
        background1.anchorPoint = CGPointZero
        background1.position = CGPointZero
        background1.zPosition = 0
        self.addChild(background1)
        
        background2.anchorPoint = CGPointZero
        background2.position = CGPointMake(0, background2.size.height - 1)
        background2.zPosition = 0
        self.addChild(background2)
    }
    
    func createPlayer() {
        
        let size = CGSize(width: self.frame.size.width / 4, height: self.frame.size.height / 4)
        let playerTexture = SKTexture(imageNamed: "car")
        player = SKSpriteNode(texture: playerTexture)
        player.name = playerCategoryName
        player.size = size
        player.position = CGPointMake((self.frame.size.width / playerRelativePosition), player.frame.size.height / 2)
        self.addChild(player)
        
        player.physicsBody = SKPhysicsBody(texture: playerTexture, size: player.size)
        //player.physicsBody?.dynamic = false
        player.physicsBody?.usesPreciseCollisionDetection = true
        player.physicsBody?.restitution = 0.0
        player.physicsBody?.friction = 0.0
        player.physicsBody?.angularDamping = 0.0
        player.physicsBody?.linearDamping = 0.0
        
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.collisionBitMask = vehicleCategory
        player.physicsBody?.contactTestBitMask = vehicleCategory
        
    }
    
    func createVehicles() {
        
        let nextQty = GKRandomDistribution(lowestValue: 0, highestValue: 2).nextInt()
        let rand = GKRandomDistribution(lowestValue: 150, highestValue: 300).nextInt()
        let speed = CGFloat(rand)
        
        var lastXposition = possibleXPositions[0]
        
        for qty in 0..<nextQty {
        
            let enemyVehicle = EnemyVehicle()
            var vehicle = SKSpriteNode()
            
            possibleXPositions = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(possibleXPositions) as! [CGFloat]
            var xPosition = possibleXPositions[0]
            
            while xPosition == lastXposition {
                possibleXPositions = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(possibleXPositions) as! [CGFloat]
                xPosition = possibleXPositions[0]
            }
            
            vehicle = enemyVehicle.configureVehicleOfType(.Normal, atXPosition: xPosition, speed: speed, frame: self.frame)
            
            if qty == 1 {
                vehicle.position.y = vehicles.last!.position.y - 50
                
            }
            
            self.addChild(vehicle)
            vehicles.append(vehicle)
            
            lastXposition = xPosition
        }
    }
    
    func initCars() {
        
        let create = SKAction.runBlock { [unowned self] in
            self.createVehicles()
        }
        
        let wait = SKAction.waitForDuration(2)
        let sequence = SKAction.sequence([create, wait])
        let repeatForever = SKAction.repeatActionForever(sequence)
        
        runAction(repeatForever)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        player.physicsBody?.dynamic = false
        
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == playerCategory && secondBody.categoryBitMask == vehicleCategory {
            
            let name = secondBody.node?.name
            for node in vehicles {
                if node.name == name {
                    node.removeFromParent()
                    
                    if let index = vehicles.indexOf(node) {
                        vehicles.removeAtIndex(index)
                        
                    }
                }
            }
            
            //let gameOverScene = GameOverScene()
            //self.view?.presentScene(gameOverScene)
        }
        player.physicsBody?.dynamic = true
    }
    
    func createHUD() -> SKNode {
        
        hudNode = SKNode()
        
        lblScore = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblScore.fontSize = 30
        lblScore.fontColor = SKColor.whiteColor()
        lblScore.position = CGPoint(x: 30, y: self.size.height - 40)
        lblScore.horizontalAlignmentMode = .Right
        lblScore.text = "0"
        lblScore.zPosition = 5
        hudNode.addChild(lblScore)
        
        pausedNode = SKNode()
        pausedNode.name = "pauseButton"
        pauseButton = SKSpriteNode(imageNamed: "pauseButton")
        pauseButton.size = CGSize(width: 30, height: 35)
        pauseButton.position = CGPoint(x: self.frame.size.width - pauseButton.frame.width, y: self.size.height - 30)
        pauseButton.userInteractionEnabled = true
        pauseButton.zPosition = 5
        pausedNode.addChild(pauseButton)
        hudNode.addChild(pausedNode)
        
        return hudNode
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let touch = touches.first
        let touchLocation = touch!.locationInNode(self)
        let nodes = nodesAtPoint(touchLocation)
        
        for node in nodes {
            if node.name == "pauseButton" {
                print("pause")
            }
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        
        if gameOver {
            return
        }
        
        background1.position = CGPoint(x: background1.position.x, y: background1.position.y - 10)
        background2.position = CGPoint(x: background2.position.x, y: background2.position.y - 10)
        
        if (background1.position.y < -background1.size.height) {
            background1.position.y = background2.position.y + background2.size.height
            
        } else if (background2.position.y < -background2.size.height) {
            background2.position.y = background1.position.y + background1.size.height
            
        }
        
        for node in vehicles {
            if node.position.y <= -frame.height {
                node.removeFromParent()
                
                if let index = vehicles.indexOf(node) {
                    vehicles.removeAtIndex(index)
                }
            }
        }
        print(player.physicsBody!.velocity.dy)
    }
    
    func swipedRight(sender: UISwipeGestureRecognizer) {
        
        switch playerRelativePosition {
        case Properties.Left.xRelativePosition:
            playerRelativePosition = Properties.Center.xRelativePosition
            newXPosition = CGFloat(self.frame.size.width / playerRelativePosition)
            moveAction = SKAction.moveToX(newXPosition, duration: moveDuration)
            player.runAction(rotateRight())
            return player.runAction(moveAction)
            
        case Properties.Center.xRelativePosition:
            playerRelativePosition = Properties.Right.xRelativePosition
            newXPosition = CGFloat(self.frame.size.width / playerRelativePosition)
            moveAction = SKAction.moveToX(newXPosition, duration: moveDuration)
            player.runAction(rotateRight())
            return player.runAction(moveAction)
            
        default:
            return newXPosition = player.position.x
        }
        
    }
    
    func swipedLeft(sender: UISwipeGestureRecognizer) {
        
        switch playerRelativePosition {
        case Properties.Right.xRelativePosition:
            playerRelativePosition = Properties.Center.xRelativePosition
            newXPosition = CGFloat(self.frame.size.width / playerRelativePosition)
            moveAction = SKAction.moveToX(newXPosition, duration: moveDuration)
            player.runAction(rotateLeft())
            return player.runAction(moveAction)
            
        case Properties.Center.xRelativePosition:
            player.runAction(rotateLeft())
            playerRelativePosition = Properties.Left.xRelativePosition
            newXPosition = CGFloat(self.frame.size.width / playerRelativePosition)
            moveAction = SKAction.moveToX(newXPosition, duration: moveDuration)
            player.runAction(rotateLeft())
            return player.runAction(moveAction)
            
        default:
            return newXPosition = player.position.x
        }
    }
    
    func swipedUp(sender: UISwipeGestureRecognizer) {
        if player.physicsBody!.velocity.dy == 0 {
            player.physicsBody?.velocity.dy = 50
        }
        
    }
    
    func swipedDown(sender: UISwipeGestureRecognizer) {
        let goBack = SKAction.moveToY(player.frame.size.height / 2, duration: 1)
        player.physicsBody?.velocity.dy = 0.0
        player.runAction(goBack)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func rotateLeft() -> SKAction {
        
        let value = rotationAngle
        let rotateLeft = SKAction.rotateToAngle(value, duration: 0.1)
        let rotateBack = SKAction.rotateToAngle(0, duration: 0.2)
        let sequence = SKAction.sequence([rotateLeft, rotateBack])
        
        return sequence
        
    }
    
    func rotateRight() -> SKAction {
        
        let value = rotationAngle
        let rotateRight = SKAction.rotateToAngle(-value, duration: 0.1)
        let rotateBack = SKAction.rotateToAngle(0, duration: 0.2)
        let sequence = SKAction.sequence([rotateRight, rotateBack])
        
        return sequence
    }
    
    
}
