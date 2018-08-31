//
//  GameOptions.swift
//  HexWars
//
//  Created by Aleksandr Grin on 10/5/17.
//  Copyright © 2017 AleksandrGrin. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

// These enums represent the various possibilites for the options menu
enum Difficulty: Int {
    case easy = 0
    case medium
    case hard
    case unfair1
    case unfair2
}

enum GameTheme: Int {
    case medieval = 0
    case scifi
    case modern

    func themeName()->String {
        switch self {
            case .medieval:
                return "Medieval"
            case .scifi:
                return "Scifi"
            case .modern:
                 return "Modern"
        }
    }
}

enum PlayerColor: Int {
    case red = 0
    case blue
    case green
    case yellow
    case purple
    case orange
    case cyan
    case magenta
    case brown

    func getColorFromCode() -> UIColor{
        switch self{
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
}

enum SoundToggle: Int{
    case soundOff = 0
    case soundOn
}

// The following data is for representing the custom game menu screen
enum MapFillType: Int {
    case pangea = 0
    case continents
    case islands
    case fractured
}

class GameState: NSObject, NSCoding {
    //Singleton to access the game state
    private static let sharedGameState:GameState = loadGameState()

    //To see if we need to unpack the GameScene
    var wasGameSaved:Bool? = false

    var mainPlayerOptions: GameOptions?
    var numHumanPlayers:Int?
    var currentGameMap:GameMap?
    var playerStatistics:GameStatistics?
    var savedMaps:Array<GameMap> = []   //Doesn't need to be encoded, simply reconstructed every time.

    override private init(){
        super.init()
        //Defualt initialization used in the MainScreen()
        self.mainPlayerOptions = GameOptions()
        self.numHumanPlayers = 1
        self.currentGameMap = GameMap()
        self.playerStatistics = GameStatistics()
        self.savedMaps = []
        self.addPresetMaps()
    }

    //Retrieve the Game State from a file or return a totally new GameState
    private class func loadGameState() -> GameState{
        if let data = NSKeyedUnarchiver.unarchiveObject(withFile: stateFilePath) as? GameState{
            return data
        }else{
            return GameState()
        }
    }

    class func saveGameState() {
        NSKeyedArchiver.archiveRootObject(GameState.sharedInstance(), toFile: stateFilePath)
    }

    class func sharedInstance() -> GameState {
        return self.sharedGameState
    }

    func resetCurrentMap(){
        self.mainPlayerOptions!.isGamePreset = false
        self.currentGameMap = GameMap()
    }

    func addPresetMaps(){
        let map1 = GameMap()
        let mapArray = [[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
                        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
                        [0,0,0,0,1,1,0,0,0,0,0,0,0,0,1,1,0,0,0,0],
                        [0,0,0,0,1,1,1,0,0,0,0,0,1,1,1,0,0,0,0,0],
                        [0,0,0,0,0,1,2,1,0,0,0,0,1,2,1,0,0,0,0,0],
                        [0,0,4,0,0,0,2,1,0,0,0,1,2,0,0,0,4,0,0,0],
                        [0,0,1,2,0,0,0,4,1,1,1,1,4,0,0,0,2,1,0,0],
                        [0,1,1,3,3,2,2,1,1,1,1,1,2,2,3,3,1,1,0,0],
                        [0,1,5,1,3,4,3,2,1,1,1,1,2,3,4,3,1,5,1,0],
                        [0,1,1,1,3,3,2,1,1,1,1,1,2,3,3,1,1,1,0,0],
                        [0,0,0,1,0,2,0,0,1,4,4,1,0,0,2,0,1,0,0,0],
                        [0,0,1,0,2,0,0,0,0,0,0,0,0,0,2,0,1,0,0,0],
                        [0,0,0,1,0,1,0,0,0,0,0,0,0,0,1,0,1,0,0,0],
                        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
                        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],]

        map1.gameMapModel = Array.init(repeating: Array.init(repeating: TileTypes.empty, count: mapArray[0].count), count: mapArray.count)
        for row in 0..<mapArray.count {
            for col in 0..<mapArray[row].count {
                if mapArray[row][col] == 1 {
                    map1.gameMapModel![row][col] = .neutral
                }else if mapArray[row][col] == 2{
                    map1.gameMapModel![row][col] = .level1
                }else if mapArray[row][col] == 3{
                    map1.gameMapModel![row][col] = .level2
                }else if mapArray[row][col] == 4{
                    map1.gameMapModel![row][col] = .level3
                }else if mapArray[row][col] == 5{
                    map1.gameMapModel![row][col] = .crown
                }
            }
        }

        map1.mapName = "Invaders"
        map1.numPlayers = 2
        map1.mapBounds = BoardBounds(columns: mapArray[0].count, rows: mapArray.count)
        self.savedMaps.append(map1)

        let map2 = GameMap()
        let mapArray2 =
                [[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
                 [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,1,1,1,0],
                 [0,1,1,1,0,0,1,1,1,1,0,0,0,0,1,1,1,2,1,1,1,1,1,1,1,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,1,1,1,1,1,1],
                 [1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,0,2,1,1,1,2,1,1,0,0,0,0,0,0,0,1,1,2,2,2,2,1,1,1,0,0,1,1,1,1,1,1,1],
                 [1,1,1,1,1,1,1,1,1,0,0,0,1,1,1,0,0,0,2,2,1,2,2,1,0,0,0,0,0,1,0,1,2,2,2,0,0,0,2,2,0,0,1,1,1,1,1,1,1,1],
                 [2,2,1,1,1,1,1,1,1,0,0,0,1,1,1,0,0,0,0,2,2,2,0,0,1,1,0,0,0,1,0,0,3,4,0,0,0,0,0,2,4,3,1,1,1,1,1,1,5,1],
                 [3,2,2,2,1,1,1,2,2,1,0,0,1,2,2,0,0,0,3,4,0,0,0,0,0,1,0,0,3,3,0,0,0,0,0,0,0,1,1,1,3,1,1,3,3,2,1,1,1,1],
                 [4,3,1,1,2,3,3,1,1,1,1,1,1,4,3,2,0,0,0,3,0,0,0,0,0,0,1,1,3,5,4,0,0,3,2,3,1,2,3,1,1,1,1,1,4,4,2,2,2,1],
                 [4,3,5,1,2,4,2,2,2,2,1,1,1,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,4,2,2,2,4,3,3,2,4,3,2,2,1,1,3,3,3,2,2,1,1],
                 [0,3,1,1,1,2,2,1,1,2,2,1,5,1,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,3,4,2,5,2,2,3,2,2,1,1,2,1,2,2,2,2,1],
                 [0,1,1,2,2,2,2,2,2,1,2,1,1,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,3,3,2,2,2,1,2,2,2,2,1,1,2,2,2,2,2,2,2],
                 [0,3,3,1,2,2,2,2,2,1,3,4,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,2,1,1,2,4,3,1,1,2,2,2,2,2,2,2,2],
                 [0,4,3,2,2,2,1,2,2,1,3,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,1,0,0,4,3,1,2,3,2,0,1,2,2,4,1,2,2,2,2,1],
                 [0,0,4,3,2,1,1,2,2,1,1,1,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,3,2,0,0,0,3,3,2,4,3,0,0,0,0,3,3,1,1,1,1,1],
                 [0,0,0,2,1,1,1,1,0,0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,2,2,0,0,0,4,1,0,3,2,0,0,0,0,2,0,0,1,1,1,1],
                 [0,0,0,0,0,2,4,3,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,2,2,0,0,2,4,3,1,1,1,2,0,0,1,1,1],
                 [0,0,0,0,0,2,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,1,0,2,2,0,0,0,0,3,2,1,1,1,2,0,1,1,1,1],
                 [0,0,0,0,0,0,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,2,2,2,2,1,0,0,0,0,0,0,0,2,2,2,2,1,0,1,1,1,1],
                 [0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,5,1,1,1,1,1,0,0,0,0,0,0,4,3,2,2,2,1,1,1,1,1],
                 [0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,2,1,1,1,1,1,1,1,0,0,0,0,0,3,3,1,1,2,2,1,1,1,1],
                 [0,0,0,0,0,0,0,0,0,1,2,3,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,2,2,3,3,4,3,2,1,1,1,1,1,1,1,1,1],
                 [0,0,0,0,0,0,0,0,0,1,1,2,3,4,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,2,1,1,1,2,2,2,2,3,2,0,0,1,1,1,1,1,1],
                 [0,0,0,0,0,0,0,0,1,2,2,2,2,2,1,0,0,0,0,0,0,0,0,0,0,2,2,1,1,1,1,2,2,1,1,1,2,2,5,2,3,2,0,0,1,1,1,1,1,1],
                 [0,0,0,0,0,0,0,0,0,1,2,1,5,1,1,2,0,0,0,0,0,0,0,0,0,2,3,2,2,1,1,1,2,2,1,1,1,1,1,1,2,2,2,0,0,1,1,1,1,1],
                 [0,0,0,0,0,0,0,0,1,1,1,1,1,1,2,2,0,0,0,0,0,0,0,1,1,4,2,2,1,1,1,2,2,1,1,1,1,1,1,1,1,1,2,2,0,1,1,1,1,0],
                 [0,0,0,0,0,0,0,0,0,1,1,1,2,2,4,3,2,0,0,0,0,1,1,1,1,0,3,3,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4,3,0,1,1,1,1],
                 [0,0,0,0,0,0,0,0,0,1,1,1,2,3,3,2,1,1,1,1,1,0,0,0,0,0,4,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,2,3,1,0,0,0,0,0],
                 [0,0,0,0,0,0,0,0,0,0,1,1,2,2,2,1,1,1,1,0,0,0,0,0,0,0,0,0,0,2,1,1,1,1,1,1,1,1,1,1,1,1,1,2,0,0,0,0,0,0],
                 [0,0,0,0,0,0,0,0,0,1,1,1,2,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,2,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0],
                 [0,0,0,0,0,0,0,0,0,0,1,2,2,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0],
                 [0,0,0,0,0,0,0,0,0,1,1,1,3,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,2,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0],
                 [0,0,0,0,0,0,0,0,0,2,3,1,1,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,1,1,1,1,1,3,4,0,0,0,0,0,0,0,0],
                 [0,0,0,0,0,0,0,0,0,4,2,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,1,1,1,1,2,3,0,0,0,0,0,0,0,0,0],
                 [0,0,0,0,0,0,0,0,0,3,2,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,1,1,1,1,2,2,0,0,0,0,0,0,0,0,0],
                 [0,0,0,0,0,0,0,0,1,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,1,1,1,1,1,2,2,0,0,0,0,0,0,0,0,0,0],
                 [0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0]]
        map2.gameMapModel = Array.init(repeating: Array.init(repeating: TileTypes.empty, count: mapArray2[0].count), count: mapArray2.count)
        for row in 0..<mapArray2.count {
            for col in 0..<mapArray2[row].count {
                if mapArray2[row][col] == 1 {
                    map2.gameMapModel![row][col] = .neutral
                }else if mapArray2[row][col] == 2{
                    map2.gameMapModel![row][col] = .level1
                }else if mapArray2[row][col] == 3{
                    map2.gameMapModel![row][col] = .level2
                }else if mapArray2[row][col] == 4{
                    map2.gameMapModel![row][col] = .level3
                }else if mapArray2[row][col] == 5{
                    map2.gameMapModel![row][col] = .crown
                }
            }
        }
        map2.mapName = "East.v.West"
        map2.numPlayers = 8
        map2.mapBounds = BoardBounds(columns: mapArray2[0].count, rows: mapArray2.count)
        self.savedMaps.append(map2)

        let map3 = GameMap()
        let mapArray3 = [[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
                        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0],
                        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,5,1,1,1,1,1,0,0,0],
                        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,3,1,1,1,2,4,3,1,1,0,0],
                        [0,0,0,0,0,2,2,0,0,1,1,1,1,0,0,1,0,0,2,4,2,2,2,3,1,1,1,1,0,0],
                        [0,0,0,0,0,2,4,4,1,1,0,0,0,1,1,1,0,0,1,3,1,3,4,1,1,1,1,3,1,0],
                        [0,0,0,0,0,4,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,3,1,1,3,4,1,1,0],
                        [0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,2,1,1,0],
                        [0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,2,1,1,1,3,2,1,5,1,0],
                        [0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,3,4,2,3,4,1,1,4,1,1,1,0],
                        [0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,3,1,1,2,3,1,3,2,2,1,0,0],
                        [0,0,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,0,1,1,5,1,2,2,1,2,3,4,1,0],
                        [0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,1,0,1,1,3,4,3,1,1,1,3,0,0],
                        [0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,1,1,1,1,0,0,1,0],
                        [0,1,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0],
                        [0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,1,1,3,1,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0],
                        [0,1,1,1,1,1,4,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [0,1,1,5,1,2,3,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0],
                        [0,3,2,1,1,3,2,1,3,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0],
                        [1,4,3,2,4,1,1,2,4,3,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,2,1,0,0],
                        [1,1,1,2,3,1,1,1,2,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,2,0,0,0],
                        [1,1,1,1,1,1,1,3,1,5,1,0,0,0,0,0,0,0,0,0,1,1,4,4,3,2,1,0,0,0],
                        [1,1,3,1,2,2,1,4,2,1,1,1,0,0,0,0,0,0,0,0,0,1,3,4,4,1,1,0,0,0],
                        [1,1,4,2,3,4,1,3,2,2,1,0,0,0,0,0,0,0,0,0,1,2,2,4,3,1,1,0,0,0],
                        [0,1,3,1,1,1,3,1,1,4,3,1,1,0,0,0,0,0,0,0,2,2,1,1,1,1,0,0,0,0],
                        [0,1,1,5,1,2,2,1,3,1,0,0,1,1,1,0,0,0,1,1,0,0,1,1,1,0,0,0,0,0],
                        [0,0,1,1,1,3,4,1,1,1,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0],
                        [0,0,0,1,1,1,3,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
                        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]]
        map3.gameMapModel = Array.init(repeating: Array.init(repeating: TileTypes.empty, count: mapArray3[0].count), count: mapArray3.count)
        for row in 0..<mapArray3.count {
            for col in 0..<mapArray3[row].count {
                if mapArray3[row][col] == 1 {
                    map3.gameMapModel![row][col] = .neutral
                }else if mapArray3[row][col] == 2{
                    map3.gameMapModel![row][col] = .level1
                }else if mapArray3[row][col] == 3{
                    map3.gameMapModel![row][col] = .level2
                }else if mapArray3[row][col] == 4{
                    map3.gameMapModel![row][col] = .level3
                }else if mapArray3[row][col] == 5{
                    map3.gameMapModel![row][col] = .crown
                }
            }
        }
        map3.mapName = "Mars.v.Earth"
        map3.numPlayers = 6
        map3.mapBounds = BoardBounds(columns: mapArray3[0].count, rows: mapArray3.count)
        self.savedMaps.append(map3)

        let map4 = GameMap()
        let mapArray4 = [[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
                         [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
                         [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
                         [0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
                         [0,0,0,0,1,2,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0],
                         [0,0,0,0,2,2,2,1,1,1,1,0,0,0,0,0,0,0,0,2,2,2,3,3,3,1,0,0,0,0],
                         [0,0,2,2,1,1,1,4,1,1,1,0,0,0,0,0,0,0,2,2,3,3,3,3,1,1,2,2,0,0],
                         [0,0,1,1,1,1,4,5,3,3,1,1,0,0,0,0,0,0,0,2,2,2,3,2,1,1,2,2,2,0],
                         [0,1,1,1,1,1,1,2,2,2,1,1,0,0,0,0,0,0,2,2,2,2,2,2,1,2,2,2,1,0],
                         [0,1,1,1,1,1,1,1,2,2,1,1,1,0,0,0,0,0,0,3,2,2,2,2,1,1,2,2,2,1],
                         [1,1,4,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,4,2,2,2,1,1,1,3,3,2,2,1],
                         [1,4,5,1,2,4,4,3,1,1,1,1,1,1,1,1,1,1,1,4,3,2,2,1,1,1,2,2,2,1],
                         [1,1,2,2,2,4,3,1,1,1,1,1,4,1,1,1,1,1,1,4,2,2,1,1,1,5,2,1,2,1],
                         [0,1,2,2,2,2,2,1,1,1,1,3,4,4,1,1,1,1,1,1,4,2,1,1,1,2,1,1,2,2],
                         [0,1,1,1,1,1,1,1,1,1,4,3,3,2,1,1,1,1,1,1,4,4,2,2,2,2,1,1,2,1],
                         [0,1,1,1,1,1,1,1,1,1,1,2,2,2,1,1,1,1,1,1,1,1,4,2,2,3,1,1,2,2],
                         [1,1,1,1,1,1,1,1,1,1,1,2,1,1,1,1,2,1,1,1,1,1,4,2,2,2,2,2,2,2],
                         [0,3,2,2,1,1,1,2,1,1,1,1,1,1,1,1,2,2,1,1,1,1,1,4,2,2,2,3,2,3],
                         [0,3,2,2,1,1,2,3,4,1,1,1,1,1,1,1,4,1,1,1,1,1,4,1,1,2,2,2,2,2],
                         [0,0,0,2,1,1,5,2,4,1,1,1,1,1,1,1,1,1,1,1,1,1,4,1,1,1,2,2,3,2],
                         [0,0,0,0,0,1,1,2,4,1,1,1,1,1,1,1,1,1,1,1,1,1,4,1,1,1,2,2,2,0],
                         [0,0,0,0,0,0,0,4,1,1,1,1,1,1,1,1,1,2,1,1,1,1,1,4,3,2,1,2,3,0],
                         [0,0,0,0,0,0,0,0,0,1,1,1,2,2,1,1,2,2,1,1,1,1,1,4,2,2,2,2,0,0],
                         [0,0,0,0,0,0,0,0,0,0,0,1,2,4,2,1,1,3,2,1,1,1,1,1,4,4,3,2,0,0],
                         [0,0,0,0,0,0,0,0,0,0,0,0,4,3,2,1,1,3,2,1,1,1,1,1,1,0,0,0,0,0],
                         [0,0,0,0,0,0,0,0,0,0,0,0,1,1,3,1,1,1,1,1,1,2,1,1,0,0,0,0,0,0],
                         [0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,2,2,0,0,0,0,0,0,0,0],
                         [0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,4,1,1,1,1,1,1,0,0,0,0,0,0,0,0],
                         [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,4,3,2,2,1,0,0,0,0,0,0,0,0,0],
                         [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,3,2,2,0,0,0,0,0,0,0,0,0]]
        map4.gameMapModel = Array.init(repeating: Array.init(repeating: TileTypes.empty, count: mapArray4[0].count), count: mapArray4.count)
        for row in 0..<mapArray4.count {
            for col in 0..<mapArray4[row].count {
                if mapArray4[row][col] == 1 {
                    map4.gameMapModel![row][col] = .neutral
                }else if mapArray4[row][col] == 2{
                    map4.gameMapModel![row][col] = .level1
                }else if mapArray4[row][col] == 3{
                    map4.gameMapModel![row][col] = .level2
                }else if mapArray4[row][col] == 4{
                    map4.gameMapModel![row][col] = .level3
                }else if mapArray4[row][col] == 5{
                    map4.gameMapModel![row][col] = .crown
                }
            }
        }
        map4.mapName = "WallOfChina"
        map4.numPlayers = 5
        map4.mapBounds = BoardBounds(columns: mapArray4[0].count, rows: mapArray4.count)
        self.savedMaps.append(map4)

        let map5 = GameMap()
        let mapArray5 = [[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,1],
                         [1,1,2,2,4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4,1,1,2,2],
                         [1,2,2,4,4,1,1,1,1,1,1,1,1,1,1,1,1,1,4,4,1,1,2,2],
                         [1,2,2,2,4,1,1,1,1,4,2,1,1,1,1,1,1,1,1,4,1,1,2,2],
                         [1,3,3,4,4,1,1,1,3,2,2,1,3,1,1,1,1,1,4,4,3,3,1,1],
                         [1,3,5,1,4,1,1,1,1,3,3,1,1,3,3,1,1,1,1,4,1,5,3,1],
                         [1,3,4,4,4,4,1,1,1,1,1,1,3,4,1,1,1,4,4,4,4,3,1,1],
                         [1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,1,1,1,1,1,1,1,2,1],
                         [2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,1,1,2,2,1],
                         [2,2,3,3,3,1,1,1,1,1,2,2,1,1,1,1,1,2,2,2,1,1,2,2],
                         [2,2,2,3,3,1,1,1,1,1,4,2,1,1,1,1,3,2,2,1,1,1,2,2],
                         [1,2,2,2,3,1,1,1,1,1,1,1,1,1,1,1,1,3,3,1,1,1,1,2]]

        map5.gameMapModel = Array.init(repeating: Array.init(repeating: TileTypes.empty, count: mapArray5[0].count), count: mapArray5.count)
        for row in 0..<mapArray5.count {
            for col in 0..<mapArray5[row].count {
                if mapArray5[row][col] == 1 {
                    map5.gameMapModel![row][col] = .neutral
                }else if mapArray5[row][col] == 2{
                    map5.gameMapModel![row][col] = .level1
                }else if mapArray5[row][col] == 3{
                    map5.gameMapModel![row][col] = .level2
                }else if mapArray5[row][col] == 4{
                    map5.gameMapModel![row][col] = .level3
                }else if mapArray5[row][col] == 5{
                    map5.gameMapModel![row][col] = .crown
                }
            }
        }
        map5.mapName = "TwoTowers"
        map5.numPlayers = 2
        map5.mapBounds = BoardBounds(columns: mapArray5[0].count, rows: mapArray5.count)
        self.savedMaps.append(map5)

        let map6 = GameMap()
        let mapArray6 = [[0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0],
                         [0,0,0,0,0,0,0,0,0,1,1,1,5,3,1,0,0,0,0,0,0,0,0,0,0],
                         [0,0,0,1,1,1,1,1,0,0,1,1,1,3,2,1,1,0,1,1,0,0,0,0,0],
                         [0,0,0,1,1,2,1,1,1,0,0,0,1,2,4,1,0,0,1,1,0,0,0,0,0],
                         [0,0,1,1,1,5,3,4,3,1,1,0,0,1,2,1,0,0,1,1,1,0,0,0,0],
                         [0,0,1,1,1,1,2,2,2,2,1,0,0,2,3,0,0,1,2,5,1,0,0,0,0],
                         [0,0,0,0,0,0,0,1,1,4,3,1,0,1,4,1,0,1,3,3,2,1,0,0,0],
                         [0,0,0,0,0,0,0,0,1,2,2,1,0,3,2,0,1,2,4,1,1,0,0,0,0],
                         [0,0,1,1,1,1,1,0,0,0,2,1,0,2,2,0,1,3,2,1,1,0,0,1,0],
                         [1,1,1,1,1,1,1,1,0,1,3,1,4,3,1,2,4,2,1,1,0,0,1,1,0],
                         [1,1,2,3,4,3,2,4,3,1,4,1,4,1,4,3,3,1,0,0,0,1,1,1,0],
                         [1,5,2,2,2,2,2,2,3,1,4,4,4,4,2,1,0,0,1,1,1,1,1,1,0],
                         [0,1,1,1,0,0,0,0,1,4,4,4,2,4,1,1,1,0,1,1,3,2,2,1,0],
                         [1,1,1,0,0,0,0,1,3,1,4,4,4,4,4,2,2,3,2,4,3,5,1,1,0],
                         [0,1,1,0,1,1,2,3,3,1,4,1,4,1,1,1,3,4,2,2,2,1,1,1,0],
                         [0,0,0,1,1,3,4,2,0,3,2,1,4,1,1,0,1,1,1,1,1,1,1,0,0],
                         [0,0,0,1,1,2,2,1,0,2,3,0,0,2,3,0,0,0,0,1,1,1,0,0,0],
                         [0,0,0,1,4,2,1,0,1,4,1,0,0,4,1,1,1,1,0,0,0,0,0,0,0],
                         [0,0,0,1,3,2,1,0,0,1,2,1,0,2,3,2,2,1,1,1,0,1,0,0,0],
                         [0,0,1,1,5,1,1,0,1,3,2,1,0,1,1,4,2,3,1,1,1,1,0,0,0],
                         [0,0,0,1,1,1,1,0,0,1,4,2,1,0,1,1,2,3,5,1,1,1,0,0,0],
                         [0,0,0,1,1,1,1,0,1,3,2,1,0,0,1,1,1,2,1,1,1,0,0,0,0],
                         [0,0,0,0,0,1,1,0,0,1,5,1,1,0,0,0,1,1,1,1,0,0,0,0,0],
                         [0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0],
                         [0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0]]

        map6.gameMapModel = Array.init(repeating: Array.init(repeating: TileTypes.empty, count: mapArray6[0].count), count: mapArray6.count)
        for row in 0..<mapArray6.count {
            for col in 0..<mapArray6[row].count {
                if mapArray6[row][col] == 1 {
                    map6.gameMapModel![row][col] = .neutral
                }else if mapArray6[row][col] == 2{
                    map6.gameMapModel![row][col] = .level1
                }else if mapArray6[row][col] == 3{
                    map6.gameMapModel![row][col] = .level2
                }else if mapArray6[row][col] == 4{
                    map6.gameMapModel![row][col] = .level3
                }else if mapArray6[row][col] == 5{
                    map6.gameMapModel![row][col] = .crown
                }
            }
        }
        map6.mapName = "Spiral8Arm"
        map6.numPlayers = 8
        map6.mapBounds = BoardBounds(columns: mapArray6[0].count, rows: mapArray6.count)
        self.savedMaps.append(map6)

        let map7 = GameMap()
        let mapArray7 = [[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
                         [0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
                         [0,0,0,0,0,0,0,0,0,0,1,1,1,2,1,1,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,1,1,1,0,0,0,0],
                         [0,0,0,0,0,0,0,0,0,0,3,1,5,2,1,1,1,1,1,1,1,1,1,1,1,2,2,0,0,0,0,0,1,1,1,1,1,0,0,0],
                         [0,0,0,0,0,0,0,0,0,4,3,2,2,2,2,0,0,0,0,0,0,0,1,3,3,2,1,1,1,1,1,1,1,1,2,1,1,1,0,0],
                         [0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,1,1,4,2,1,0,0,0,0,0,1,1,1,2,5,1,1,0],
                         [0,0,0,0,0,0,0,0,0,1,1,0,0,1,0,0,0,0,0,0,0,1,1,1,2,1,0,0,0,0,0,0,0,2,2,2,2,3,1,0],
                         [0,0,0,0,0,0,0,0,1,1,0,0,0,0,1,0,0,0,0,0,1,1,0,0,0,0,1,0,0,0,0,0,1,1,1,1,1,3,4,0],
                         [0,0,0,0,1,1,1,1,0,0,0,0,0,0,1,1,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,1,1,1,0,0],
                         [0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,1,0,0],
                         [0,0,1,1,3,1,1,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,1,1,0,1,0,0,0,0,0,0,1,0,0],
                         [0,0,1,1,4,3,1,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,1,1,1,1,2,1,0,0,0,0,0,0,0,1,0],
                         [0,0,2,2,2,2,2,1,1,1,1,1,0,0,1,1,3,1,1,1,1,1,1,0,0,1,4,3,2,1,1,0,0,0,0,0,0,0,1,0],
                         [0,0,0,1,1,1,0,0,0,0,0,0,1,0,1,1,4,3,1,1,0,0,0,1,1,1,1,3,2,1,1,0,0,0,0,0,0,1,1,0],
                         [0,0,0,0,0,1,0,0,0,0,0,0,1,1,2,2,2,2,2,1,0,0,0,0,0,1,1,2,1,1,1,0,0,0,0,0,0,1,0,0],
                         [0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,1,2,1,1,0,0,0,0,0,0,1,1,1,1],
                         [0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,1,1,1,1,1],
                         [0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,1,1,0,0,0,1,1,1,1,0,0,1,1,1,1,1],
                         [0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,1,1,1,0,1,1,5,1,1],
                         [0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2],
                         [0,0,0,1,1,1,5,1,1,1,1,1,1,1,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,3,1,1],
                         [0,0,0,0,1,2,2,2,2,2,0,0,0,0,1,0,1,4,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,3,4,0],
                         [0,0,0,0,0,1,3,3,1,1,0,0,0,0,1,1,3,3,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0],
                         [0,0,0,0,0,1,1,4,1,0,0,0,0,0,0,1,2,2,2,2,2,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0],
                         [0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,1,1,0,1,1,1,1,1,0,0,0,0,0,0],
                         [0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,1,1,1,0,1,0,0,0,0,0,0,0,1,2,2,2,2,2,0,0,0,0,0,0],
                         [0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,1,1,0,0,0,0,0,0,1,1,3,3,1,1,0,0,0,0,0,0],
                         [0,0,0,1,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,1,1,4,1,1,0,0,0,0,0,0],
                         [0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0],
                         [0,0,0,1,0,0,0,0,0,1,1,1,2,1,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,1,1,0,0,1,0,0,0,0,0,0],
                         [0,0,1,0,0,0,0,0,0,0,1,1,2,1,1,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0],
                         [0,0,0,1,0,0,0,0,0,0,1,1,1,2,1,1,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,1,0,0,1,0,0],
                         [0,0,1,0,0,0,0,0,0,1,1,1,1,2,1,1,1,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,1,0,4,0,0,0],
                         [0,0,1,2,4,3,0,0,0,1,1,1,1,3,3,1,0,1,1,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,1,3,3,0,0],
                         [0,1,1,2,3,1,1,1,1,0,0,0,1,4,1,0,0,0,1,1,1,0,1,1,1,1,1,1,0,0,0,0,0,0,1,1,2,2,1,0],
                         [0,1,1,5,2,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,3,1,1,1,0,0,0,0,0,0,1,1,5,2,1,0],
                         [0,1,1,1,2,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,3,4,1,1,1,1,1,1,1,1,1,1,1,2,1,1,0],
                         [0,0,1,1,1,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,0,0,0,0,0,0,0,0,1,2,1,0,0],
                         [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
                         [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]]

        map7.gameMapModel = Array.init(repeating: Array.init(repeating: TileTypes.empty, count: mapArray7[0].count), count: mapArray7.count)
        for row in 0..<mapArray7.count {
            for col in 0..<mapArray7[row].count {
                if mapArray7[row][col] == 1 {
                    map7.gameMapModel![row][col] = .neutral
                }else if mapArray7[row][col] == 2{
                    map7.gameMapModel![row][col] = .level1
                }else if mapArray7[row][col] == 3{
                    map7.gameMapModel![row][col] = .level2
                }else if mapArray7[row][col] == 4{
                    map7.gameMapModel![row][col] = .level3
                }else if mapArray7[row][col] == 5{
                    map7.gameMapModel![row][col] = .crown
                }
            }
        }
        map7.mapName = "IslandHopping"
        map7.numPlayers = 6
        map7.mapBounds = BoardBounds(columns: mapArray7[0].count, rows: mapArray7.count)
        self.savedMaps.append(map7)

        let map8 = GameMap()
        let mapArray8 = [[0,2,3,1,3,2,0,0,0,0,0,0,0,2,3,5,3,2,0,2,3,1,3,4,0],
                         [2,3,1,3,4,0,0,0,0,0,0,0,2,3,1,1,3,2,0,2,3,1,3,4,0],
                         [2,3,1,1,3,4,0,0,0,0,0,0,2,3,1,3,1,3,4,0,4,3,1,3,4],
                         [3,1,3,1,3,4,4,4,2,2,2,2,3,1,3,3,1,3,4,4,3,1,3,3,3],
                         [3,1,3,3,1,3,3,3,3,3,3,3,3,1,3,2,3,1,3,4,3,1,1,1,1],
                         [1,3,2,3,1,1,1,1,1,1,1,1,1,3,2,2,3,1,3,3,1,3,3,3,3],
                         [1,3,2,2,3,1,3,3,3,3,3,3,1,3,2,0,2,3,1,3,1,3,2,2,2],
                         [3,2,0,2,3,1,3,2,2,2,3,1,3,4,0,0,2,3,1,1,3,2,0,0,0],
                         [3,2,0,0,2,3,1,3,2,2,3,1,3,4,0,0,0,2,3,1,3,2,0,0,0],
                         [2,2,4,4,4,3,1,3,2,3,1,3,4,4,4,2,2,3,1,3,4,4,2,2,2],
                         [3,3,3,3,3,3,3,1,3,3,1,3,3,3,3,3,3,3,1,3,3,3,3,3,3],
                         [5,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,5],
                         [3,3,3,3,3,3,3,1,3,3,3,3,3,3,3,1,3,1,3,3,3,3,3,3,3],
                         [2,2,2,2,4,3,1,3,4,4,4,4,4,3,1,3,3,1,3,4,2,2,2,2,2],
                         [0,0,0,0,4,3,1,3,2,0,0,0,2,3,1,3,2,3,1,3,4,0,0,0,0],
                         [0,0,0,4,3,1,3,2,0,0,0,2,3,1,3,2,2,3,1,3,4,0,0,0,0],
                         [2,2,2,4,3,1,3,2,0,0,0,2,3,1,3,2,0,2,3,1,3,4,0,0,0],
                         [3,3,3,3,1,3,2,2,2,2,2,3,1,3,4,0,0,2,3,1,3,2,0,0,0],
                         [1,1,1,1,1,3,3,3,3,3,3,3,1,3,4,0,0,0,2,3,1,3,2,2,2],
                         [3,3,3,1,1,1,1,1,1,1,1,1,3,4,4,4,2,2,2,3,1,3,3,3,3],
                         [2,2,3,1,3,3,3,3,3,3,3,1,3,3,3,3,3,3,3,3,3,1,1,1,1],
                         [0,4,3,1,3,4,4,4,4,4,3,1,1,1,1,1,1,1,1,1,1,3,3,3,3],
                         [0,4,3,1,1,3,2,0,0,0,2,3,1,3,3,3,3,3,3,3,3,3,4,4,4],
                         [4,3,1,3,1,3,2,0,0,0,2,3,1,3,4,4,4,2,2,2,2,2,0,0,0],
                         [2,3,1,3,3,1,3,2,0,0,0,2,3,5,3,4,0,0,0,0,0,0,0,0,0]]

        map8.gameMapModel = Array.init(repeating: Array.init(repeating: TileTypes.empty, count: mapArray8[0].count), count: mapArray8.count)
        for row in 0..<mapArray8.count {
            for col in 0..<mapArray8[row].count {
                if mapArray8[row][col] == 1 {
                    map8.gameMapModel![row][col] = .neutral
                }else if mapArray8[row][col] == 2{
                    map8.gameMapModel![row][col] = .level1
                }else if mapArray8[row][col] == 3{
                    map8.gameMapModel![row][col] = .level2
                }else if mapArray8[row][col] == 4{
                    map8.gameMapModel![row][col] = .level3
                }else if mapArray8[row][col] == 5{
                    map8.gameMapModel![row][col] = .crown
                }
            }
        }
        map8.mapName = "UrbanWarfare"
        map8.numPlayers = 4
        map8.mapBounds = BoardBounds(columns: mapArray8[0].count, rows: mapArray8.count)
        self.savedMaps.append(map8)

        let map9 = GameMap()
        let mapArray9 = [[2,2,3,2,2,4,3,3,2,2],
                         [2,3,4,3,2,2,3,2,5,1],
                         [3,1,2,2,1,1,2,2,1,1],
                         [0,4,0,0,4,1,4,1,2,1],
                         [0,1,0,0,0,0,0,0,1,1],
                         [0,0,1,1,0,0,0,0,1,1],
                         [0,0,0,1,0,0,0,0,1,1],
                         [0,0,0,0,1,0,0,0,1,1],
                         [0,1,1,1,0,0,0,0,1,1],
                         [0,1,0,0,0,0,0,0,1,1],
                         [1,0,0,0,0,0,0,0,1,0],
                         [0,1,1,0,0,0,0,0,1,1],
                         [0,0,1,0,0,0,0,0,1,1],
                         [0,0,0,1,0,0,0,0,1,1],
                         [0,0,4,0,0,0,0,0,1,1],
                         [1,2,2,1,1,1,1,1,1,1],
                         [3,2,1,1,1,1,2,1,1,1],
                         [3,1,1,2,2,1,3,2,2,4],
                         [2,2,5,2,3,4,3,2,2,1],
                         [1,2,2,3,3,4,4,3,3,1]]

        map9.gameMapModel = Array.init(repeating: Array.init(repeating: TileTypes.empty, count: mapArray9[0].count), count: mapArray9.count)
        for row in 0..<mapArray9.count {
            for col in 0..<mapArray9[row].count {
                if mapArray9[row][col] == 1 {
                    map9.gameMapModel![row][col] = .neutral
                }else if mapArray9[row][col] == 2{
                    map9.gameMapModel![row][col] = .level1
                }else if mapArray9[row][col] == 3{
                    map9.gameMapModel![row][col] = .level2
                }else if mapArray9[row][col] == 4{
                    map9.gameMapModel![row][col] = .level3
                }else if mapArray9[row][col] == 5{
                    map9.gameMapModel![row][col] = .crown
                }
            }
        }
        map9.mapName = "Thermopylae"
        map9.numPlayers = 2
        map9.mapBounds = BoardBounds(columns: mapArray9[0].count, rows: mapArray9.count)
        self.savedMaps.append(map9)

        let map10 = GameMap()
        let mapArray10 = [[0,0,0,0,0,0,1,5,1,0,0,0,0,0,0],
                          [0,0,0,0,0,0,1,1,0,0,0,0,0,0,0],
                          [0,0,0,0,0,0,1,1,1,0,0,0,0,0,0],
                          [0,0,0,0,0,0,2,1,0,0,0,0,0,0,0],
                          [0,0,0,0,0,0,2,4,2,0,0,0,0,0,0],
                          [0,0,0,0,0,1,3,3,1,0,0,0,0,0,0],
                          [0,0,0,0,0,1,1,2,1,1,0,0,0,0,0],
                          [0,0,0,0,1,1,1,1,1,1,0,0,0,0,0],
                          [0,0,0,0,1,1,1,4,1,1,1,0,0,0,0],
                          [0,0,2,3,2,1,1,1,1,2,3,2,0,0,0],
                          [0,1,1,4,3,1,0,0,0,1,3,4,1,1,0],
                          [1,1,2,2,1,0,0,0,0,1,2,2,1,1,0],
                          [1,1,1,1,0,0,0,0,0,0,0,1,1,1,1],
                          [5,1,0,0,0,0,0,0,0,0,0,0,1,5,0],
                          [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]]

        map10.gameMapModel = Array.init(repeating: Array.init(repeating: TileTypes.empty, count: mapArray10[0].count), count: mapArray10.count)
        for row in 0..<mapArray10.count {
            for col in 0..<mapArray10[row].count {
                if mapArray10[row][col] == 1 {
                    map10.gameMapModel![row][col] = .neutral
                }else if mapArray10[row][col] == 2{
                    map10.gameMapModel![row][col] = .level1
                }else if mapArray10[row][col] == 3{
                    map10.gameMapModel![row][col] = .level2
                }else if mapArray10[row][col] == 4{
                    map10.gameMapModel![row][col] = .level3
                }else if mapArray10[row][col] == 5{
                    map10.gameMapModel![row][col] = .crown
                }
            }
        }
        map10.mapName = "ThreeKings"
        map10.numPlayers = 3
        map10.mapBounds = BoardBounds(columns: mapArray10[0].count, rows: mapArray10.count)
        self.savedMaps.append(map10)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(GameState.sharedInstance().wasGameSaved!, forKey: "GameState_wasGameSaved")
        aCoder.encode(GameState.sharedInstance().mainPlayerOptions!, forKey: "GameState_mainPlayerOptions")
        aCoder.encode(GameState.sharedInstance().numHumanPlayers!, forKey: "GameState_numHumanPlayers")
        aCoder.encode(GameState.sharedInstance().currentGameMap!, forKey: "GameState_currentGameMap")
        aCoder.encode(GameState.sharedInstance().playerStatistics!, forKey: "GameState_playerStatistics")
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        self.wasGameSaved = aDecoder.decodeBool(forKey: "GameState_wasGameSaved")

        if let data = aDecoder.decodeObject(forKey: "GameState_mainPlayerOptions") as? GameOptions {
            self.mainPlayerOptions = data
        }
        if let data = aDecoder.decodeObject(forKey: "GameState_numHumanPlayers") as? Int {
            self.numHumanPlayers = data
        }
        if let data = aDecoder.decodeObject(forKey: "GameState_currentGameMap") as? GameMap {
            self.currentGameMap = data
        }
        if let data = aDecoder.decodeObject(forKey: "GameState_playerStatistics") as? GameStatistics {
            self.playerStatistics = data
        }
        self.addPresetMaps()    //Added manually
    }
}

// This class contains options that the player can set through the game menus that are unrelated to the
// generation of the game map.
class GameOptions: NSObject, NSCoding {
    var isGamePreset:Bool?

    //Options
    var chosenDifficulty:Difficulty?
    var chosenGameTheme: GameTheme?
    var chosenWallType:WallType?
    var chosenPlayerColor:PlayerColor?
    var chosenSoundToggle:SoundToggle?

    override init() {
        //Default initialization
        self.chosenDifficulty = .hard
        self.chosenGameTheme = .medieval
        self.chosenWallType = .type1
        self.chosenPlayerColor = .red
        self.chosenSoundToggle = .soundOn
        self.isGamePreset = false
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.isGamePreset!, forKey: "GameOptions_isGamePreset")
        aCoder.encode(self.chosenDifficulty!.rawValue, forKey: "GameOptions_chosenDifficulty")
        aCoder.encode(self.chosenGameTheme!.rawValue, forKey: "GameOptions_chosenGameTheme")
        aCoder.encode(self.chosenWallType!.rawValue, forKey: "GameOptions_chosenWallType")
        aCoder.encode(self.chosenPlayerColor!.rawValue, forKey: "GameOptions_chosenPlayerColor")
        aCoder.encode(self.chosenSoundToggle!.rawValue, forKey: "GameOptions_chosenSoundToggle")
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        self.isGamePreset = aDecoder.decodeBool(forKey: "GameOptions_isGamePreset")

        var data = aDecoder.decodeInteger(forKey: "GameOptions_chosenDifficulty")
        self.chosenDifficulty = Difficulty(rawValue: data)

        data = aDecoder.decodeInteger(forKey: "GameOptions_chosenGameTheme")
        self.chosenGameTheme = GameTheme(rawValue: data)

        data = aDecoder.decodeInteger(forKey: "GameOptions_chosenWallType")
        self.chosenWallType = WallType(rawValue: data)

        data = aDecoder.decodeInteger(forKey: "GameOptions_chosenPlayerColor")
        self.chosenPlayerColor = PlayerColor(rawValue: data)

        data = aDecoder.decodeInteger(forKey: "GameOptions_chosenSoundToggle")
        self.chosenSoundToggle = SoundToggle(rawValue: data)
    }
}

//This class stores all the necessary information to build a game map.
class GameMap: NSObject, NSCoding {
    var mapName:String?
    //General map parameters, filled either by preset or by NewCustomGame() menu
    var numPlayers:Int?

    //Custom map parameters, filled by the NewCustomGame() menu
    var mapBounds:BoardBounds?
    var mapFillType:MapFillType?
    var landGrowthRadius:Int?
    var seedForMap:UInt64?
    var seedForCrowns:UInt64?

    var gameMapModel:[[TileTypes]]?

    //These will be defualt values as long as the user changes nothing and calls for a random map
    override init(){
        self.mapName = "Random"
        self.numPlayers = 2
        self.mapBounds = BoardBounds(columns: 20, rows: 20)
        self.mapFillType = .continents
        self.landGrowthRadius = 2

        //We leave the remaining parameters as is because they are initialized at map creation.
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.mapName!, forKey: "GameMap_mapName")
        aCoder.encode(self.numPlayers!, forKey: "GameMap_numPlayers")

        aCoder.encode(self.mapBounds!, forKey: "GameMap_mapBounds")
        aCoder.encode(self.mapFillType!.rawValue, forKey: "GameMap_mapFillType")
        aCoder.encode(self.landGrowthRadius!, forKey: "GameMap_landGrowthRadius")
        aCoder.encode(self.seedForMap, forKey: "GameMap_seedForMap")
        aCoder.encode(self.seedForCrowns, forKey: "GameMap_seedForCrowns")

        if self.gameMapModel != nil {
            let values = self.gameMapModel!.map { $0.map{ $0.rawValue}}
            aCoder.encode(values, forKey: "GameMap_gameMapModel")
        }
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        if let data = aDecoder.decodeObject(forKey: "GameMap_mapName") as? String{
            self.mapName = data
        }

        self.numPlayers = aDecoder.decodeInteger(forKey: "GameMap_numPlayers")

        if let data = aDecoder.decodeObject(forKey: "GameMap_mapBounds") as? BoardBounds {
            self.mapBounds = data
        }
        if let data = aDecoder.decodeObject(forKey: "GameMap_mapFillType") as? Int{
            self.mapFillType = MapFillType(rawValue: data)
        }

        self.landGrowthRadius = aDecoder.decodeInteger(forKey: "GameMap_landGrowthRadius")

        if let data = aDecoder.decodeObject(forKey: "GameMap_seedForMap") as? UInt64 {
            self.seedForMap = data
        }
        if let data = aDecoder.decodeObject(forKey: "GameMap_seedForCrowns") as? UInt64 {
            self.seedForCrowns = data
        }
        if let data = aDecoder.decodeObject(forKey: "GameMap_gameMapModel") as? [[Int]] {
            self.gameMapModel = data.map{ $0.map{ TileTypes(rawValue: $0)!}}
        }

    }
}


//This information is used for the "History" screen of the game to show player achievement.
class GameStatistics: NSObject, NSCoding {
    var gamesPlayedTotal:Int?
    var gamesWonTotal:Int?
    var gamesLostTotal:Int?

    var fastestGameWin:Int?     //Least number of turns to win.
    var isGameBeingTracked:Bool? //The counters are only updated for singleplayer games.

    override init(){
        self.gamesPlayedTotal = 0
        self.gamesWonTotal = 0
        self.gamesLostTotal = 0

        self.fastestGameWin = 0
        self.isGameBeingTracked = false
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.gamesPlayedTotal!, forKey: "GameStatistics_gamesPlayerTotal")
        aCoder.encode(self.gamesWonTotal!, forKey: "GameStatistics_gamesWonTotal")
        aCoder.encode(self.gamesLostTotal!, forKey: "GameStatistics_gamesLostTotal")
        aCoder.encode(self.fastestGameWin!, forKey: "GameStatistics_fastestGameWin")
        aCoder.encode(self.isGameBeingTracked!, forKey: "GameStatistics_isGameBeingTracked")
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        self.gamesPlayedTotal = aDecoder.decodeInteger(forKey: "GameStatistics_gamesPlayerTotal")
        self.gamesWonTotal = aDecoder.decodeInteger(forKey: "GameStatistics_gamesWonTotal")
        self.gamesLostTotal = aDecoder.decodeInteger(forKey: "GameStatistics_gamesLostTotal")
        self.fastestGameWin = aDecoder.decodeInteger(forKey: "GameStatistics_fastestGameWin")
        self.isGameBeingTracked = aDecoder.decodeBool(forKey: "GameStatistics_isGameBeingTracked")
    }
}