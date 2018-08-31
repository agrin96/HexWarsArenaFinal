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

class MainMenuScene: SKScene, UIGestureRecognizerDelegate {
    
    var menuButtonRecognizer:UITapGestureRecognizer?
    var tapSoundMaker:SKAudioNode?
    var backGroundMusicMaker:SKAudioNode?

    weak var parentViewController:MainScreen?
    let fadeDuration = 0.5

    override func didMove(to view: SKView) {
        setupBackGround(for: view)
        setupGameMenu(for: view)
        
        menuButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleMenuTap))
        self.scene?.view?.addGestureRecognizer(menuButtonRecognizer!)

        if GameState.sharedInstance().mainPlayerOptions!.chosenSoundToggle! == .soundOn {
            if let path = Bundle.main.url(forResource: "TapSound", withExtension: "wav", subdirectory: "Sounds"){
                self.tapSoundMaker = SKAudioNode(url: path)
                self.tapSoundMaker!.autoplayLooped = false
                self.tapSoundMaker!.isPositional = false
                self.tapSoundMaker!.run(SKAction.changeVolume(to: 0.15, duration: 0))
                self.addChild(self.tapSoundMaker!)
            }
            if let path = Bundle.main.url(forResource: "BackgroundMusic", withExtension: "mp3", subdirectory: "Sounds"){
                self.backGroundMusicMaker = SKAudioNode(url: path)
                self.backGroundMusicMaker!.autoplayLooped = true
                self.backGroundMusicMaker!.isPositional = false
                self.backGroundMusicMaker!.run(SKAction.changeVolume(to: 0.05, duration: 0))
                self.addChild(self.backGroundMusicMaker!)
            }
        }
    }

    func reinitSoundMaker(){
        if let path = Bundle.main.url(forResource: "TapSound", withExtension: "wav", subdirectory: "Sounds"){
            self.tapSoundMaker = SKAudioNode(url: path)
            self.tapSoundMaker!.autoplayLooped = false
            self.tapSoundMaker!.isPositional = false
            self.tapSoundMaker!.run(SKAction.changeVolume(to: 0.15, duration: 0))
            self.addChild(self.tapSoundMaker!)
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

    func animationToggle(pause:Bool){
        let bkg1 = self.childNode(withName: "backGroundStyleImage") as! SKSpriteNode
        let bkg2 = self.childNode(withName: "backGroundStyleImage2") as! SKSpriteNode

        bkg1.isPaused = pause
        bkg2.isPaused = pause
    }

    func updateBackGround(){
        let color = GameState.sharedInstance().mainPlayerOptions!.chosenPlayerColor!.getColorFromCode()
        (self.childNode(withName: "//backGroundStyleImage") as! SKSpriteNode).color = color
        (self.childNode(withName: "//backGroundStyleImage2") as! SKSpriteNode).color = color
    }
    
    private func setupGameMenu(for view: SKView){
        let gameLogoImage = SKSpriteNode(texture: SKTexture(imageNamed: "Title"))
        self.addChild(gameLogoImage)
        gameLogoImage.zPosition = 0
        gameLogoImage.anchorPoint = CGPoint(x: 0.5, y: 1)
        gameLogoImage.position = CGPoint(x: view.frame.width / 2, y: view.frame.height - 20)
        gameLogoImage.alpha = 0
    
        gameLogoImage.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration))
        
        let singlePlayerButton = SpriteButton(button: SKTexture(imageNamed: "MenuButton"), buttonTouched: SKTexture(imageNamed: "MenuButton_TouchUpInside"))
        singlePlayerButton.setButtonText(text: "SinglePlayer")
        singlePlayerButton.setButtonTextFont(size: 26)
        singlePlayerButton.text!.position.y = -singlePlayerButton.size.height / 2 + 5
        self.addChild(singlePlayerButton)
        singlePlayerButton.zPosition = 0
        singlePlayerButton.anchorPoint = CGPoint(x: 0.5, y: 1)
        singlePlayerButton.position = CGPoint(x: view.frame.width / 2, y: view.frame.height - 240)
        singlePlayerButton.alpha = 0
        singlePlayerButton.name = "singlePlayerButton"
        
        singlePlayerButton.run(SKAction.sequence([SKAction.wait(forDuration: 1) ,SKAction.fadeAlpha(to: 1, duration: fadeDuration)]))
        
        let optionsButton = SpriteButton(button: SKTexture(imageNamed: "MenuButton"), buttonTouched: SKTexture(imageNamed: "MenuButton_TouchUpInside"))
        optionsButton.setButtonText(text: "Options")
        optionsButton.setButtonTextFont(size: 26)
        optionsButton.text!.position.y = -optionsButton.size.height / 2 + 5
        self.addChild(optionsButton)
        optionsButton.zPosition = 0
        optionsButton.anchorPoint = CGPoint(x: 0.5, y: 1)
        optionsButton.position = CGPoint(x: view.frame.width / 2, y: view.frame.height - 340)
        optionsButton.alpha = 0
        optionsButton.name = "optionsButton"
        
        optionsButton.run(SKAction.sequence([SKAction.wait(forDuration: 1) ,SKAction.fadeAlpha(to: 1, duration: fadeDuration)]))
        
        let historyButton = SpriteButton(button: SKTexture(imageNamed: "MenuButton"), buttonTouched: SKTexture(imageNamed: "MenuButton_TouchUpInside"))
        historyButton.setButtonText(text: "History")
        historyButton.setButtonTextFont(size: 26)
        historyButton.text!.position.y = -historyButton.size.height / 2 + 5
        self.addChild(historyButton)
        historyButton.zPosition = 0
        historyButton.anchorPoint = CGPoint(x: 0.5, y: 1)
        historyButton.position = CGPoint(x: view.frame.width / 2, y: view.frame.height - 440)
        historyButton.alpha = 0
        historyButton.name = "historyButton"
        
        historyButton.run(SKAction.sequence([SKAction.wait(forDuration: 1) ,SKAction.fadeAlpha(to: 1, duration: fadeDuration)]))

        let tutorialButton = SpriteButton(button: SKTexture(imageNamed: "MenuButton"), buttonTouched: SKTexture(imageNamed: "MenuButton_TouchUpInside"))
        tutorialButton.setButtonText(text: "Tutorial")
        tutorialButton.setButtonTextFont(size: 26)
        tutorialButton.text!.position.y = -tutorialButton.size.height / 2 + 5
        self.addChild(tutorialButton)
        tutorialButton.zPosition = 0
        tutorialButton.anchorPoint = CGPoint(x: 0.5, y: 1)
        tutorialButton.position = CGPoint(x: view.frame.width / 2, y: view.frame.height - 540)
        tutorialButton.alpha = 0
        tutorialButton.name = "tutorialButton"

        tutorialButton.run(SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.fadeAlpha(to: 1, duration: fadeDuration)]))
        
    }
    
    @objc func handleMenuTap(_ sender: UITapGestureRecognizer){
        let tapped = sender.location(in: self.scene?.view)
        let locationInScene = self.convertPoint(fromView: tapped)
        for button in self.scene!.children {
            if button.contains(locationInScene){
                if let buttonName = button.name {
                    switch buttonName {
                    case "singlePlayerButton":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            self.parentViewController?.transitionToSinglePlayer()
                        }
                        break
                    case "optionsButton":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            self.parentViewController?.transitionToOptions()
                        }
                        break
                    case "historyButton":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            self.parentViewController?.transitionToHistory()
                        }
                        break
                    case "tutorialButton":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            self.parentViewController?.transitionToTutorial()
                        }
                        break
                    default:
                        break
                    }
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {

    }


}
