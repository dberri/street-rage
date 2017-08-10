//
//  MenuScene.swift
//  StreetRageProject
//
//  Created by David Willian Berri on 7/28/16.
//  Copyright © 2016 David Willian Berri. All rights reserved.
//

import UIKit
import SpriteKit

class MenuScene: SKScene {
    
    let fontName = "AmericanTypewriter-Bold"
    let fontColor = SKColor.yellowColor()
    let fontSize: CGFloat = 40
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    var score: Int!
    var coins: Int!
    
    var bestScoreLbl: SKLabelNode!
    var coinsLbl: SKLabelNode!
    var easyLbl: SKLabelNode?
    var mediumLbl: SKLabelNode?
    var hardLbl: SKLabelNode?
    
    var startButton: SKSpriteNode!
    var difficultyButton: SKSpriteNode!
    var settingsButton: SKSpriteNode!
    var coinContainer: SKNode!
    var coin: SKSpriteNode!
    var background: SKSpriteNode!
    var midground: SKSpriteNode!
    
    var entities: [AnyObject]!
    var difficulties: [SKLabelNode?]!
    
    enum Names: String {
        case Start = "start"
        case Difficulty = "difficulty"
        case Settings = "settings"
        case Coin = "coin"
        case Easy = "easy"
        case Medium = "medium"
        case Hard = "hard"
    }
        
    override func didMoveToView(view: SKView) {

        coins = userDefaults.integerForKey("Coins")
        score = userDefaults.integerForKey("BestScore")
        
        createPlayer()
        createBackground()
        setupMenu()
        
        entities = [startButton, difficultyButton, settingsButton, coinContainer]
    }
    
    func setupMenu() {
        
        let buttonSize = CGSize(width: frame.size.width / 1.4, height: frame.size.height / 10)
        let firstButtonYPosition = frame.height - 130
        let verticalSpacing: CGFloat =  buttonSize.height + 10
        
        midground = SKSpriteNode(color: SKColor.blackColor().colorWithAlphaComponent(0.5), size: frame.size)
        midground.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        addChild(midground)
      
        bestScoreLbl = SKLabelNode(fontNamed: fontName)
        bestScoreLbl.fontSize = fontSize
        bestScoreLbl.fontColor = fontColor
        bestScoreLbl.horizontalAlignmentMode = .Center
        bestScoreLbl.position = CGPoint(x: frame.width / 2, y: frame.height - 40)
        bestScoreLbl.text = "best score \(score)"
        addChild(bestScoreLbl)
        
        let startTexture = SKTexture(imageNamed: "startButton")
        startButton = SKSpriteNode(texture: startTexture)
        startButton.position = CGPoint(x: frame.width / 2, y: firstButtonYPosition)
        startButton.size = buttonSize
        startButton.name = Names.Start.rawValue
        addChild(startButton)
        
        let difficultyTexture = SKTexture(imageNamed: "difficultyButton")
        difficultyButton = SKSpriteNode(texture: difficultyTexture)
        difficultyButton.position = CGPoint(x: frame.width / 2, y: firstButtonYPosition - verticalSpacing)
        difficultyButton.size = buttonSize
        difficultyButton.name = Names.Difficulty.rawValue
        addChild(difficultyButton)
        
        let settingsTexture = SKTexture(imageNamed: "settingsButton")
        settingsButton = SKSpriteNode(texture: settingsTexture)
        settingsButton.position = CGPoint(x: frame.width / 2, y: firstButtonYPosition - verticalSpacing * 2)
        settingsButton.size = buttonSize
        settingsButton.name = Names.Settings.rawValue
        addChild(settingsButton)
        
        coinContainer = SKNode()
        coinContainer = SKSpriteNode(color: UIColor.clearColor(), size: buttonSize)
        coinContainer.position = CGPoint(x: frame.width / 2, y: firstButtonYPosition - verticalSpacing * 3)
        addChild(coinContainer)
        
        let coinTexture = SKTexture(imageNamed: "coin")
        coin = SKSpriteNode(texture: coinTexture)
        coin.position = CGPoint(x: -(coinContainer.frame.width / 3), y: 0)
        coin.size = CGSize(width: buttonSize.height, height: buttonSize.height)
        coin.name = Names.Coin.rawValue
        coinContainer.addChild(coin)
        
        coinsLbl = SKLabelNode(fontNamed: fontName)
        coinsLbl.fontSize = fontSize
        coinsLbl.fontColor = fontColor
        coinsLbl.horizontalAlignmentMode = .Center
        coinsLbl.position = CGPoint(x: (coinContainer.frame.width / 3), y: -fontSize/3)
        coinsLbl.text = "\(coins)"
        coinsLbl.name = Names.Coin.rawValue
        coinContainer.addChild(coinsLbl)
        
    }
    
    func createBackground() {
        background = SKSpriteNode(color: SKColor.whiteColor(), size: self.frame.size)
        background.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        background.zPosition = -1
        addChild(background)
    }
    
    func createPlayer() {
        let size = CGSize(width: self.frame.size.width / 4, height: self.frame.size.height / 4)
        let playerTexture = SKTexture(imageNamed: "car")
        let player = SKSpriteNode(texture: playerTexture)
        player.size = size
        player.position = CGPointMake((self.frame.size.width / 2), player.frame.size.height / 2 + 20)
        addChild(player)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            
            if let name = node.name {
                switch name {
                case Names.Start.rawValue:
                    
                    startGame()
                    
                case Names.Difficulty.rawValue:
                    
                    enterDifficultyMenu()
                    
                case Names.Settings.rawValue:
                    
                    enterSettingsMenu()
                    
                case Names.Coin.rawValue:
                    
                    print(Names.Coin.rawValue)
                    
                case Names.Easy.rawValue:
                    let labelNode = node as! SKLabelNode
                    labelNode.text = ">\(Names.Easy.rawValue)<"
                    difficulties[1]!.text = "\(Names.Medium.rawValue)"
                    difficulties[2]!.text = "\(Names.Hard.rawValue)"
                    
                    leaveMenu()
                    
                case Names.Medium.rawValue:
                    let labelNode = node as! SKLabelNode
                    labelNode.text = ">\(Names.Medium.rawValue)<"
                    difficulties[0]!.text = "\(Names.Easy.rawValue)"
                    difficulties[2]!.text = "\(Names.Hard.rawValue)"
                    
                    leaveMenu()
                    
                case Names.Hard.rawValue:
                    let labelNode = node as! SKLabelNode
                    labelNode.text = ">\(Names.Hard.rawValue)<"
                    difficulties[0]!.text = "\(Names.Easy.rawValue)"
                    difficulties[1]!.text = "\(Names.Medium.rawValue)"
                    
                    leaveMenu()
                    
                default:
                    break
                }
            }
        }
    }
    
    func startGame() {
        
        let reveal = SKTransition.pushWithDirection(SKTransitionDirection.Down, duration: 0.5)
        let gameScene = GameScene2(size: self.size)
        self.view!.presentScene(gameScene, transition: reveal)
    }
    
    func enterDifficultyMenu() {
        
        let labelSize = CGSize(width: frame.size.width / 1.5, height: frame.size.height / 10)
        let firstLabelYposition = frame.height - 130
        let verticalSpacing: CGFloat =  labelSize.height + 10
        let initialXPosition = -frame.width
        
        for i in 0..<entities.count {
            
            let node = entities[i] as! SKNode
            let finalPosition = CGPoint(x: self.frame.width * 2, y: entities[i].position.y)
            let slide = SKAction.moveTo(finalPosition, duration: 0.2)
            
            node.runAction(slide)
        }
        
        // Create the difficulty menu labels
        
        easyLbl = SKLabelNode(fontNamed: fontName)
        easyLbl!.fontSize = fontSize
        easyLbl!.fontColor = SKColor.whiteColor()
        easyLbl!.horizontalAlignmentMode = .Center
        easyLbl!.position = CGPoint(x: initialXPosition, y: firstLabelYposition)
        easyLbl!.text = "> easy <"
        easyLbl!.name = Names.Easy.rawValue
        addChild(easyLbl!)
        
        mediumLbl = SKLabelNode(fontNamed: fontName)
        mediumLbl!.fontSize = fontSize
        mediumLbl!.fontColor = SKColor.whiteColor()
        mediumLbl!.horizontalAlignmentMode = .Center
        mediumLbl!.position = CGPoint(x: initialXPosition, y: firstLabelYposition - verticalSpacing)
        mediumLbl!.text = "medium"
        mediumLbl!.name = Names.Medium.rawValue
        addChild(mediumLbl!)
        
        hardLbl = SKLabelNode(fontNamed: fontName)
        hardLbl!.fontSize = fontSize
        hardLbl!.fontColor = SKColor.whiteColor()
        hardLbl!.horizontalAlignmentMode = .Center
        hardLbl!.position = CGPoint(x: initialXPosition, y: firstLabelYposition - verticalSpacing * 2)
        hardLbl!.text = "hard"
        hardLbl!.name = Names.Hard.rawValue
        addChild(hardLbl!)
        
        difficulties = [easyLbl, mediumLbl, hardLbl]
        
        if let difficulties = difficulties {
            for i in 0..<difficulties.count {
                
                let node = difficulties[i]!
                let finalPosition = CGPoint(x: self.frame.width / 2, y: difficulties[i]!.position.y)
                let slide = SKAction.moveTo(finalPosition, duration: 0.2)
                
                node.runAction(slide)
            }
        }
    }
    
    func enterSettingsMenu() {
        
    }
    
    func leaveMenu() {
        
        // Bring Home Menu Back
        for i in 0..<entities.count {
            
            let node = entities[i] as! SKNode
            let finalPosition = CGPoint(x: self.frame.width / 2, y: entities[i].position.y)
            let slide = SKAction.moveTo(finalPosition, duration: 0.4)
            
            node.runAction(slide)
        }
        
        // Slide and Remove difficulties menu
        if let difficulties = difficulties {
            for i in 0..<difficulties.count {
                
                let node = difficulties[i]!
                let finalPosition = CGPoint(x: -self.frame.width, y: difficulties[i]!.position.y)
                let slide = SKAction.moveTo(finalPosition, duration: 0.2)
                let wait = SKAction.waitForDuration(0.2)
                let sequence = SKAction.sequence([wait, slide, SKAction.removeFromParent()])
                node.runAction(sequence)
            }
        }
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
