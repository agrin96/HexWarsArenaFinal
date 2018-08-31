//
//  GameScene.swift
//  HexWars
//
//  Created by Aleksandr Grin on 8/5/17.
//  Copyright © 2017 AleksandrGrin. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import GameplayKit

// Tile construction will follow a ratio system. You use counters to claim land which allows us to build level 1 tiles.
//  level 1 tiles allow construction of level 2 in a 2-1 ratio and level 2 allows construction of level 3.
//  level 3 tiles give the player more counters to deploy in the field.
struct TileConstructionRatios {
    var level0_RequiredForLevel1:Int = 1
    var level1_RequiredForLevel2:Int = 2
    var level2_RequiredForLevel3:Int = 2
    var level3_RequiredForCounter:Int = 1
}

var tileConstructionRatios:TileConstructionRatios = TileConstructionRatios()

class GameScene: SKScene {
    weak var parentViewController:GameViewController? = nil
    weak var gameCameraAndUI:CameraWithUI? = nil

    var strategist:GKMinmaxStrategist? = nil
    var gameModel:GameModel? = nil
    var gameTileManager:BoardTileManager? = nil

    var gamePlayers:Array<Player>? = nil
    var currentActivePlayer:Player? = nil   //Used at the games initialization, but then its functions are taken over by the GameModel
    var difficulty:Difficulty? = nil
    var currentTurn:Int = 0
    var gameDidBegin:Bool = false
    var gameIsOver:Bool = false

    override init(size: CGSize){
        super.init(size: size)
    }

    override func didMove(to view: SKView) {
        if GameState.sharedInstance().wasGameSaved == false {
            //Setup the gameTile Manager.
            self.gameTileManager = setupMapAndPlayers()
            self.gameTileManager!.setupColorationTileGroups(for: gamePlayers!)

            //Set up the strategsist for the AI
            self.strategist = GKMinmaxStrategist()
            self.strategist!.maxLookAheadDepth = 1
            self.strategist!.randomSource = GKARC4RandomSource()


            //Setup Camera and UI for the game.
            let newCamera = CameraWithUI(in: self.view!)
            newCamera.boardTileManager = gameTileManager!
            self.gameCameraAndUI = newCamera
            self.camera = newCamera
            self.addChild(newCamera)
            self.gameCameraAndUI!.activateSound()
            self.gameCameraAndUI!.updateUIColor(for: GameState.sharedInstance().mainPlayerOptions!.chosenPlayerColor!.getColorFromCode())
            self.addGestureRecognizers(for: newCamera)

            self.difficulty = GameState.sharedInstance().mainPlayerOptions!.chosenDifficulty!

            beginGame()
        }else{
            self.strategist!.gameModel = self.gameModel!
            self.gameTileManager!.gameModel = self.gameModel
            self.gameCameraAndUI = self.camera! as? CameraWithUI
            self.gameCameraAndUI!.boardTileManager = self.gameTileManager!

            self.addGestureRecognizers(for: self.gameCameraAndUI!)
            self.gameTileManager!.updateTileWalls(for: nil)
        }
    }

    func advanceTurnToNextPlayer(){
        self.gameModel!.updateAvailableTilesToBuild(for: self.gameModel!.activePlayer! as! Player, difficulty: self.difficulty!)
        self.gameTileManager!.upgradeExistingPlayerTiles(for: self.gameModel!.activePlayer! as! Player)

        DispatchQueue.global().sync { [unowned self] in
            self.gameTileManager!.updateTileWalls(for: nil)   //FindAdjacencyGroups() is called inside here as necessary for the following destroy() function.
            self.gameTileManager!.destroyNonAdjacentTiles()
            self.gameTileManager!.resetTileWallLayer()
        }

        if self.gameModel!.activePlayer != nil{
            if self.gameModel!.players!.count != 1 {
                for player in self.gameModel!.players!{
                    if (player as! Player).playerId == (self.gameModel!.activePlayer! as! Player).playerId{
                        let index = Int(self.gameModel!.players!.index(where: {($0 as! Player) == (player as! Player)})!)
                        if index < self.gameModel!.players!.count - 1{
                            self.gameModel!.activePlayer! = self.gameModel!.players![index + 1]
                            self.gameCameraAndUI!.updatePlayerTurnLabel(for: self.gameModel!.activePlayer! as! Player)
                            if (self.gameModel!.activePlayer! as! Player).isPlayerHuman == false {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    if self.gameIsOver == false {
                                        self.startAIMove()
                                    }
                                }
                            }else{
                                self.gameCameraAndUI!.updateUIColor(for: (self.gameModel!.activePlayer! as! Player).color!)
                            }
                            return
                        }else{
                            self.currentTurn += 1
                            self.gameModel!.activePlayer! = self.gameModel!.players!.first!
                            self.gameCameraAndUI!.updatePlayerTurnLabel(for: self.gameModel!.activePlayer! as! Player)
                            if let turnLabel = gameCameraAndUI!.childNode(withName: "//currentTurnLabel") as? SKLabelNode {
                                turnLabel.text = "Turn: \(self.currentTurn)"
                            }
                            if (self.gameModel!.activePlayer! as! Player).isPlayerHuman == false {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    if self.gameIsOver == false {
                                        self.startAIMove()
                                    }
                                }
                            }else{
                                self.gameCameraAndUI!.updateUIColor(for: (self.gameModel!.activePlayer! as! Player).color!)
                            }
                            return
                        }
                    }
                }
            }
        }
    }

    private func beginGame(){
        // Set the first player to active
        if let playerOne = gamePlayers!.first{
            currentActivePlayer = playerOne
            currentTurn = 1
        }else{
            print("FATAL ERROR NO PLAYERS AT START \(#function)")
        }

        //Show a label indicating it is the first player's turn
        if gameCameraAndUI != nil{
            gameCameraAndUI!.updatePlayerTurnLabel(for: currentActivePlayer!)
        }else{
            print("FATAL ERROR NO CAMERA \(#function)")
        }

        //Creat the gamemodel and set it for the strategist
        self.gameModel = GameModel(tileMap: self.gameTileManager!.initializeGameModel(), players: (self.gamePlayers! as [GKGameModelPlayer]))
        self.gameModel!.activePlayer = self.currentActivePlayer!
        self.gameModel!.difficulty = self.difficulty!       //Set the difficulty of the game.
        self.gameTileManager!.gameModel = self.gameModel!   //Add a weak reference for the tile manager.
        self.strategist!.gameModel = self.gameModel

        //Update data initially for all players indicating how many of each tile they have.
        for player in gamePlayers!{
            if gameTileManager != nil{
                self.gameModel!.updateAmountOfTiles(for: player)
                self.gameModel!.updateAvailableTilesToBuild(for: player, difficulty: self.difficulty!)
            }else{
                print("FATAL ERROR NO TILE MANAGER \(#function)")
            }
        }
        //Sets the initial Walls
        self.gameTileManager!.initTileWallTextures(for: GameState.sharedInstance().mainPlayerOptions!.chosenWallType!)
        self.gameTileManager!.createCrownHealth()
        self.gameTileManager!.updateTileWalls(for: nil)

        //Check if this game is singleplayer and if we are tracking stats.
        if GameState.sharedInstance().numHumanPlayers! > 1 {
            GameState.sharedInstance().playerStatistics!.isGameBeingTracked = false
        }else{
            GameState.sharedInstance().playerStatistics!.isGameBeingTracked = true
        }

        //Preparation for game beginning complete so we begin
        gameDidBegin = true
        initPlayerDataValues()
        gameCameraAndUI!.updateIndicatorLabels(for: self.gameModel!.activePlayer! as! Player)
    }

    private func createAndAddPlayers(for gameState: GameState, crowns:Array<CGPoint>){
        let numberOfPlayers = gameState.currentGameMap!.numPlayers!
        var numHumanPlayers = gameState.numHumanPlayers! - 1
        var arrayOfCrowns = crowns
        self.gamePlayers = []

        //For the human!
        let colorForPlayer = gameState.mainPlayerOptions!.chosenPlayerColor!.getColorFromCode()
        var crownsToAdd:Array<CGPoint> = []

        let newCrown = arrayOfCrowns.randomItem()
        let convertedCrownToTileMap = CGPoint(x: Int(newCrown!.y), y: gameState.currentGameMap!.mapBounds!.rows - 1 - Int(newCrown!.x))
        crownsToAdd.append(convertedCrownToTileMap)
        let index = arrayOfCrowns.index(of: newCrown!)
        arrayOfCrowns.remove(at: index!)

        let newHumanPlayer = Player(color: colorForPlayer, name: "Human", ID: 1, crowns: crownsToAdd, isHuman: true)
        //Assign the human player the piece that they selected
        newHumanPlayer.gameTheme = gameState.mainPlayerOptions!.chosenGameTheme!
        self.gamePlayers!.append(newHumanPlayer)


        var colorCode = 0
        for iD in 1..<numberOfPlayers{
            if PlayerColor(rawValue: colorCode) == gameState.mainPlayerOptions!.chosenPlayerColor! {
                colorCode += 1
            }
            let colorForComputer = getColorFromCode(code: PlayerColor(rawValue: colorCode)!)
            crownsToAdd = []

            let newCrown = arrayOfCrowns.randomItem()
            let convertedCrownToTileMap = CGPoint(x: Int(newCrown!.y), y: gameState.currentGameMap!.mapBounds!.rows - 1 - Int(newCrown!.x))
            crownsToAdd.append(convertedCrownToTileMap)
            let index = arrayOfCrowns.index(of: newCrown!)
            arrayOfCrowns.remove(at: index!)

            if numHumanPlayers > 0 {
                let newHumanPlayer = Player(color: colorForComputer, name: "Human", ID: iD + 1, crowns: crownsToAdd, isHuman: true)
                //Randomly choose a piece type for the computer player based on whether use has full piece roster or not
                newHumanPlayer.gameTheme! = gameState.mainPlayerOptions!.chosenGameTheme!
                self.gamePlayers!.append(newHumanPlayer)
                numHumanPlayers -= 1
                print(numHumanPlayers)
            }else{
                let newComputerPlayer = Player(color: colorForComputer, name: "Computer", ID: iD + 1, crowns: crownsToAdd, isHuman: false)
                //Randomly choose a piece type for the computer player based on whether use has full piece roster or not
                newComputerPlayer.gameTheme! = gameState.mainPlayerOptions!.chosenGameTheme!
                self.gamePlayers!.append(newComputerPlayer)
            }

            colorCode += 1
        }

    }
    //Returns the taxi cab distance between two points A and B.
    private func taxiCabDistanceFor(locA: CGPoint, locB: CGPoint) -> Int{
        return Int(abs(locA.x - locB.x) + abs(locA.y - locB.y))
    }

    //Run inside the update function to recalculate player tile amounts.
    private func initPlayerDataValues(){
        if self.gameModel!.players != nil{
            for player in self.gameModel!.players! as! [Player]{
                self.gameModel!.updateAmountOfTiles(for: player)
            }
        }
    }

    private func getColorFromCode(code: PlayerColor) -> UIColor{
        switch code{
            case .red:
                return UIColor.red
            case .blue:
                return UIColor.blue
            case .brown:
                return  UIColor.brown
            case .cyan:
                return UIColor.cyan
            case .green:
                return UIColor.green
            case .magenta:
                return UIColor.magenta
            case .orange:
                return UIColor.orange
            case .purple:
                return UIColor.purple
            case .yellow:
                return UIColor.yellow
        }
    }

    private func setupMapAndPlayers() -> BoardTileManager{
        let gameMapModel = GameBoardModel()
        var mapCrownLocations:Array<CGPoint> = []
        let newTileMap = BoardTileManager()
        newTileMap.gameModel = self.gameModel    //Give a reference of the GameModel to the TileManager.

        if GameState.sharedInstance().mainPlayerOptions!.isGamePreset == false {

            gameMapModel.createRandomTileMapModel(mapDescription: GameState.sharedInstance().currentGameMap!) //Creates a 2D array representing a tileMap
            mapCrownLocations = getCrownLocationsOnMap(boardModel: gameMapModel.boardModel!)    //Extracts the crown locations from the map
            newTileMap.initializeBoardMapFor(model: gameMapModel.boardModel!, mapDescription: GameState.sharedInstance().currentGameMap!)

        }else{
            //We have chosen a presetMap and should load that.

            mapCrownLocations = getCrownLocationsOnMap(boardModel: GameState.sharedInstance().currentGameMap!.gameMapModel!)
            newTileMap.initializeBoardMapFor(model: GameState.sharedInstance().currentGameMap!.gameMapModel!, mapDescription: GameState.sharedInstance().currentGameMap!)
        }

        self.addChild(newTileMap.mainBoardMap!)
        self.addChild(newTileMap.tileSelectionBoardMap!)
        self.addChild(newTileMap.tileWallingBoardMap!)

        createAndAddPlayers(for: GameState.sharedInstance(),crowns: mapCrownLocations)

        return newTileMap
    }

    //Used to setup the players by pulling unassigned crown locations from the generated map.
    private func getCrownLocationsOnMap(boardModel: [[TileTypes]]) -> Array<CGPoint>{
        var crownLocations:Array<CGPoint> = []
        for row in 0..<boardModel.count {
            for col in 0..<boardModel[row].count {
                if boardModel[row][col] == .crown {
                    crownLocations.append(CGPoint(x: row, y: col))
                }
            }
        }
        return crownLocations
    }

    func checkForPlayerLosing(){
        if self.gameModel!.players != nil {
            for player in self.gameModel!.players as! [Player] {
                if player.numberOfCrowns! == 0 {
                    if GameState.sharedInstance().numHumanPlayers! == 1 && player.isPlayerHuman == true && self.gameIsOver == false{
                        self.gameIsOver = true
                        self.parentViewController!.presentGameOver()
                    }
                    self.gameCameraAndUI!.displayGameNotification(text: "Player \(player.playerId) \nhas been defeated!", textColor: player.color!){}
                    if let index = self.gameModel!.players!.index(where: {($0 as! Player) == player}){
                        self.gameModel!.players!.remove(at: index)
                    }
                }
            }

            if self.gameModel!.players!.count == 1 {
                self.gameIsOver = true
                self.gameCameraAndUI!.displayGameNotification(text: "Player \((self.gameModel!.players!.first! as! Player).playerId) has won!", textColor: (self.gameModel!.players!.first! as! Player).color!){}
                self.gameCameraAndUI!.displayGameNotification(text: "Tap to Finish", textColor: .black){}
            }
        }
    }

    private func addGestureRecognizers(for camera: CameraWithUI){
        let panMap = UIPanGestureRecognizer(target: camera, action: #selector(camera.handlePan))
        self.scene?.view?.addGestureRecognizer(panMap)
        panMap.delegate = camera

        let zoomMap = UIPinchGestureRecognizer(target: camera, action: #selector(camera.handleZoom))
        self.scene?.view?.addGestureRecognizer(zoomMap)
        zoomMap.delegate = camera

        let menuButtonRecognizer = UITapGestureRecognizer(target: camera, action: #selector(camera.handleMenuTap))
        self.scene?.view?.addGestureRecognizer(menuButtonRecognizer)
        menuButtonRecognizer.delegate = camera
    }

    func tileForAIMove() -> (tile: SKTileGroup, position:CGPoint)?{
        if let aiMove = self.strategist!.bestMove(for: self.gameModel!.activePlayer! as GKGameModelPlayer) as? Move {
            if self.gameIsOver == true { return nil }
            switch aiMove.tileToPlace {
            case .counter:
                guard let tileGroup = self.gameTileManager!.mainBoardMap!.tileSet.tileGroups.first(where: {$0.name! == "\(self.gameTileManager!.currentPlayerPiece!)Player\(self.gameModel!.activePlayer!.playerId)"}) else{
                   print("FATAL ERROR NO TILE GROUP FOUND IN \(#function)"); return nil
                }
                return (tileGroup, aiMove.position)
            default:
                break
            }
        }else{
            return nil //There are no more valid moves to be made right now. Which means turn should advance.
        }

        return nil //Just in case
    }

    func makeAIMove(with tile:SKTileGroup, position: CGPoint){
        if self.gameIsOver == true { return }
        self.gameTileManager!.currentTileToOperateOn = position
        self.gameTileManager!.handleBuildingOnTile(tileToBuild: tile, currentPlayer: self.gameModel!.activePlayer! as! Player)
    }

    func startAIMove() {
        if self.gameIsOver == true { return }
        DispatchQueue.global().async {
            while let move = self.tileForAIMove() {
                DispatchQueue.main.sync {
                    if self.gameIsOver == true { return }
                    self.makeAIMove(with: move.tile, position: move.position)
                    //Keep going until all the moves for this possible turn are made.

                    if let currentPlayer = self.gameModel!.activePlayer! as? Player {
                        if currentPlayer.availableCounters! == 0{
                            //No valid moves left so we transition to next player.
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){ [unowned self] in
                                self.advanceTurnToNextPlayer()
                            }
                        }
                    }
                }
            }
        }
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }

    override func encode(with aCoder: NSCoder){
        super.encode(with: aCoder)
        aCoder.encode(self.gameModel!, forKey: "GameScene_gameModel")
        aCoder.encode(self.gameTileManager!, forKey: "GameScene_gameTileManager")

        aCoder.encode(self.gamePlayers!, forKey: "GameScene_gamePlayers")
        aCoder.encode(self.currentActivePlayer!, forKey: "GameScene_currentActivePlayer")
        aCoder.encode(self.difficulty!.rawValue, forKey: "GameScene_difficulty")
        aCoder.encode(self.currentTurn, forKey: "GameScene_currentTurn")
        aCoder.encode(self.gameDidBegin, forKey: "GameScene_gameDidBegin")
        aCoder.encode(self.gameIsOver, forKey: "GameScene_gameisOver")
    }

    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        self.strategist = GKMinmaxStrategist()
        self.strategist!.maxLookAheadDepth = 1
        self.strategist!.randomSource = GKARC4RandomSource()

        if let data = aDecoder.decodeObject(forKey: "GameScene_gameModel") as? GameModel{
            self.gameModel = data
        }
        if let data = aDecoder.decodeObject(forKey: "GameScene_gameTileManager") as? BoardTileManager{
            self.gameTileManager = data
        }
        if let data = aDecoder.decodeObject(forKey: "GameScene_gamePlayers") as? [Player]{
            self.gamePlayers = data
        }
        if let data = aDecoder.decodeObject(forKey: "GameScene_currentActivePlayer") as? Player {
            self.currentActivePlayer = data
        }
        let data = aDecoder.decodeInteger(forKey: "GameScene_difficulty")
        self.difficulty = Difficulty(rawValue: data)!

        self.currentTurn = aDecoder.decodeInteger(forKey: "GameScene_currentTurn")
        self.gameDidBegin = aDecoder.decodeBool(forKey: "GameScene_gameDidBegin")
        self.gameIsOver = aDecoder.decodeBool(forKey: "GameScene_gameisOver")
    }
}
