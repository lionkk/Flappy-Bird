//
//  GameScene.swift
//  Flappy Bird
//
//  Created by geine on 15/2/25.
//  Copyright (c) 2015年 isee. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    let BirdGroup:UInt32 = 1
    let ObjectGroup:UInt32 = 2
    let GapGroup:UInt32 = 0 << 3
    var Bird = SKSpriteNode()
    var Bg = SKSpriteNode()
    var LabelHolder = SKSpriteNode()
    var GameOver = 0
    var MovingObjects = SKNode()
    
    var Score = 0
    var ScoreLabel = SKLabelNode()
    var GameOverLabel = SKLabelNode()
    
    override func didMoveToView(view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVectorMake(0, -5)
        self.addChild(MovingObjects)
        self.addChild(LabelHolder)
        
        backgroundInit()
        
        ScoreLabel.fontName = "Helvetica"
        ScoreLabel.fontSize = 60
        ScoreLabel.text = "0"
        ScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 70)
        ScoreLabel.zPosition = 10
        self.addChild(ScoreLabel)
        
        birdInit()
        groundInit()
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("pipesRun"), userInfo: nil, repeats: true)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if GameOver == 0 {
            Bird.physicsBody?.velocity = CGVectorMake(0, 0)
            Bird.physicsBody?.applyImpulse(CGVectorMake(0, 50))
        } else {
            Score = 0
            ScoreLabel.text = "0"
            
            MovingObjects.removeAllChildren()
            backgroundInit()
            Bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
            LabelHolder.removeAllChildren()
            Bird.physicsBody?.velocity = CGVectorMake(0, 0)
            GameOver = 0
            MovingObjects.speed = 1
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func backgroundInit() {
        var bgTexture = SKTexture(imageNamed: "bg.png")
        
        var moveBg = SKAction.moveByX(-bgTexture.size().width, y: 0, duration: 9)
        var replaceBg = SKAction.moveByX(bgTexture.size().width, y: 0, duration: 0)
        var moveBgForever = SKAction.repeatActionForever(SKAction.sequence([moveBg, replaceBg]))
        for var i:CGFloat = 0; i < 3; ++i {
            Bg = SKSpriteNode(texture: bgTexture)
            Bg.position = CGPoint(x: bgTexture.size().width/2 + bgTexture.size().width*i, y: CGRectGetMidY(self.frame))
            Bg.size.height = self.frame.height
            Bg.runAction(moveBgForever)
            
            MovingObjects.addChild(Bg)
        }
    }
    
    func birdInit() {
        var birdTexture1 = SKTexture(imageNamed: "flappy1.png")
        var birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        
        var animation = SKAction.animateWithTextures([birdTexture1, birdTexture2], timePerFrame: 0.1)
        var makeBirdFlap = SKAction.repeatActionForever(animation)
        
        Bird = SKSpriteNode(texture: birdTexture1)
        Bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        Bird.runAction(makeBirdFlap)
        
        Bird.physicsBody = SKPhysicsBody(circleOfRadius: Bird.size.height/2)
        Bird.physicsBody?.dynamic = true
        Bird.physicsBody?.allowsRotation = false
        Bird.physicsBody?.categoryBitMask = BirdGroup
        Bird.physicsBody?.collisionBitMask = GapGroup
        Bird.physicsBody?.contactTestBitMask = ObjectGroup
        
        Bird.zPosition = 10
        
        self.addChild(Bird)
    }
    
    func groundInit() {
        var ground = SKNode()
        ground.position = CGPointMake(0, 0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, 1))
        ground.physicsBody?.dynamic = false
        ground.physicsBody?.categoryBitMask = ObjectGroup
        MovingObjects.addChild(ground)
    }
    
    func pipesRun() {
        let gapHeight = Bird.size.height * 4
        var movementAmount = arc4random() % UInt32(self.frame.size.height / 2)
        var pipeOffset = CGFloat(movementAmount) - self.frame.size.height / 4
        var movePipes = SKAction.moveByX(-self.frame.size.width * 2, y: 0, duration: NSTimeInterval(self.frame.size.width/100))
        var removePipes = SKAction.removeFromParent()
        var moveAndRemovePipes = SKAction.sequence([movePipes, removePipes])
        
        var pipeTexture1 = SKTexture(imageNamed: "pipe1.png")
        var pipe1 = SKSpriteNode(texture: pipeTexture1)
        pipe1.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + pipe1.size.height/2 + gapHeight/2 + pipeOffset)
        pipe1.runAction(moveAndRemovePipes)
        pipe1.physicsBody = SKPhysicsBody(rectangleOfSize: pipe1.size)
        pipe1.physicsBody?.dynamic = false
        pipe1.physicsBody?.categoryBitMask = ObjectGroup
        MovingObjects.addChild(pipe1)
        
        var pipeTexture2 = SKTexture(imageNamed: "pipe2.png")
        var pipe2 = SKSpriteNode(texture: pipeTexture2)
        pipe2.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) - pipe2.size.height/2 - gapHeight/2 + pipeOffset)
        pipe2.runAction(moveAndRemovePipes)
        pipe2.physicsBody = SKPhysicsBody(rectangleOfSize: pipe2.size)
        pipe2.physicsBody?.dynamic = false
        pipe2.physicsBody?.categoryBitMask = ObjectGroup
        MovingObjects.addChild(pipe2)
        
        var gap = SKNode()
        gap.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + pipeOffset)
        gap.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipe1.size.width, gapHeight))
        gap.runAction(moveAndRemovePipes)
        gap.physicsBody?.dynamic = false
        gap.physicsBody?.collisionBitMask = GapGroup
        gap.physicsBody?.categoryBitMask = GapGroup
        gap.physicsBody?.contactTestBitMask = BirdGroup
        MovingObjects.addChild(gap)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == GapGroup || contact.bodyB.categoryBitMask == GapGroup {
            ++Score
            ScoreLabel.text = "\(Score)"
        } else {
            if GameOver == 0 {
                GameOver = 1
                MovingObjects.speed = 0
                
                GameOverLabel.fontName = "Helvetica"
                GameOverLabel.fontSize = 30
                GameOverLabel.text = "Game Over! Tap to play again."
                GameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
                LabelHolder.addChild(GameOverLabel)
            }
        }
    }
}
