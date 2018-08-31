//
// Created by Aleksandr Grin on 2/15/18.
// Copyright (c) 2018 AleksandrGrin. All rights reserved.
//

//
//  MainMenuScene.swift
//  HexWars
//
//  Created by Aleksandr Grin on 9/24/17.
//  Copyright © 2017 AleksandrGrin. All rights reserved.
//

import SpriteKit
import CoreGraphics
import AVFoundation

class TutorialScene: SKScene, UIGestureRecognizerDelegate {

    var menuButtonRecognizer:UITapGestureRecognizer?
    var scrollRecognizer:UIPanGestureRecognizer?
    var tapSoundMaker:SKAudioNode?

    weak var parentViewController:TutorialScreen?
    let fadeDuration = 0.5

    override func didMove(to view: SKView) {
        setupBackGround(for: view)
        setupUI(for: view)
        addInformation(for: view)

        menuButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleMenuTap))
        self.scene?.view?.addGestureRecognizer(menuButtonRecognizer!)

        scrollRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.scene?.view?.addGestureRecognizer(scrollRecognizer!)

        if GameState.sharedInstance().mainPlayerOptions!.chosenSoundToggle! == .soundOn {
            if let path = Bundle.main.url(forResource: "TapSound", withExtension: "wav", subdirectory: "Sounds"){
                self.tapSoundMaker = SKAudioNode(url: path)
                self.tapSoundMaker!.autoplayLooped = false
                self.tapSoundMaker!.isPositional = false
                self.tapSoundMaker!.run(SKAction.changeVolume(to: 0.15, duration: 0))
                self.addChild(self.tapSoundMaker!)
            }
        }
    }

    private func setupBackGround(for view: SKView){
        let backGroundColorImage = SKSpriteNode(texture: SKTexture(imageNamed: "Background"), size: view.frame.size)
        backGroundColorImage.zPosition = -2
        backGroundColorImage.anchorPoint = CGPoint(x: 0, y: 0)

        let backGroundStyleImage = SKSpriteNode(texture: SKTexture(imageNamed: "BackGroundStyleV2"), size: view.frame.size)
        backGroundStyleImage.zPosition = -1
        backGroundStyleImage.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backGroundStyleImage.color = GameState.sharedInstance().mainPlayerOptions!.chosenPlayerColor!.getColorFromCode()
        backGroundStyleImage.colorBlendFactor = 1.0
        backGroundStyleImage.name = "backGroundStyleImage"
        backGroundStyleImage.blendMode = .add

        let backGroundStyleImage2 = SKSpriteNode(texture: SKTexture(imageNamed: "BackGroundStyleV1"), size: view.frame.size)
        backGroundStyleImage2.zPosition = -1
        backGroundStyleImage2.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backGroundStyleImage2.color = GameState.sharedInstance().mainPlayerOptions!.chosenPlayerColor!.getColorFromCode()
        backGroundStyleImage2.colorBlendFactor = 1.0
        backGroundStyleImage2.blendMode = .add
        backGroundStyleImage2.name = "backGroundStyleImage2"

        self.addChild(backGroundColorImage)
        self.addChild(backGroundStyleImage)
        self.addChild(backGroundStyleImage2)

        animateBackGround(for: view)
    }

    private func animateBackGround(for view: SKView){
        let path = CGMutablePath()
        let refRect = CGRect(x: view.frame.width / 2 - 12, y: view.frame.height / 2 - 12, width: 24, height: 24)
        path.addEllipse(in: refRect)
        let bkg1 = self.childNode(withName: "backGroundStyleImage") as! SKSpriteNode
        let bkg2 = self.childNode(withName: "backGroundStyleImage2") as! SKSpriteNode

        let animation = SKAction.repeatForever(SKAction.follow(path, asOffset: false, orientToPath: false, speed: 4))
        let animation2 = SKAction.repeatForever(SKAction.follow(path, asOffset: false, orientToPath: false, speed: 7))
        bkg1.run(animation)
        bkg2.run(animation2)
    }

    private func setupUI(for view: SKView){
        let newCamera = SKCameraNode()
        newCamera.name = "MainCamera"
        newCamera.position.x = view.frame.width / 2
        newCamera.position.y = view.frame.height / 2
        self.addChild(newCamera)
        self.camera = newCamera
        if self.camera!.physicsBody == nil {
            self.camera!.physicsBody = SKPhysicsBody(circleOfRadius: 1)
            self.camera!.physicsBody!.isDynamic = true
            self.camera!.physicsBody!.mass = 3
            self.camera!.physicsBody!.allowsRotation = false
            self.camera!.physicsBody!.affectedByGravity = false
            self.camera!.physicsBody!.linearDamping = 0.99
        }

        let navigationBar = SKSpriteNode(texture: SKTexture(imageNamed: "TurnNavigatorBar"))
        navigationBar.alpha = 1.0
        navigationBar.name = "BottomBar"
        navigationBar.isHidden = false
        navigationBar.isUserInteractionEnabled = false
        navigationBar.anchorPoint = CGPoint(x: 0.5, y: 0)
        navigationBar.position = CGPoint(x: 0, y: -view.frame.height / 2 + 20)
        navigationBar.zPosition = 11
        newCamera.addChild(navigationBar)

        let returnButton = SpriteButton(button: SKTexture(imageNamed: "TurnNavigatorSubBar"), buttonTouched: SKTexture(imageNamed: "TurnNavigatorSubBar_TouchUpInside"))
        returnButton.setButtonText(text: "Return")
        returnButton.setButtonTextFont(size: 18)
        returnButton.alpha = 1.0
        returnButton.name = "returnButton"
        returnButton.isHidden = false
        returnButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        returnButton.position = CGPoint(x: 0, y: navigationBar.frame.height / 2)
        returnButton.zPosition = 10
        navigationBar.addChild(returnButton)
    }

    private func addInformation(for view: SKView){
        let tutorial = SKSpriteNode(imageNamed: "GameTutorialPage_Full")
        tutorial.alpha = 1.0
        tutorial.name = "tutorial"
        tutorial.isHidden = false
        tutorial.isUserInteractionEnabled = false
        tutorial.anchorPoint = CGPoint(x: 0.5, y: 1)
        tutorial.position = CGPoint(x: view.frame.width / 2, y: view.frame.height)
        tutorial.zPosition = 10
        self.addChild(tutorial)

        let range = SKRange(lowerLimit: -tutorial.frame.height + (view.frame.height / 2.5), upperLimit: -(view.frame.height / 2))
        let constraint = SKConstraint.positionY(range)
        constraint.referenceNode = tutorial
        self.camera?.constraints = [constraint]
    }


    @objc func handleMenuTap(_ sender: UITapGestureRecognizer){
        let tapped = sender.location(in: self.scene?.view)
        let locationInScene = self.convertPoint(fromView: tapped)

        let tappedNodes = self.nodes(at: locationInScene)
        for button in tappedNodes {
            if let buttonName = button.name {
                switch buttonName {
                case "returnButton":
                    if self.tapSoundMaker != nil {
                        self.tapSoundMaker!.run(SKAction.play())
                    }
                    (button as! SpriteButton).buttonTouchedUpInside(){
                        self.parentViewController?.returnToMenu()
                    }
                    break
                default:
                    break
                }
            }
        }
    }

    override func update(_ currentTime: TimeInterval) {

    }

    @objc func handlePan(_ sender: UIPanGestureRecognizer){
        switch sender.state {
        case .began:
            self.camera!.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            break
        case .changed:
            self.camera!.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            let moved = sender.translation(in: self.view)
            self.camera!.position.y += moved.y
            sender.setTranslation(CGPoint.zero, in: self.scene!.view)
            break
        case .ended:
            let velocity = sender.velocity(in: self.view)
            self.camera!.physicsBody!.applyImpulse(CGVector(dx: 0, dy: velocity.y))
            break
        default:
            break
        }

    }
}
