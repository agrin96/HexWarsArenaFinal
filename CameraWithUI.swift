//
// Created by Aleksandr Grin on 10/11/17.
// Copyright (c) 2017 AleksandrGrin. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit
import DeviceKit

class CameraWithUI: SKCameraNode, UIGestureRecognizerDelegate {
    weak var boardTileManager:BoardTileManager?
    weak var currentActivePlayer:Player?
    var tapSoundMaker:SKAudioNode?

    private var maxZoomIn:CGFloat = 0.25
    private var maxZoomOut:CGFloat = 4

    private var previousCrownFocused:Array<CGPoint> = []
    private var notificationSystem:NotificationSystem = NotificationSystem()

    init(in view: SKView) {
        super.init()
        self.createGameUI(for: view)
    }

    func activateSound(){
        if GameState.sharedInstance().mainPlayerOptions!.chosenSoundToggle! == .soundOn {
            if let path = Bundle.main.url(forResource: "TapSound", withExtension: "wav", subdirectory: "Sounds"){
                self.tapSoundMaker = SKAudioNode(url: path)
                self.tapSoundMaker!.autoplayLooped = false
                self.tapSoundMaker!.isPositional = false
                self.tapSoundMaker!.run(SKAction.changeVolume(to: 0.10, duration: 0))
                self.addChild(self.tapSoundMaker!)
            }
        }
    }

    func createGameUI(for view: SKView){
        //NOTE: Order of calling maters for creating these UIElements
        createTopCrownBar(for: view)
        createTopIndicatorBar(for: view)
        createGameInfoBar(for: view)
        createHelpButton(for: view)
        createBuildTabs(for: view)
        createTurnNavigatorBar(for: view)
        createGameNotificationLabel(for: view)
        setupBackGround(for: view)

    }

    private func setupBackGround(for view: SKView){
        let newSize = CGSize(width: view.frame.width, height: view.frame.height)

        let background = SKSpriteNode(texture: SKTexture(imageNamed: "MidievalBackground"))
        background.size = newSize
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        background.zPosition = -1000
        background.alpha = 0.8
        background.position = CGPoint(x: 0, y: 0)
        self.addChild(background)
    }

    //Display a text indicating the current players turn began. Update on calling endTurn() function.
    //Set the current player reference inside this class.
    func updatePlayerTurnLabel(for player: Player){
        self.currentActivePlayer = player

        let indicator = self.childNode(withName: "//gameNotification") as! SKLabelNode
        let text = getNameFromColor(color: player.color!) + "'s Turn"
        let textColor = player.color

        let animation = SKAction.sequence([SKAction.unhide(),
                                           SKAction.wait(forDuration: 1.5),
                                           SKAction.hide(),
                                           SKAction.wait(forDuration: 0.1)])
        self.notificationSystem.setExecution(action: animation, node: indicator)
        self.notificationSystem.addNew(notification: text, fontColor: textColor, fontName: nil)

        //Sets the player piece name in the board tile manager for the current piece.
        self.boardTileManager!.getCurrentPlayerPiece()
        self.run(SKAction.group([SKAction.scale(to: 3, duration: 1),SKAction.move(to: CGPoint(x: 0, y: 0), duration: 1)]))

        self.updateCurrentPlayer(player: player)
    }

    //Update the top indicator labels with the latest player data. Likely call inside the update function
    func updateIndicatorLabels(for player: Player){
        if player.numberOfLevel3 == nil || player.numberOfLevel2 == nil || player.numberOfLevel1 == nil || player.numberOfCrowns == nil {
            print("ERROR PLAYER DATA NIL \(#function)")
        }else{
            let crownIndicator = self.childNode(withName: "//crownCountLabel") as! SKLabelNode
            let farmIndicator = self.childNode(withName: "//farmIndicatorCount") as! SKLabelNode
            let industryIndictor = self.childNode(withName: "//industryIndicatorCount") as! SKLabelNode
            let militaryIndicator = self.childNode(withName: "//militaryIndicatorCount") as! SKLabelNode
            let counterIndicator = self.childNode(withName: "//counterIndicatorCount") as! SKLabelNode

            crownIndicator.text = "Crown: " + String(player.crownHealth!)
            farmIndicator.text = ": " + String(player.numberOfLevel1!)
            industryIndictor.text = ": " + String(player.numberOfLevel2!)
            militaryIndicator.text = ": " + String(player.numberOfLevel3!)
            counterIndicator.text = ": " + String(player.deployedCounters!)
        }

    }

    //Used to display any type of textual notificaiton through the game. Offers feedback for player action.
    func displayGameNotification(text: String, textColor: UIColor?, completion: @escaping ()->()){
        let notifier = self.childNode(withName: "//gameNotification") as! SKLabelNode
        let animation = SKAction.sequence([SKAction.unhide(),
                                           SKAction.wait(forDuration: 1.5),
                                           SKAction.hide(),
                                           SKAction.wait(forDuration: 0.1)])

        self.notificationSystem.setExecution(action: animation, node: notifier)
        self.notificationSystem.addNew(notification: text, fontColor: textColor, fontName: nil)
    }

    func updateUIColor(for color:SKColor){
        let bottomBar = self.childNode(withName: "//BottomBar") as! SKSpriteNode
        bottomBar.color = color
        bottomBar.blendMode = .alpha
        bottomBar.colorBlendFactor = 0.6

        var symbols:[SKSpriteNode] = []
        let crownSymbol = self.childNode(withName: "//crownSymbol") as! SKSpriteNode
        symbols.append(crownSymbol)
        let levelOne = self.childNode(withName: "//levelOneSymbol") as! SKSpriteNode
        symbols.append(levelOne)
        let levelTwo = self.childNode(withName: "//levelTwoSymbol") as! SKSpriteNode
        symbols.append(levelTwo)
        let levelThree = self.childNode(withName: "//levelThreeSymbol") as! SKSpriteNode
        symbols.append(levelThree)
        let counterSymbol = self.childNode(withName: "//counterIndicatorSymbol") as! SKSpriteNode
        symbols.append(counterSymbol)
        let counterBuildSym = self.childNode(withName: "//counterBuildSymbol") as! SKSpriteNode
        symbols.append(counterBuildSym)

        for node in symbols {
            node.color = color
            node.blendMode = .add
            node.colorBlendFactor = 0.7
        }

    }


    //************************************ Top Bar UI setup **************************************//
    private func createTopCrownBar(for view: SKView){
        let crownBar = SKSpriteNode(texture: SKTexture(imageNamed: "CrownBar"))
        crownBar.alpha = 1.0
        crownBar.isHidden = false
        crownBar.anchorPoint = CGPoint(x: 0.5, y: 1)
        crownBar.position = CGPoint(x: 0, y: view.frame.height / 2 - 10)
        crownBar.zPosition = 10
        crownBar.name = "crownBar"
        self.addChild(crownBar)

        let crownIndicator = SpriteButton(button: SKTexture(imageNamed: "CrownIndicator"), buttonTouched: SKTexture(imageNamed: "CrownIndicator_TouchUpInside"))
        crownIndicator.alpha = 1.0
        crownIndicator.isHidden = false
        crownIndicator.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        crownIndicator.position = CGPoint(x: -5, y: -crownBar.frame.height / 2)
        crownIndicator.zPosition = 11
        crownIndicator.name = "crownIndicator"
        crownBar.addChild(crownIndicator)

        let crownSymbol = SKSpriteNode(imageNamed: "CrownHex")
        crownSymbol.alpha = 1.0
        crownSymbol.isHidden = false
        crownSymbol.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        crownSymbol.position = CGPoint(x: -crownIndicator.frame.width / 3, y: 2)
        crownSymbol.xScale = 0.4
        crownSymbol.yScale = 0.4
        crownSymbol.zPosition = 12
        crownSymbol.name = "crownSymbol"
        crownIndicator.addChild(crownSymbol)

        let crownCountLabel = SKLabelNode(text: "3")
        crownCountLabel.fontSize = 16
        crownCountLabel.fontColor = UIColor.white
        crownCountLabel.horizontalAlignmentMode = .center
        crownCountLabel.verticalAlignmentMode = .center
        crownCountLabel.fontName = "Arial"

        crownCountLabel.alpha = 1.0
        crownCountLabel.isHidden = false
        crownCountLabel.position = CGPoint(x: crownIndicator.position.x + crownIndicator.frame.width / 10, y: -crownBar.frame.height / 2)
        crownCountLabel.zPosition = 12
        crownCountLabel.name = "crownCountLabel"
        crownBar.addChild(crownCountLabel)
    }

    private func createTopIndicatorBar(for view: SKView){
        let scale:CGFloat = 0.35

        let indicatorsBar = SKSpriteNode(texture: SKTexture(imageNamed: "IndicatorBar"))
        indicatorsBar.alpha = 1.0
        indicatorsBar.isHidden = false
        indicatorsBar.anchorPoint = CGPoint(x: 0.5, y: 1)
        indicatorsBar.position = CGPoint(x: 0, y: self.childNode(withName: "crownBar")!.position.y - self.childNode(withName: "crownBar")!.frame.height / 0.9)
        indicatorsBar.zPosition = 10
        self.addChild(indicatorsBar)

        let levelOneIndicator = SKSpriteNode(imageNamed: "IndicatorSubTab")
        levelOneIndicator.alpha = 1.0
        levelOneIndicator.name = "farmBar"
        levelOneIndicator.isHidden = false
        levelOneIndicator.anchorPoint = CGPoint(x: 0, y: 0.5)
        levelOneIndicator.position = CGPoint(x: -indicatorsBar.frame.width / 2 + 5, y: -indicatorsBar.frame.height / 2)
        levelOneIndicator.zPosition = 10
        indicatorsBar.addChild(levelOneIndicator)

        let levelOneIndicatorSymbol = SKSpriteNode(imageNamed: "\(GameState.sharedInstance().mainPlayerOptions!.chosenGameTheme!.themeName())_Level1")
        levelOneIndicatorSymbol.alpha = 1.0
        levelOneIndicatorSymbol.isHidden = false
        levelOneIndicatorSymbol.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        levelOneIndicatorSymbol.position = CGPoint(x: levelOneIndicator.frame.width / 3, y: 2)
        levelOneIndicatorSymbol.xScale = scale
        levelOneIndicatorSymbol.yScale = scale
        levelOneIndicatorSymbol.zPosition = 11
        levelOneIndicatorSymbol.name = "levelOneSymbol"
        levelOneIndicator.addChild(levelOneIndicatorSymbol)

        let levelOneIndicatorCount = SKLabelNode(text: "0")
        levelOneIndicatorCount.fontSize = 16
        levelOneIndicatorCount.fontColor = UIColor.white
        levelOneIndicatorCount.horizontalAlignmentMode = .center
        levelOneIndicatorCount.verticalAlignmentMode = .center
        levelOneIndicatorCount.fontName = "Arial-BoldMT"

        levelOneIndicatorCount.alpha = 1.0
        levelOneIndicatorCount.isHidden = false
        levelOneIndicatorCount.position = CGPoint(x: levelOneIndicator.position.x + levelOneIndicator.frame.width / 1.6, y: -levelOneIndicator.frame.height / 2)
        levelOneIndicatorCount.zPosition = 11
        levelOneIndicatorCount.name = "farmIndicatorCount"
        indicatorsBar.addChild(levelOneIndicatorCount)

        let industryIndicator = SKSpriteNode(imageNamed: "IndicatorSubTab")
        industryIndicator.alpha = 1.0
        industryIndicator.name = "industryBar"
        industryIndicator.isHidden = false
        industryIndicator.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        industryIndicator.position = CGPoint(x: -indicatorsBar.frame.width / 4, y: -indicatorsBar.frame.height / 2)
        industryIndicator.zPosition = 10
        indicatorsBar.addChild(industryIndicator)

        let levelTwoIndicatorSymbol = SKSpriteNode(imageNamed: "\(GameState.sharedInstance().mainPlayerOptions!.chosenGameTheme!.themeName())_Level2")
        levelTwoIndicatorSymbol.alpha = 1.0
        levelTwoIndicatorSymbol.isHidden = false
        levelTwoIndicatorSymbol.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        levelTwoIndicatorSymbol.position = CGPoint(x: industryIndicator.frame.width / 3, y: 2)
        levelTwoIndicatorSymbol.xScale = scale
        levelTwoIndicatorSymbol.yScale = scale
        levelTwoIndicatorSymbol.zPosition = 11
        levelTwoIndicatorSymbol.name = "levelTwoSymbol"
        industryIndicator.addChild(levelTwoIndicatorSymbol)

        let levelTwoIndicatorCount = SKLabelNode(text: "1")
        levelTwoIndicatorCount.fontSize = 16
        levelTwoIndicatorCount.fontColor = UIColor.white
        levelTwoIndicatorCount.horizontalAlignmentMode = .center
        levelTwoIndicatorCount.verticalAlignmentMode = .center
        levelTwoIndicatorCount.fontName = "Arial-BoldMT"

        levelTwoIndicatorCount.alpha = 1.0
        levelTwoIndicatorCount.isHidden = false
        levelTwoIndicatorCount.position = CGPoint(x: industryIndicator.position.x + levelOneIndicator.frame.width / 1.6, y: -industryIndicator.frame.height / 2)
        levelTwoIndicatorCount.zPosition = 11
        levelTwoIndicatorCount.name = "industryIndicatorCount"
        indicatorsBar.addChild(levelTwoIndicatorCount)

        let levelThreeIndicator = SKSpriteNode(imageNamed: "IndicatorSubTab")
        levelThreeIndicator.alpha = 1.0
        levelThreeIndicator.name = "militaryBar"
        levelThreeIndicator.isHidden = false
        levelThreeIndicator.anchorPoint = CGPoint(x: 1, y: 0.5)
        levelThreeIndicator.position = CGPoint(x: indicatorsBar.frame.width / 4, y: -indicatorsBar.frame.height / 2)
        levelThreeIndicator.zPosition = 10
        indicatorsBar.addChild(levelThreeIndicator)

        let levelThreeIndicatorSymbol = SKSpriteNode(imageNamed: "\(GameState.sharedInstance().mainPlayerOptions!.chosenGameTheme!.themeName())_Level3")
        levelThreeIndicatorSymbol.alpha = 1.0
        levelThreeIndicatorSymbol.isHidden = false
        levelThreeIndicatorSymbol.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        levelThreeIndicatorSymbol.position = CGPoint(x: -levelThreeIndicator.frame.width / 3 * 2, y: 2)
        levelThreeIndicatorSymbol.xScale = scale
        levelThreeIndicatorSymbol.yScale = scale
        levelThreeIndicatorSymbol.zPosition = 11
        levelThreeIndicatorSymbol.name = "levelThreeSymbol"
        levelThreeIndicator.addChild(levelThreeIndicatorSymbol)

        let levelThreeIndicatorCount = SKLabelNode(text: ":  2")
        levelThreeIndicatorCount.fontSize = 16
        levelThreeIndicatorCount.fontColor = UIColor.white
        levelThreeIndicatorCount.horizontalAlignmentMode = .center
        levelThreeIndicatorCount.verticalAlignmentMode = .center
        levelThreeIndicatorCount.fontName = "Arial-BoldMT"

        levelThreeIndicatorCount.alpha = 1.0
        levelThreeIndicatorCount.isHidden = false
        levelThreeIndicatorCount.position = CGPoint(x: levelThreeIndicator.position.x - levelThreeIndicator.frame.width / 2.5, y: -levelThreeIndicator.frame.height / 2)
        levelThreeIndicatorCount.zPosition = 11
        levelThreeIndicatorCount.name = "militaryIndicatorCount"
        indicatorsBar.addChild(levelThreeIndicatorCount)

        let counterIndicator = SKSpriteNode(imageNamed: "IndicatorSubTab")
        counterIndicator.alpha = 1.0
        counterIndicator.name = "militaryBar"
        counterIndicator.isHidden = false
        counterIndicator.anchorPoint = CGPoint(x: 1, y: 0.5)
        counterIndicator.position = CGPoint(x: indicatorsBar.frame.width / 2 - 3, y: -indicatorsBar.frame.height / 2)
        counterIndicator.zPosition = 10
        indicatorsBar.addChild(counterIndicator)

        let counterIndicatorSymbol = SKSpriteNode(imageNamed: "Medieval_Counter")
        counterIndicatorSymbol.alpha = 1.0
        counterIndicatorSymbol.isHidden = false
        counterIndicatorSymbol.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        counterIndicatorSymbol.position = CGPoint(x: -counterIndicator.frame.width / 3 * 2, y: 2)
        counterIndicatorSymbol.xScale = scale
        counterIndicatorSymbol.yScale = scale
        counterIndicatorSymbol.zPosition = 11
        counterIndicatorSymbol.name = "counterIndicatorSymbol"
        counterIndicator.addChild(counterIndicatorSymbol)

        let counterIndicatorCount = SKLabelNode(text: ": 3")
        counterIndicatorCount.fontSize = 16
        counterIndicatorCount.fontColor = UIColor.white
        counterIndicatorCount.horizontalAlignmentMode = .center
        counterIndicatorCount.verticalAlignmentMode = .center
        counterIndicatorCount.fontName = "Arial-BoldMT"

        counterIndicatorCount.alpha = 1.0
        counterIndicatorCount.isHidden = false
        counterIndicatorCount.position = CGPoint(x: counterIndicator.position.x - counterIndicator.frame.width / 2.5, y: -counterIndicator.frame.height / 2)
        counterIndicatorCount.zPosition = 11
        counterIndicatorCount.name = "counterIndicatorCount"
        indicatorsBar.addChild(counterIndicatorCount)
    }

    private func createGameInfoBar(for view: SKView){
        let gameInfoBar = SKSpriteNode(texture: SKTexture(imageNamed: "GameInfoBar"))
        gameInfoBar.alpha = 1.0
        gameInfoBar.isHidden = false
        gameInfoBar.anchorPoint = CGPoint(x: 0.5, y: 1)
        gameInfoBar.position = CGPoint(x: 0, y: view.frame.height / 2.40 - 10)
        gameInfoBar.zPosition = 9
        gameInfoBar.name = "gameInfoBar"
        self.addChild(gameInfoBar)

        let currentPlayerLabel = SKLabelNode(text: "Player 1")
        currentPlayerLabel.fontSize = 10
        currentPlayerLabel.fontColor = UIColor.black
        currentPlayerLabel.horizontalAlignmentMode = .center
        currentPlayerLabel.verticalAlignmentMode = .center
        currentPlayerLabel.fontName = "Arial-BoldMT"

        currentPlayerLabel.alpha = 1.0
        currentPlayerLabel.isHidden = false
        currentPlayerLabel.position = CGPoint(x: -gameInfoBar.frame.width / 4, y: -gameInfoBar.frame.height / 1.5 - 1)
        currentPlayerLabel.zPosition = 10
        currentPlayerLabel.name = "currentPlayerLabel"
        gameInfoBar.addChild(currentPlayerLabel)

        let currentTurnLabel = SKLabelNode(text: "Turn 1")
        currentTurnLabel.fontSize = 10
        currentTurnLabel.fontColor = UIColor.black
        currentTurnLabel.horizontalAlignmentMode = .center
        currentTurnLabel.verticalAlignmentMode = .center
        currentTurnLabel.fontName = "Arial-BoldMT"

        currentTurnLabel.alpha = 1.0
        currentTurnLabel.isHidden = false
        currentTurnLabel.position = CGPoint(x: 0, y: -gameInfoBar.frame.height / 1.5)
        currentTurnLabel.zPosition = 10
        currentTurnLabel.name = "currentTurnLabel"
        gameInfoBar.addChild(currentTurnLabel)

        let currentMapLabel = SKLabelNode(text: "HEX")
        currentMapLabel.fontSize = 10
        currentMapLabel.fontColor = UIColor.black
        currentMapLabel.horizontalAlignmentMode = .center
        currentMapLabel.verticalAlignmentMode = .center
        currentMapLabel.fontName = "Arial-BoldMT"

        currentMapLabel.alpha = 1.0
        currentMapLabel.isHidden = false
        currentMapLabel.position = CGPoint(x: gameInfoBar.frame.width / 4, y: -gameInfoBar.frame.height / 1.5)
        currentMapLabel.zPosition = 10
        currentMapLabel.name = "currentMapLabel"
        gameInfoBar.addChild(currentMapLabel)
    }

    private func createHelpButton(for view: SKView){
        let helpButton = SpriteButton(button: SKTexture(imageNamed: "BuildSubTab"), buttonTouched: SKTexture(imageNamed: "BuildSubTab_TouchUpInside"))
        helpButton.setButtonText(text: "?  ?")
        helpButton.setButtonTextFont(size: 24)
        helpButton.alpha = 1.0
        helpButton.isHidden = false
        helpButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        helpButton.position = CGPoint(x: -view.frame.width / 2, y: view.frame.height / 4)
        helpButton.xScale = 1
        helpButton.yScale = 1
        helpButton.zPosition = 9
        helpButton.name = "helpButton"
        self.addChild(helpButton)
    }


    //************************************ Tile construction UI Setup *******************************//

    private func createBuildTabs(for view: SKView){
        let counterBuildTab = SpriteButton(button: SKTexture(imageNamed: "BuildSubTab"), buttonTouched: SKTexture(imageNamed: "BuildSubTab_TouchUpInside"))
        counterBuildTab.alpha = 1.0
        counterBuildTab.isHidden = true
        counterBuildTab.anchorPoint = CGPoint(x: 1, y: 0.5)
        counterBuildTab.position = CGPoint(x: view.frame.width / 2, y: view.frame.height / 4)
        counterBuildTab.xScale = 1.75
        counterBuildTab.yScale = 1.75
        counterBuildTab.zPosition = 9
        counterBuildTab.name = "counterBuildTab"
        self.addChild(counterBuildTab)

        let counterBuildSymbol = SKSpriteNode(imageNamed: "Medieval_Counter")
        counterBuildSymbol.alpha = 1.0
        counterBuildSymbol.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        counterBuildSymbol.position = CGPoint(x: -counterBuildTab.frame.width / 4.25, y: 2)
        counterBuildSymbol.zPosition = 10
        counterBuildSymbol.isHidden = false
        counterBuildSymbol.xScale = 0.5
        counterBuildSymbol.yScale = 0.5
        counterBuildSymbol.name = "counterBuildSymbol"
        counterBuildTab.addChild(counterBuildSymbol)

        let counterBuildText = SKLabelNode(text: "x0")
        counterBuildText.fontSize = 16
        counterBuildText.fontColor = UIColor.white
        counterBuildText.horizontalAlignmentMode = .center
        counterBuildText.verticalAlignmentMode = .center
        counterBuildText.fontName = "Arial"

        counterBuildText.alpha = 1.0
        counterBuildText.isHidden = false
        counterBuildText.position = CGPoint(x: -counterBuildTab.frame.width / 2.25, y: 2.5)
        counterBuildText.zPosition = 12
        counterBuildText.name = "counterBuildText"
        counterBuildTab.addChild(counterBuildText)

        ///**********************************CLOSE BUILD TAB***************************///

        let closeBuildTab = SpriteButton(button: SKTexture(imageNamed: "CloseBuildSubTab"), buttonTouched: SKTexture(imageNamed: "CloseBuildSubTab_TouchUpInside"))
        closeBuildTab.alpha = 1.0
        closeBuildTab.isHidden = true
        closeBuildTab.anchorPoint = CGPoint(x: 1, y: 0.5)
        closeBuildTab.position = CGPoint(x: view.frame.width / 2 , y: counterBuildTab.position.y - counterBuildTab.frame.height * 1.35 )
        closeBuildTab.xScale = 1.75
        closeBuildTab.yScale = 1.75
        closeBuildTab.zPosition = 9
        closeBuildTab.name = "closeBuildTab"
        self.addChild(closeBuildTab)

        let closeBuildText = SKLabelNode(text: "Close")
        closeBuildText.fontSize = 16
        closeBuildText.fontColor = UIColor.white
        closeBuildText.horizontalAlignmentMode = .center
        closeBuildText.verticalAlignmentMode = .center
        closeBuildText.fontName = "Arial-BoldMT"

        closeBuildText.alpha = 1.0
        closeBuildText.isHidden = false
        closeBuildText.position = CGPoint(x: -closeBuildTab.frame.width / 3.25, y: 2.5)
        closeBuildText.zPosition = 11
        closeBuildText.name = "closeBuildText"
        closeBuildTab.addChild(closeBuildText)

        let builtTabBar = SKSpriteNode(imageNamed: "SideBar")
        builtTabBar.alpha = 1.0
        builtTabBar.isHidden = true
        builtTabBar.anchorPoint = CGPoint(x: 1, y: 0.5)
        builtTabBar.position = CGPoint(x: view.frame.width / 2, y: counterBuildTab.position.y)
        builtTabBar.zPosition = 10
        builtTabBar.name = "buildSideBar"
        self.addChild(builtTabBar)

    }

    //Toggles whether the build menu is seen or hidden.
    private func toggleBuildMenu(){
        var toggleState = false
        if self.childNode(withName: "//counterBuildTab")!.isHidden == true {
            toggleState = false
        }else{
            toggleState = true
        }
        self.childNode(withName: "//counterBuildTab")!.isHidden = toggleState
        self.childNode(withName: "//buildSideBar")!.isHidden = toggleState
        self.childNode(withName: "//closeBuildTab")!.isHidden = toggleState
    }

    //Adds symbol graphics depicting the number of a type of tile the current player can build.
    func updateBuildSymbolCount(for player:Player){

        let counterSymbol = self.childNode(withName: "//counterBuildSymbol") as! SKSpriteNode
        let newSymbol = SKAction.setTexture(SKTexture(imageNamed: "\(self.boardTileManager!.currentPlayerPiece!)"), resize: false)
        counterSymbol.run(newSymbol)
        let counterTab = self.childNode(withName: "//counterBuildText") as! SKLabelNode
        counterTab.text = String(player.availableCounters!) + "x"
    }

    //************************************ Bottom Bar UI Setup **************************************//
    private func createTurnNavigatorBar(for view: SKView){
        let turnNavigationBar = SKSpriteNode(texture: SKTexture(imageNamed: "TurnNavigatorBar"))
        turnNavigationBar.alpha = 1.0
        turnNavigationBar.name = "BottomBar"
        turnNavigationBar.isHidden = false
        turnNavigationBar.isUserInteractionEnabled = false
        turnNavigationBar.anchorPoint = CGPoint(x: 0.5, y: 0)
        if Device.allDevicesWithSensorHousing.contains(Device.current){
            turnNavigationBar.position = CGPoint(x: 0, y: -view.frame.height / 2 + 35)
        }else{
            turnNavigationBar.position = CGPoint(x: 0, y: -view.frame.height / 2 + 60)
        }
        turnNavigationBar.zPosition = 10
        self.addChild(turnNavigationBar)

        let endTurnButton = SpriteButton(button: SKTexture(imageNamed: "TurnNavigatorSubBar"), buttonTouched: SKTexture(imageNamed: "TurnNavigatorSubBar_TouchUpInside"))
        endTurnButton.setButtonText(text: "End Turn")
        endTurnButton.setButtonTextFont(size: 18)
        endTurnButton.text!.position.x -= endTurnButton.frame.width / 2
        endTurnButton.alpha = 1.0
        endTurnButton.name = "endTurnButton"
        endTurnButton.isHidden = false
        endTurnButton.anchorPoint = CGPoint(x: 1, y: 0.5)
        endTurnButton.position = CGPoint(x: turnNavigationBar.frame.width / 2 - 3, y: turnNavigationBar.frame.height / 2)
        endTurnButton.zPosition = 11
        turnNavigationBar.addChild(endTurnButton)

        let surrenderButton = SpriteButton(button: SKTexture(imageNamed: "TurnNavigatorSubBar"), buttonTouched: SKTexture(imageNamed: "TurnNavigatorSubBar_TouchUpInside"))
        surrenderButton.setButtonText(text: "Surrender")
        surrenderButton.setButtonTextFont(size: 18)
        surrenderButton.text!.position.x += surrenderButton.frame.width / 2
        surrenderButton.alpha = 1.0
        surrenderButton.name = "surrenderButton"
        surrenderButton.isHidden = false
        surrenderButton.anchorPoint = CGPoint(x: 0, y: 0.5)
        surrenderButton.position = CGPoint(x: -turnNavigationBar.frame.width / 2 + 5, y: turnNavigationBar.frame.height / 2)
        surrenderButton.zPosition = 11
        turnNavigationBar.addChild(surrenderButton)

        createConfirmationTabs(for: view, navigatorBar: turnNavigationBar)
    }

    private func createConfirmationTabs(for view: SKView, navigatorBar: SKSpriteNode){
        let surrenderPopUp = SKSpriteNode(texture: SKTexture(imageNamed: "ConfirmationTab"))
        surrenderPopUp.alpha = 1.0
        surrenderPopUp.name = "surrenderPopup"
        surrenderPopUp.isHidden = true
        surrenderPopUp.anchorPoint = CGPoint(x: 0, y: 0)
        surrenderPopUp.position = CGPoint(x: -navigatorBar.frame.width / 2 + 20, y: navigatorBar.frame.height / 2)
        surrenderPopUp.zPosition = 9
        navigatorBar.addChild(surrenderPopUp)

        let confirmSurrenderButton = SpriteButton(button: SKTexture(imageNamed: "ConfirmEndTurn"), buttonTouched: SKTexture(imageNamed: "ConfirmEndTurn_TouchUpInside"))
        confirmSurrenderButton.setButtonText(text: "Confirm")
        confirmSurrenderButton.setButtonTextFont(size: 20)
        confirmSurrenderButton.text!.position.y += confirmSurrenderButton.frame.height / 2
        confirmSurrenderButton.alpha = 1.0
        confirmSurrenderButton.name = "confirmSurrenderButton"
        confirmSurrenderButton.isHidden = true
        confirmSurrenderButton.anchorPoint = CGPoint(x: 0.5, y: 0)
        confirmSurrenderButton.position = CGPoint(x: surrenderPopUp.frame.width / 2, y: surrenderPopUp.frame.height / 2.5)
        confirmSurrenderButton.zPosition = 9
        surrenderPopUp.addChild(confirmSurrenderButton)

        let endTurnPopUp = SKSpriteNode(texture: SKTexture(imageNamed: "ConfirmationTab"))
        endTurnPopUp.alpha = 1.0
        endTurnPopUp.name = "endTurnPopup"
        endTurnPopUp.isHidden = true
        endTurnPopUp.anchorPoint = CGPoint(x: 1.0, y: 0)
        endTurnPopUp.position = CGPoint(x: navigatorBar.frame.width / 2 - 15, y: navigatorBar.frame.height / 2)
        endTurnPopUp.zPosition = 9
        navigatorBar.addChild(endTurnPopUp)

        let confirmEndTurnButton = SpriteButton(button: SKTexture(imageNamed: "ConfirmEndTurn"), buttonTouched: SKTexture(imageNamed: "ConfirmEndTurn_TouchUpInside"))
        confirmEndTurnButton.setButtonText(text: "Confirm")
        confirmEndTurnButton.setButtonTextFont(size: 20)
        confirmEndTurnButton.text!.position.y += confirmSurrenderButton.frame.height / 2
        confirmEndTurnButton.alpha = 1.0
        confirmEndTurnButton.name = "confirmEndTurnButton"
        confirmEndTurnButton.isHidden = true
        confirmEndTurnButton.anchorPoint = CGPoint(x: 0.5, y: 0)
        confirmEndTurnButton.position = CGPoint(x: -endTurnPopUp.frame.width / 2, y: endTurnPopUp.frame.height / 2.5)
        confirmEndTurnButton.zPosition = 9
        endTurnPopUp.addChild(confirmEndTurnButton)

    }

    private func createGameNotificationLabel(for view: SKView){
        let gameNotificationIndicator = SKLabelNode(text: "")
        gameNotificationIndicator.fontSize = 36
        gameNotificationIndicator.fontColor = UIColor.black
        gameNotificationIndicator.horizontalAlignmentMode = .center
        gameNotificationIndicator.verticalAlignmentMode = .center
        gameNotificationIndicator.fontName = "Arial-BoldMT"

        gameNotificationIndicator.alpha = 1
        gameNotificationIndicator.isHidden = true
        gameNotificationIndicator.position = CGPoint(x: 0 , y: 0)
        gameNotificationIndicator.zPosition = 20
        gameNotificationIndicator.name = "gameNotification"
        gameNotificationIndicator.isUserInteractionEnabled = false
        self.addChild(gameNotificationIndicator)
    }

    private func getNameFromColor(color: UIColor) -> String{
        switch color{
        case UIColor.red:
            return "Red"
        case UIColor.blue:
            return "Blue"
        case UIColor.brown:
            return  "Brown"
        case UIColor.cyan:
            return "Cyan"
        case UIColor.green:
            return "Green"
        case UIColor.magenta:
            return "Magenta"
        case UIColor.orange:
            return "Orange"
        case UIColor.purple:
            return "Purple"
        case UIColor.yellow:
            return "Yellow"
        default:
            return "MeowErrer"
        }
    }

    private func updateCurrentPlayer(player: Player){
        self.currentActivePlayer = player
        let nameIndicator = self.childNode(withName: "//currentPlayerLabel") as! SKLabelNode
        nameIndicator.text = "Player \(player.playerId)"
        nameIndicator.fontColor = player.color

        let currentIndicatorSymbol = self.childNode(withName: "//counterIndicatorSymbol") as! SKSpriteNode
        currentIndicatorSymbol.texture = SKTexture(imageNamed: "\(self.boardTileManager!.currentPlayerPiece!)")
    }


    //*********************************** User Interaction Handling *************************************//
    @objc func handlePan(_ sender: UIPanGestureRecognizer){
        switch sender.state {
            case .began:
                 break
            case .changed:
                self.modifyConstraints(for: sender)
                break
            case .ended:
                break
        default:
                break
        }

    }

    //Don't even ask....
    func modifyConstraints(for sender:UIPanGestureRecognizer?){
        var moved:CGPoint = CGPoint.zero
        if sender != nil {
            moved = sender!.translation(in: (self.parent as! SKScene).view!)
        }
            let oldPosition = self.position
            let moveModifier = self.xScale
            let newPosition = CGPoint(x: oldPosition.x - (moved.x * moveModifier), y: oldPosition.y + (moved.y * moveModifier))

            //Right Bound and Left bound respectively
            let boardRect = self.boardTileManager!.mainBoardMap!.calculateAccumulatedFrame()
            let scaledSize = CGSize(width: self.scene!.size.width * self.xScale, height: self.scene!.size.height * self.yScale)

            let xInset = min((scaledSize.width / 2.5), (boardRect.width / 2))
            let yInset = min((scaledSize.height / 2.75), (boardRect.height / 2))

            let insetContentRect = boardRect.insetBy(dx: xInset, dy: yInset)
            let xRange = SKRange(lowerLimit: insetContentRect.minX - 300 / self.xScale, upperLimit: insetContentRect.maxX + 300 / self.xScale)
            let yRange = SKRange(lowerLimit: insetContentRect.minY - 400 / self.yScale, upperLimit: insetContentRect.maxY + 300 / self.yScale)

            let levelEdgeConstraint = SKConstraint.positionX(xRange, y: yRange)
            levelEdgeConstraint.referenceNode = self.boardTileManager!.mainBoardMap!

            self.constraints = [levelEdgeConstraint]

            self.position = newPosition

            if sender != nil{
                sender!.setTranslation(CGPoint.zero, in: self.scene!.view)
            }
    }

    @objc func handleZoom(_ sender: UIPinchGestureRecognizer){
        switch sender.state {
            case .began:
                break
            case .changed:
                let pinch = sender.scale
                if pinch < 1 {
                    let newScale = self.xScale / pinch
                    if newScale < maxZoomOut {
                        self.setScale(newScale)
                    }
                }else{
                    let newScale = self.xScale / pinch
                    if newScale > maxZoomIn {
                        self.setScale(newScale)
                    }
                }
                self.modifyConstraints(for: nil)
                sender.scale = 1.0
                break
            case .ended:
                break
            default:
                break
        }
    }

    @objc func handleMenuTap(_ sender: UITapGestureRecognizer){
        if (self.scene as! GameScene).gameIsOver == true {
            (self.scene as! GameScene).parentViewController?.presentGameOver()
        }

        let tapped = sender.location(in: self.scene?.view)
        let scenelocation = self.scene!.convertPoint(fromView: tapped)
        let cameralocation = self.convert(scenelocation, from: self.scene!)

        //If the game freezes we want the player to be able to surrender.
        if ((self.scene as! GameScene).gameModel!.activePlayer! as! Player).isPlayerHuman! == false {
            let touchedNodes = self.nodes(at: cameralocation)
            if touchedNodes.isEmpty == false{
                for button in touchedNodes{
                    if let buttonName = button.name {
                        switch buttonName {
                        case "surrenderButton":
                            if self.tapSoundMaker != nil {
                                self.tapSoundMaker!.run(SKAction.play())
                            }
                            (button as! SpriteButton).buttonTouchedUpInside(){
                                if self.childNode(withName: "//confirmSurrenderButton")?.isHidden == true {
                                    self.childNode(withName: "//surrenderPopup")?.isHidden = false
                                    self.childNode(withName: "//confirmSurrenderButton")?.isHidden = false
                                }else{
                                    self.childNode(withName: "//confirmSurrenderButton")?.isHidden = true
                                    self.childNode(withName: "//surrenderPopup")?.isHidden = true
                                }
                            }
                            return
                        case "confirmSurrenderButton":
                            if self.tapSoundMaker != nil {
                                self.tapSoundMaker!.run(SKAction.play())
                            }
                            if self.childNode(withName: "//confirmSurrenderButton")?.isHidden == false{
                                (button as! SpriteButton).buttonTouchedUpInside(){
                                    for player in self.boardTileManager!.gameModel!.players as! [Player] {
                                        if player.isPlayerHuman == true {
                                            if GameState.sharedInstance().numHumanPlayers == 1 {
                                                self.boardTileManager!.resetColorationTileGroups()
                                                (self.scene as! GameScene).parentViewController?.presentGameOver()
                                                (self.scene as! GameScene).gameIsOver = true
                                            }else{
                                                (self.boardTileManager!.gameModel!.activePlayer! as! Player).numberOfCrowns = 0
                                                (self.boardTileManager!.gameModel!.activePlayer! as! Player).crown_Locations = []
                                                (self.boardTileManager!.gameModel!.activePlayer! as! Player).crownHealth = 0
                                                (self.boardTileManager!.mainBoardMap!.scene as! GameScene).advanceTurnToNextPlayer()
                                                (self.boardTileManager!.mainBoardMap!.scene as! GameScene).checkForPlayerLosing()
                                                self.childNode(withName: "//surrenderPopup")?.isHidden = true
                                                self.childNode(withName: "//confirmSurrenderButton")?.isHidden = true
                                            }
                                            return
                                        }
                                    }
                                    self.boardTileManager!.resetColorationTileGroups()
                                    (self.scene as! GameScene).parentViewController?.presentGameOver()
                                }
                            }
                            return
                        default:
                            return
                        }
                    }
                }
            }
            return
        }

        let touchedNodes = self.nodes(at: cameralocation)
        if touchedNodes.isEmpty == false{
            for button in touchedNodes {
                if let buttonName = button.name {
                    switch buttonName {
                    case "surrenderButton":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            if self.childNode(withName: "//confirmSurrenderButton")?.isHidden == true {
                                self.childNode(withName: "//surrenderPopup")?.isHidden = false
                                self.childNode(withName: "//confirmSurrenderButton")?.isHidden = false
                            }else{
                                self.childNode(withName: "//confirmSurrenderButton")?.isHidden = true
                                self.childNode(withName: "//surrenderPopup")?.isHidden = true
                            }
                        }
                        return
                    case "confirmSurrenderButton":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        if self.childNode(withName: "//confirmSurrenderButton")?.isHidden == false{
                            (button as! SpriteButton).buttonTouchedUpInside(){
                                for player in self.boardTileManager!.gameModel!.players as! [Player] {
                                    if player.isPlayerHuman == true {
                                        if GameState.sharedInstance().numHumanPlayers == 1 {
                                            self.boardTileManager!.resetColorationTileGroups()
                                            (self.scene as! GameScene).parentViewController?.presentGameOver()
                                            (self.scene as! GameScene).gameIsOver = true
                                        }else{
                                            (self.boardTileManager!.gameModel!.activePlayer! as! Player).numberOfCrowns = 0
                                            (self.boardTileManager!.gameModel!.activePlayer! as! Player).crown_Locations = []
                                            (self.boardTileManager!.gameModel!.activePlayer! as! Player).crownHealth = 0
                                            (self.boardTileManager!.mainBoardMap!.scene as! GameScene).advanceTurnToNextPlayer()
                                            (self.boardTileManager!.mainBoardMap!.scene as! GameScene).checkForPlayerLosing()
                                            self.childNode(withName: "//surrenderPopup")?.isHidden = true
                                            self.childNode(withName: "//confirmSurrenderButton")?.isHidden = true
                                        }
                                        return
                                    }
                                }
                                self.boardTileManager!.resetColorationTileGroups()
                                (self.scene as! GameScene).parentViewController?.presentGameOver()
                            }
                        }
                        return
                    case "endTurnButton":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            if self.childNode(withName: "//confirmEndTurnButton")?.isHidden == true {
                                self.childNode(withName: "//endTurnPopup")?.isHidden = false
                                self.childNode(withName: "//confirmEndTurnButton")?.isHidden = false
                            }else{
                                self.childNode(withName: "//confirmEndTurnButton")?.isHidden = true
                                self.childNode(withName: "//endTurnPopup")?.isHidden = true
                            }
                        }
                        return
                    case "confirmEndTurnButton":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        if self.childNode(withName: "//confirmEndTurnButton")?.isHidden == false{
                            (button as! SpriteButton).buttonTouchedUpInside(){
                                (self.scene! as! GameScene).advanceTurnToNextPlayer()
                                self.childNode(withName: "//confirmEndTurnButton")?.isHidden = true
                                self.childNode(withName: "//endTurnPopup")?.isHidden = true
                            }
                        }
                        return
                    case "endTurnPopup":
                        return
                    case "crownIndicator":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            self.focusCameraOnCrownTile()
                        }
                        return
                    case "counterBuildSymbol":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (self.childNode(withName: "//counterBuildTab") as! SpriteButton).buttonTouchedUpInside() {
                            if self.boardTileManager != nil {
                                if self.currentActivePlayer != nil {
                                    let tileGroups = self.boardTileManager!.mainBoardMap!.tileSet.tileGroups
                                    let tileToSet = tileGroups.first(where: { $0.name!.contains("\(self.boardTileManager!.currentPlayerPiece!)Player\(self.currentActivePlayer!.playerId)") })
                                    self.boardTileManager!.handleBuildingOnTile(tileToBuild: tileToSet!, currentPlayer: self.currentActivePlayer!)
                                }
                            }
                        }
                        return
                    case "counterBuildTab":
                        return
                    case "closeBuildTab", "closeBuildText":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (self.childNode(withName: "//closeBuildTab") as! SpriteButton).buttonTouchedUpInside() {
                            if self.childNode(withName: "//counterBuildTab")!.isHidden == true {
                                self.toggleBuildMenu()
                                self.childNode(withName: "//BottomBar")!.isHidden = true
                            } else {
                                self.toggleBuildMenu()
                                self.childNode(withName: "//BottomBar")!.isHidden = false
                                self.boardTileManager!.unhighlightSelectedTile()
                            }
                        }
                        return
                    case "helpButton":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (self.childNode(withName: "//helpButton") as! SpriteButton).buttonTouchedUpInside() {
                            (self.scene as! GameScene).parentViewController?.showTutorial()
                        }
                        return
                    default:
                        //handleTileManagerTileTap(sender)
                        break
                    }
                }else{
                    handleTileManagerTileTap(sender)
                }
            }
        }else{
            handleTileManagerTileTap(sender)
        }
    }

    private func handleTileManagerTileTap(_ sender: UITapGestureRecognizer){
        // Checks if a valid tile was tapped and returns if it was or not
        if boardTileManager!.handleTileTap(sender, player: self.boardTileManager!.gameModel!.activePlayer! as! Player){
            if self.childNode(withName: "//counterBuildTab")!.isHidden == true{
                self.toggleBuildMenu()
            }
            self.childNode(withName: "//BottomBar")!.isHidden = true
        }else{
            if self.childNode(withName: "//counterBuildTab")!.isHidden == false{
                self.toggleBuildMenu()
            }
            self.childNode(withName: "//BottomBar")!.isHidden = false
        }
    }

    func focusCameraOnCrownTile(){
        let focusScale:CGFloat = 1.5
        let focusTime:Double = 0.75

        //Convert all the crown positions from tile coordinates to screen coordinates
        let convertedPoints = self.currentActivePlayer!.crown_Locations!.map({ val-> CGPoint in
            let realLocation = self.boardTileManager!.mainBoardMap!.centerOfTile(atColumn: Int(val.x), row: Int(val.y))
            return self.scene!.convert(realLocation, from: self.boardTileManager!.mainBoardMap!)
        })

        //During course of the game, a player crown can be destroyed, but would be retained in this array.
        self.previousCrownFocused = self.previousCrownFocused.filter({
            return convertedPoints.contains($0)
        })

        for crown in convertedPoints {
            if previousCrownFocused.contains(crown) == false{
                self.run(SKAction.group([SKAction.scale(to: focusScale, duration: focusTime),SKAction.move(to: crown, duration: focusTime)]))

                previousCrownFocused.append(crown)
                if previousCrownFocused.count > self.currentActivePlayer!.crown_Locations!.count - 1 {
                    previousCrownFocused = []
                }
                return
            }
        }
    }

    override func encode(with aCoder: NSCoder){
        aCoder.encodeConditionalObject(self.currentActivePlayer!, forKey: "CameraWithUI_currentActivePlayer")
        super.encode(with: aCoder)
    }

    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        if let data = aDecoder.decodeObject(forKey: "CameraWithUI_currentActivePlayer") as? Player {
            self.currentActivePlayer = data
        }
    }
}