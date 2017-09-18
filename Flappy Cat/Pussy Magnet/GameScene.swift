//
//  GameScene.swift
//  Pussy Magnet
//
//  Created by Dr.Drake Ramoray on 07.04.16.
//  Copyright (c) 2016 Dr.Drake Ramoray. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let Cat : UInt32 = 0x1 << 1
    static let Ground : UInt32 = 0x1 << 2
    static let Wall : UInt32 = 0x1 << 3
    static let Score : UInt32 = 0x1 << 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var Ground = SKSpriteNode()
    var Cat = SKSpriteNode()
    var wallPair = SKNode()
    var moveAndRemove = SKAction()
    var gameStarted = Bool()
    var score = Int()
    let scoreLbl = SKLabelNode()
    var died = Bool()
    var restartBTN = SKSpriteNode()
    
    func  restartScene() {
        
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStarted = false
        score = 0
        createScene()
    }
    
    func createScene() {
        
        self.physicsWorld.contactDelegate = self
        
        for i in 0..<2 {
            let background = SKSpriteNode(imageNamed: "city2")
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: CGFloat(i) * self.frame.width, y: 0)
            background.name = "city2"
            background.size = (self.view?.bounds.size)!
            self.addChild(background)
        }
        
        scoreLbl.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.5)
        scoreLbl.text = "\(score)"
        scoreLbl.fontColor = UIColor.black
        scoreLbl.fontName = "04b_19"
        self.addChild(scoreLbl)
        scoreLbl.fontSize =  60
        scoreLbl.zPosition = 5
        
        Ground = SKSpriteNode(imageNamed: "ground")
        Ground.setScale(0.5)
        Ground.position = CGPoint(x: self.frame.width / 2, y: 0 + Ground.frame.height / 2)
        Ground.physicsBody = SKPhysicsBody(rectangleOf: Ground.size)
        Ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        Ground.physicsBody?.collisionBitMask = PhysicsCategory.Cat
        Ground.physicsBody?.contactTestBitMask = PhysicsCategory.Cat
        Ground.physicsBody?.affectedByGravity = false
        Ground.physicsBody?.isDynamic = false
        Ground.zPosition = 3
        self.addChild(Ground)
        
        Cat = SKSpriteNode(imageNamed: "cat")
        Cat.size = CGSize(width: 60, height: 70)
        Cat.position = CGPoint(x: self.frame.width / 2 - Cat.frame.width, y: self.frame.height / 2)
        Cat.physicsBody = SKPhysicsBody(circleOfRadius: Cat.frame.height / 2)
        Cat.physicsBody?.categoryBitMask = PhysicsCategory.Cat
        Cat.physicsBody?.collisionBitMask = PhysicsCategory.Ground | PhysicsCategory.Wall
        Cat.physicsBody?.contactTestBitMask = PhysicsCategory.Ground | PhysicsCategory.Wall | PhysicsCategory.Score
        Cat.physicsBody?.affectedByGravity = false
        Cat.physicsBody?.isDynamic = true
        Cat.zPosition = 2
        self.addChild(Cat)
    }
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        createScene()
    }
    
    func createBTN () {
        
        restartBTN = SKSpriteNode(imageNamed: "restart")
        restartBTN.size = CGSize(width: 200, height: 100)
        restartBTN.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartBTN.zPosition = 6
        restartBTN.setScale(0)
        self.addChild(restartBTN)
        
        restartBTN.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == PhysicsCategory.Score && secondBody.categoryBitMask == PhysicsCategory.Cat{
            score += 1
            scoreLbl.text = "\(score)"
            scoreLbl.fontColor = UIColor.black
            firstBody.node?.removeFromParent()

        }
        else if firstBody.categoryBitMask == PhysicsCategory.Cat && secondBody.categoryBitMask == PhysicsCategory.Score {
            
            score += 1
            scoreLbl.text = "\(score)"
            scoreLbl.fontColor = UIColor.black
            secondBody.node?.removeFromParent()
        }
        
        else if firstBody.categoryBitMask == PhysicsCategory.Cat && secondBody.categoryBitMask == PhysicsCategory.Wall || firstBody.categoryBitMask == PhysicsCategory.Wall && secondBody.categoryBitMask == PhysicsCategory.Cat {
            
            enumerateChildNodes(withName: "wallPair", using: ({
                (node, error) in
                
                node.speed = 0
                self.removeAllActions()
            
            }))
            if died == false {
                died = true
                createBTN()
            }
        }
        else if firstBody.categoryBitMask == PhysicsCategory.Cat && secondBody.categoryBitMask == PhysicsCategory.Ground || firstBody.categoryBitMask == PhysicsCategory.Ground && secondBody.categoryBitMask == PhysicsCategory.Cat {
            
            enumerateChildNodes(withName: "wallPair", using: ({
                (node, error) in
                
                node.speed = 0
                self.removeAllActions()
                
            }))
            if died == false {
                died = true
                createBTN()
            }
            
        }

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
        if gameStarted == false {
            
            gameStarted = true
            
            Cat.physicsBody?.affectedByGravity = true
            
            let spawn = SKAction.run({
                () in
                
                self.createWalls()
            })
            
            let delay = SKAction.wait(forDuration: 1.5)
            let SpawnDelay = SKAction.sequence([spawn,delay])
            let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
            self.run(spawnDelayForever)
            
            
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let movePipes = SKAction.moveBy(x: -distance - 50, y: 0, duration: TimeInterval(0.009 * distance))
            let removePipes = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePipes, removePipes])
            
            Cat.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            Cat.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 80))
        }
        else{
            
            if died == true {
                
            }
            else {
                Cat.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                Cat.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 80))
            }
            
        }
        
        for touch in touches {
            let location = touch.location(in: self)
            
            if died == true {
                if restartBTN.contains(location) {
                    restartScene()
                }
            }
        }
    }
    
    func createWalls() {
        
        let scoreNode = SKSpriteNode(imageNamed: "food")
        
        scoreNode.size = CGSize(width: 50, height: 50)
        scoreNode.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCategory.Score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCategory.Cat
        scoreNode.color = SKColor.blue
        
        wallPair = SKNode()
        wallPair.name = "wallPair"
       
        let topWall = SKSpriteNode(imageNamed: "wall")
        let btmWall = SKSpriteNode(imageNamed: "wall")
        
        topWall.position = CGPoint(x: self.frame.width + 30, y: self.frame.height / 2 + 370)
        btmWall.position = CGPoint(x: self.frame.width + 30, y: self.frame.height / 2 - 370)
        
        topWall.setScale(0.5)
        btmWall.setScale(0.5)
        
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        topWall.physicsBody?.collisionBitMask = PhysicsCategory.Cat
        topWall.physicsBody?.contactTestBitMask = PhysicsCategory.Cat
        topWall.physicsBody?.isDynamic = false
        topWall.physicsBody?.affectedByGravity = false
        
        btmWall.physicsBody = SKPhysicsBody(rectangleOf: btmWall.size)
        btmWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        btmWall.physicsBody?.collisionBitMask = PhysicsCategory.Cat
        btmWall.physicsBody?.contactTestBitMask = PhysicsCategory.Cat
        btmWall.physicsBody?.isDynamic = false
        btmWall.physicsBody?.affectedByGravity = false
        
        topWall.zRotation = CGFloat(M_PI)
        
        wallPair.addChild(topWall)
        wallPair.addChild(btmWall)
        
        wallPair.zPosition = 1
        
        let randomPosition = CGFloat.random(min: -100, max: 100)
        wallPair.position.y = wallPair.position.y + randomPosition
        wallPair.run(moveAndRemove)
        wallPair.addChild(scoreNode)
        
        self.addChild(wallPair)
        
    }
   
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        
        if gameStarted == true {
            if died == false {
                enumerateChildNodes(withName: "city2", using: ( {
                    (node, error) in
                    
                    let bg = node as! SKSpriteNode
                    bg.position = CGPoint(x: bg.position.x - 2, y: bg.position.y)
                    
                    if bg.position.x <= -bg.size.width {
                        
                        bg.position = CGPoint(x: bg.position.x + bg.size.width * 2 , y: bg.position.y)
                    }
                    
                }))
            }
        }
    }
}
