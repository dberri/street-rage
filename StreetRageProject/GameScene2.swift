//
//  GameScene.swift
//  StreetRageProject
//
//  Created by David Willian Berri on 7/13/16.
//  Copyright (c) 2016 David Willian Berri. All rights reserved.
//

import SpriteKit
import GameplayKit

enum Properties2 : Int {
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

class GameScene2: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Enums and properties
    enum EnemyType: Int {
        case Normal = 0
        case Cop
        case LaneChanger
        case WrongWay
        case Pickup
        
        static var name: String {
            
            let rand = GKRandomDistribution(lowestValue: 0, highestValue: 500)
            let ranNum = rand.nextInt()
            return String(format: "enemyN%d", ranNum)
        }
    }
    
    enum StreetLane {
        case Right
        case Center
        case Left
    }
    
    enum EnemyPattern: Int {
        case Single = 0
        case DoubleHorizontal
        case DoubleVertical
        case TripleUp
        case TripleDown
        case TripleVertical
    }
    
    enum ButtonNames: String {
        case Start = "start"
        case Restart = "difficulty"
        case Quit = "settings"
        case Coin = "coin"
        case Pause = "pause"
        case Resume = "resume"
    }
    
    var timeOfLastSpawn: CFTimeInterval = 0.0
    var timeToSpawn: CFTimeInterval = 3.0
    var vehicleSize: CGSize!
    var vehicles = [SKNode]()
    var street : SKSpriteNode!
    var player : SKSpriteNode!
    var hudNode : SKNode!
    var gameOver = false
    var score = 0
    var coins : Int!
    
    let kPlayerName = "player"
    let kPlayerFiredName = "playerFired"
    let kEnemyCategory: UInt32 = 0x1 << 0
    let kPlayerCategory: UInt32 = 0x1 << 1
    let kCoinCategory: UInt32 = 0x1 << 2
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    
    // CHECK THESE PROPERTIES
    
    var playerRelativePosition = Properties.Center.xRelativePosition
    var possibleXPositions : [CGFloat]!
    
    // SHOULD PROBABLY CHANGE HERE WHEN CHANGE DIFFICULTY
    
    let background1 = SKSpriteNode(imageNamed: "asphalt")
    let background2 = SKSpriteNode(imageNamed: "asphalt")
    
    // Stuff related to the player steering
    var newXPosition : CGFloat!
    let moveDuration = 0.3
    var moveAction : SKAction!
    let rotationAngle : CGFloat = 0.5
    
    var lblScore : SKLabelNode!
    var lblHighScore : SKLabelNode!
    
    var pausedNode : SKNode!
    var pauseButton : SKSpriteNode!
    var resumeButton : SKSpriteNode!
    var restartButton : SKSpriteNode!
    var quitButton : SKSpriteNode!
    
    
    // MARK: - Scene Setup and Content Creation
    override func didMoveToView(view: SKView) {
        
        coins = userDefaults.integerForKey("Coins")
        
        vehicleSize = CGSize(width: self.frame.size.width / 4, height: self.frame.size.height / 4)
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVectorMake(0,0)
        
        // Adding the swipe reconizers
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipedRight))
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipedLeft))
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipedUp))
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipedDown))
        
        swipeRight.direction = .Right
        swipeLeft.direction = .Left
        swipeUp.direction = .Up
        swipeDown.direction = .Down
        
        view.addGestureRecognizer(swipeRight)
        view.addGestureRecognizer(swipeLeft)
        view.addGestureRecognizer(swipeUp)
        view.addGestureRecognizer(swipeDown)
        
        background1.size = self.frame.size
        background2.size = self.frame.size
        
        createStreet()
        createPlayer()
        createHUD()
        
        possibleXPositions = [(self.frame.size.width / Properties.Left.xRelativePosition), (self.frame.size.width / Properties.Center.xRelativePosition), (self.frame.size.width / Properties.Right.xRelativePosition)]
    }
    
    // MARK: - Create entities
    
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
        player.name = kPlayerName
        player.size = size
        player.position = CGPointMake((self.frame.size.width / playerRelativePosition), player.frame.size.height / 2 + 20)
        self.addChild(player)
        
        player.physicsBody = SKPhysicsBody(texture: playerTexture, size: player.size)
        player.physicsBody?.usesPreciseCollisionDetection = true
        player.physicsBody?.restitution = 0.0
        player.physicsBody?.friction = 0.0
        player.physicsBody?.angularDamping = 0.0
        player.physicsBody?.linearDamping = 0.0
        
        player.physicsBody?.categoryBitMask = kPlayerCategory
        player.physicsBody?.collisionBitMask = kEnemyCategory
        player.physicsBody?.contactTestBitMask = kEnemyCategory
        
    }
    
    func makeEnemyOfType(enemyType: EnemyType, withSpeed speed: CGFloat) -> SKNode {
        
        var enemyTexture = SKTexture()
        
        switch enemyType {
        case .Normal, .LaneChanger, .WrongWay:
            enemyTexture = SKTexture(imageNamed: "car")
        case .Cop:
            enemyTexture = SKTexture(imageNamed: "copCar")
        case .Pickup:
            enemyTexture = SKTexture(imageNamed: "pickupCar")
        }
        
        let enemy = SKSpriteNode(texture: enemyTexture)
        enemy.name = EnemyType.name
        enemy.size = vehicleSize
        
        enemy.physicsBody = SKPhysicsBody(texture: enemyTexture, size: vehicleSize)
        enemy.physicsBody!.dynamic = true
        enemy.physicsBody!.categoryBitMask = kEnemyCategory
        enemy.physicsBody!.contactTestBitMask = kPlayerCategory
        enemy.physicsBody!.collisionBitMask = kPlayerCategory
        enemy.physicsBody!.velocity.dy = -speed
        
        vehicles.append(enemy)
        return enemy
    }
    
    func setupEnemies(ofPattern enemyPattern: EnemyPattern) {
        
        let enemyPositionY: CGFloat!
        
        let speed = CGFloat(GKRandomDistribution(lowestValue: 200, highestValue: 300).nextInt())
        
        var possibleTypes = [0, 1, 2, 3, 4]
        possibleTypes = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(possibleTypes) as! [Int]
        
        switch enemyPattern {
        case .Single:
            
            let enemy = makeEnemyOfType(EnemyType(rawValue: possibleTypes[0])!, withSpeed: speed)
            
            possibleXPositions = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(possibleXPositions) as! [CGFloat]
            enemyPositionY = self.frame.height + enemy.frame.height / 2
            enemy.position = CGPoint(x: possibleXPositions[0], y: enemyPositionY)
            
            addChild(enemy)
            vehicles.append(enemy)
            
        case .DoubleHorizontal:
            
            let enemyOne = makeEnemyOfType(EnemyType(rawValue: possibleTypes[0])!, withSpeed: speed)
            let enemyTwo = makeEnemyOfType(EnemyType(rawValue: possibleTypes[1])!, withSpeed: speed)
            
            possibleXPositions = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(possibleXPositions) as! [CGFloat]
            enemyPositionY = self.frame.height + enemyOne.frame.height / 2
            
            enemyOne.position = CGPoint(x: possibleXPositions[0], y: enemyPositionY)
            enemyTwo.position = CGPoint(x: possibleXPositions[1], y: enemyPositionY + 100)
            
            addChild(enemyOne)
            addChild(enemyTwo)
            
        case .DoubleVertical:
            
            let enemyOne = makeEnemyOfType(EnemyType(rawValue: possibleTypes[1])!, withSpeed: speed)
            let enemyTwo = makeEnemyOfType(EnemyType(rawValue: possibleTypes[0])!, withSpeed: speed)
            
            possibleXPositions = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(possibleXPositions) as! [CGFloat]
            enemyPositionY = self.frame.height + enemyOne.frame.height / 2
            
            enemyOne.position = CGPoint(x: possibleXPositions[0], y: enemyPositionY)
            enemyTwo.position = CGPoint(x: possibleXPositions[0], y: enemyPositionY + enemyOne.frame.height + 20)
            
            addChild(enemyOne)
            addChild(enemyTwo)
            
            
        case .TripleUp:
            
            let enemyOne = makeEnemyOfType(EnemyType(rawValue: possibleTypes[0])!, withSpeed: speed)
            let enemyTwo = makeEnemyOfType(EnemyType(rawValue: possibleTypes[1])!, withSpeed: speed)
            let enemyThree = makeEnemyOfType(EnemyType(rawValue: possibleTypes[2])!, withSpeed: speed)
            
            possibleXPositions = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(possibleXPositions) as! [CGFloat]
            enemyPositionY = self.frame.height + enemyOne.frame.height / 2
            
            enemyOne.position = CGPoint(x: possibleXPositions[0], y: enemyPositionY)
            enemyTwo.position = CGPoint(x: possibleXPositions[0], y: enemyPositionY + enemyOne.frame.height + 20)
            enemyThree.position = CGPoint(x: possibleXPositions[1], y: enemyPositionY + enemyOne.frame.height + 20)
            
            addChild(enemyOne)
            addChild(enemyTwo)
            addChild(enemyThree)
            
        case .TripleDown:
            
            let enemyOne = makeEnemyOfType(EnemyType(rawValue: possibleTypes[2])!, withSpeed: speed)
            let enemyTwo = makeEnemyOfType(EnemyType(rawValue: possibleTypes[1])!, withSpeed: speed)
            let enemyThree = makeEnemyOfType(EnemyType(rawValue: possibleTypes[0])!, withSpeed: speed)
            
            possibleXPositions = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(possibleXPositions) as! [CGFloat]
            enemyPositionY = self.frame.height + enemyOne.frame.height / 2
            
            enemyOne.position = CGPoint(x: possibleXPositions[1], y: enemyPositionY)
            enemyTwo.position = CGPoint(x: possibleXPositions[1], y: enemyPositionY + enemyOne.frame.height + 20)
            enemyThree.position = CGPoint(x: possibleXPositions[0], y: enemyPositionY + enemyOne.frame.height + 20)
            
            addChild(enemyOne)
            addChild(enemyTwo)
            addChild(enemyThree)
            
        case .TripleVertical:
            
            let enemyOne = makeEnemyOfType(EnemyType(rawValue: possibleTypes[0])!, withSpeed: speed)
            let enemyTwo = makeEnemyOfType(EnemyType(rawValue: possibleTypes[1])!, withSpeed: speed)
            let enemyThree = makeEnemyOfType(EnemyType(rawValue: possibleTypes[2])!, withSpeed: speed)
            
            possibleXPositions = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(possibleXPositions) as! [CGFloat]
            enemyPositionY = self.frame.height + enemyOne.frame.height / 2
            
            enemyOne.position = CGPoint(x: possibleXPositions[1], y: enemyPositionY)
            enemyTwo.position = CGPoint(x: possibleXPositions[1], y: enemyPositionY + enemyOne.frame.height + 20)
            enemyThree.position = CGPoint(x: possibleXPositions[0], y: enemyPositionY + enemyOne.frame.height * 2 + 20)
            
            addChild(enemyOne)
            addChild(enemyTwo)
            addChild(enemyThree)
            
            
            //            let myView : UIView = getView()
            //            switch myView {
            //            case _ where myView.frame.size.height < 50:
            
        }
        
    }
    
    func spawnEnemiesForUpdate(currentTime: CFTimeInterval) {
        
        if (currentTime - timeOfLastSpawn) < timeToSpawn {
            return
        }
        
        var possiblePatterns = [0, 1, 2, 3, 4]
        possiblePatterns = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(possiblePatterns) as! [Int]
        
        setupEnemies(ofPattern: EnemyPattern(rawValue: possiblePatterns[0])!)
        
        timeOfLastSpawn = currentTime
    }
    
    func createHUD() {
        hudNode = SKNode()
        
        lblScore = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblScore.fontSize = 30
        lblScore.fontColor = SKColor.whiteColor()
        lblScore.position = CGPoint(x: 100, y: self.size.height - 40)
        lblScore.horizontalAlignmentMode = .Right
        lblScore.text = "\(score)"
        lblScore.zPosition = 5
        hudNode.addChild(lblScore)
        
        pausedNode = SKNode()
        pausedNode.name = ButtonNames.Pause.rawValue
        pauseButton = SKSpriteNode(imageNamed: "pauseButton")
        pauseButton.name = ButtonNames.Pause.rawValue
        pauseButton.size = CGSize(width: 30, height: 35)
        pauseButton.position = CGPoint(x: self.frame.size.width - pauseButton.frame.width, y: self.size.height - 30)
        pauseButton.zPosition = 1
        pausedNode.addChild(pauseButton)
        hudNode.addChild(pausedNode)
        
        addChild(hudNode)
        
    }
    
    // MARK: - Update
    override func update(currentTime: NSTimeInterval) {
        if physicsWorld.speed == 1 {
            
            if gameOver {
                return
            }
            
            background1.position = CGPoint(x: background1.position.x, y: background1.position.y - 5)
            background2.position = CGPoint(x: background2.position.x, y: background2.position.y - 5)
            
            if (background1.position.y < -background1.size.height) {
                background1.position.y = background2.position.y + background2.size.height
                
            } else if (background2.position.y < -background2.size.height) {
                background2.position.y = background1.position.y + background1.size.height
                
            }
            
            for node in vehicles {
                
                if node.position.y <= -vehicleSize.height {
                    node.removeFromParent()
                    
                    if let index = vehicles.indexOf(node) {
                        vehicles.removeAtIndex(index)
                    }
                    
                    score += 100
                    lblScore.text = "\(score)"
                }
            }
            
            spawnEnemiesForUpdate(currentTime)
            
        } else {

            // Do not spawn more enemies
            
        }
    }
    
    // MARK: - Contact
    func didBeginContact(contact: SKPhysicsContact) {
        
        handleContact(contact)
    }
    
    func handleContact(contact: SKPhysicsContact) {
        
        if contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil {
            return
        }
        
        let nodeA = contact.bodyA.node!
        let nodeB = contact.bodyB.node!
        
        let nodeNames = [nodeA.name!, nodeB.name!]
        
        if nodeNames.contains(kPlayerName) && nodeNames.contains(EnemyType.name) {
            if nodeA.name == kPlayerName {
                
            } else {
                
            }
        }
        
         // OLD STUFF
        
        player.physicsBody?.dynamic = false
        
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == kPlayerCategory && secondBody.categoryBitMask == kEnemyCategory {
            
            let name = secondBody.node?.name
            for node in vehicles {
                if node.name == name {
                    node.removeFromParent()
                    
                    // Put different names in the vehicles
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
    
    // MARK: - Controls
    
    func pauseGame() {
        
        //        if let view = self.view {
        //            view.scene?.paused = true
        //        }
        
        let buttonSize = CGSize(width: frame.size.width / 1.4, height: frame.size.height / 10)
        let firstButtonYPosition = frame.height - 130
        let verticalSpacing: CGFloat =  buttonSize.height + 10
        
        physicsWorld.speed = 0
        
        let resumeTexture = SKTexture(imageNamed: "resumeButton")
        resumeButton = SKSpriteNode(texture: resumeTexture)
        resumeButton.position = pauseButton.position
        resumeButton.size = CGSize(width: 30, height: 35)
        resumeButton.name = ButtonNames.Resume.rawValue
        addChild(resumeButton)
        
        let restartTexture = SKTexture(imageNamed: "restartButton")
        restartButton = SKSpriteNode(texture: restartTexture)
        restartButton.position = CGPoint(x: 0, y: firstButtonYPosition - verticalSpacing)
        restartButton.size = buttonSize
        restartButton.name = ButtonNames.Restart.rawValue
        addChild(restartButton)
        
        let quitTexture = SKTexture(imageNamed: "quitButton")
        quitButton = SKSpriteNode(texture: quitTexture)
        quitButton.position = CGPoint(x: 0, y: firstButtonYPosition - verticalSpacing * 2)
        quitButton.size = buttonSize
        quitButton.name = ButtonNames.Quit.rawValue
        addChild(quitButton)
        
        pauseButton.hidden = true
        
        
        let finalXPosition = CGFloat(self.frame.width / 2)
        
        let slide = SKAction.moveToX(finalXPosition, duration: 0.2)
        restartButton.runAction(slide)
        quitButton.runAction(slide)
        
    }
    
    func resumeGame() {
        
        physicsWorld.speed = 1
        
        pauseButton.hidden = false
        resumeButton.removeFromParent()
        
        let finalXPosition = CGFloat(self.frame.width + 100)
        let slide = SKAction.moveToX(finalXPosition, duration: 0.2)
        restartButton.runAction(SKAction.sequence([slide, SKAction.removeFromParent()]))
        quitButton.runAction(SKAction.sequence([slide, SKAction.removeFromParent()]))
        
        //        if let view = self.view {
        //            view.scene?.paused = false
        //        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            
            if (node.name == ButtonNames.Pause.rawValue) && physicsWorld.speed == 1 {
                pauseGame()
            } else if (node.name == ButtonNames.Resume.rawValue) && physicsWorld.speed == 0 {
                resumeGame()
            } else if (node.name == ButtonNames.Restart.rawValue) {
                restartGame()
            } else if (node.name == ButtonNames.Quit.rawValue) {
                goHome()
            }
            
            
            //            if (node.name == "pauseButton") && self.view?.scene?.paused == false {
            //                pauseGame()
            //            } else if (node.name == "pauseButton") && self.view?.scene?.paused == true {
            //                resumeGame()
            //            }
        }
    }
    
    func goHome() {
        
        let highScore = userDefaults.integerForKey("BestScore")
        if score > highScore {
            userDefaults.setInteger(score, forKey: "BestScore")
        }
        userDefaults.setInteger(coins, forKey: "Coins")
        userDefaults.synchronize()
        
        let reveal = SKTransition.pushWithDirection(SKTransitionDirection.Up, duration: 0.5)
        let gameScene = MenuScene(size: self.size)
        self.view!.presentScene(gameScene, transition: reveal)
    }
    
    func restartGame() {
        
        let highScore = userDefaults.integerForKey("BestScore")
        if score > highScore {
            userDefaults.setInteger(score, forKey: "BestScore")
        }
        userDefaults.setInteger(coins, forKey: "Coins")
        userDefaults.synchronize()
        
        let reveal = SKTransition.pushWithDirection(SKTransitionDirection.Down, duration: 0.5)
        let gameScene = GameScene2(size: self.size)
        self.view!.presentScene(gameScene, transition: reveal)
        
    }
    
    // MARK: - Swipe Helpers
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
        let goBack = SKAction.moveToY(player.frame.size.height / 2 + 20, duration: 1)
        player.physicsBody?.velocity.dy = 0.0
        player.runAction(goBack)
    }
    
    // MARK: - Rotate Player helpers
    
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
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}


