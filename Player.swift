//
//  Player.swift
//  HexWars
//
//  Created by Aleksandr Grin on 8/5/17.
//  Copyright © 2017 AleksandrGrin. All rights reserved.
//

import UIKit
import GameplayKit

class Player: NSObject, NSCopying, NSCoding, GKGameModelPlayer {
    var color:UIColor?
    var name:String?
    var playerId:Int
    var isPlayerHuman:Bool?
    var playerScore:Int?

    var gameTheme: GameTheme?

    //Since the tilemap has limited per-Tile information storage we store tile locations per player
    var crown_Locations:Array<CGPoint>?
    var level2_Locations:Array<CGPoint>?
    var level1_Locations:Array<CGPoint>?
    var level3_Locations:Array<CGPoint>?
    var counter_Locations:Array<CGPoint>?

    var numberOfLevel1:Int?
    var numberOfLevel2:Int?
    var numberOfLevel3:Int?
    var numberOfCrowns:Int?
    var deployedCounters:Int?

    var availableCounters:Int?
    var availableLevel1:Int?
    var availableLevel2:Int?
    var availableLevel3:Int?

    var crownHealth:Int?


    override init(){
        //DefaultValues
        self.color = .red
        self.name = "Player1"
        self.playerId = 1
        self.isPlayerHuman = false
        self.playerScore = 0
        self.gameTheme = .medieval

        self.numberOfLevel1 = 0
        self.numberOfLevel2 = 0
        self.numberOfLevel3 = 0
        self.numberOfCrowns = 0
        self.deployedCounters = 0

        self.crown_Locations = []
        self.level1_Locations = []
        self.level2_Locations = []
        self.level3_Locations = []
        self.counter_Locations = []

        self.availableCounters = 1
        self.availableLevel1 = 0
        self.availableLevel2 = 0
        self.availableLevel3 = 0

        self.crownHealth = 10
        super.init()

    }

    convenience init(color: UIColor, name: String, ID: Int, crowns:[CGPoint], isHuman: Bool){
        self.init()
        self.color = color
        self.name = name
        self.playerId = ID
        self.crown_Locations = crowns
        self.isPlayerHuman = isHuman
        self.playerScore = 0

        self.numberOfLevel3 = 0
        self.numberOfLevel1 = 0
        self.numberOfCrowns = 0
        self.numberOfLevel2 = 0
        self.deployedCounters = 0

        self.level1_Locations = []
        self.level3_Locations = []
        self.level2_Locations = []
        self.counter_Locations = []

        self.availableCounters = 1
        self.availableLevel1 = 0
        self.availableLevel2 = 0
        self.availableLevel3 = 0

        self.crownHealth = 10

    }

    func totalTiles() -> Int{
        return (self.numberOfCrowns! + self.numberOfLevel1! + self.numberOfLevel2! + self.numberOfLevel3! + self.deployedCounters!)
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let playerCopy = Player()
        playerCopy.color = self.color!
        playerCopy.name = self.name!
        playerCopy.playerId = self.playerId
        playerCopy.isPlayerHuman = self.isPlayerHuman
        playerCopy.playerScore = self.playerScore
        playerCopy.gameTheme = self.gameTheme

        playerCopy.numberOfLevel1 = self.numberOfLevel1
        playerCopy.numberOfLevel2 = self.numberOfLevel2
        playerCopy.numberOfLevel3 = self.numberOfLevel3
        playerCopy.numberOfCrowns = self.numberOfCrowns
        playerCopy.deployedCounters = self.deployedCounters

        playerCopy.crown_Locations = self.crown_Locations
        playerCopy.level1_Locations = self.level1_Locations
        playerCopy.level2_Locations = self.level2_Locations
        playerCopy.level3_Locations = self.level3_Locations
        playerCopy.counter_Locations = self.counter_Locations

        playerCopy.crownHealth = self.crownHealth

        return playerCopy
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.color!, forKey: "Player_color")
        aCoder.encode(self.name!, forKey: "Player_name")
        aCoder.encode(self.playerId, forKey: "Player_playerId")
        aCoder.encode(self.isPlayerHuman!, forKey: "Player_isPlayerHuman")
        aCoder.encode(self.playerScore!, forKey: "Player_playerScore")
        aCoder.encode(self.gameTheme!.rawValue, forKey: "Player_gameTheme")

        aCoder.encode(self.numberOfLevel1!, forKey: "Player_numberOfLevel1")
        aCoder.encode(self.numberOfLevel2!, forKey: "Player_numberOfLevel2")
        aCoder.encode(self.numberOfLevel3!, forKey: "Player_numberOfLevel3")
        aCoder.encode(self.numberOfCrowns!, forKey: "Player_numberOfCrowns")
        aCoder.encode(self.deployedCounters!, forKey: "Player_deployedCounters")

        aCoder.encode(self.crown_Locations!, forKey: "Player_crownLocations")
        aCoder.encode(self.level1_Locations!, forKey: "Player_level1Locations")
        aCoder.encode(self.level2_Locations!, forKey: "Player_level2Locations")
        aCoder.encode(self.level3_Locations!, forKey: "Player_level3Locations")
        aCoder.encode(self.counter_Locations!, forKey: "Player_counterLocations")

        aCoder.encode(self.availableCounters!, forKey: "Player_availableCounters")
        aCoder.encode(self.availableLevel1!, forKey: "Player_availableLevel1")
        aCoder.encode(self.availableLevel2!, forKey: "Player_availableLevel2")
        aCoder.encode(self.availableLevel3!, forKey: "Player_availableLevel3")

        aCoder.encode(self.crownHealth!, forKey: "Player_crownHealth")
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        if let data = aDecoder.decodeObject(forKey: "Player_color") as? UIColor {
            self.color = data
        }
        if let data = aDecoder.decodeObject(forKey: "Player_name") as? String {
            self.name = data
        }
        self.playerId = aDecoder.decodeInteger(forKey: "Player_playerId")
        self.isPlayerHuman = aDecoder.decodeBool(forKey: "Player_isPlayerHuman")
        self.playerScore = aDecoder.decodeInteger(forKey: "Player_playerScore")

        let data = aDecoder.decodeInteger(forKey: "Player_gameTheme")
        self.gameTheme = GameTheme(rawValue: data)

        self.numberOfLevel1 = aDecoder.decodeInteger(forKey: "Player_numberOfLevel1")
        self.numberOfLevel2 = aDecoder.decodeInteger(forKey: "Player_numberOfLevel2")
        self.numberOfLevel3 = aDecoder.decodeInteger(forKey: "Player_numberOfLevel3")
        self.numberOfCrowns = aDecoder.decodeInteger(forKey: "Player_numberOfCrowns")
        self.deployedCounters = aDecoder.decodeInteger(forKey: "Player_deployedCounters")

        if let data = aDecoder.decodeObject(forKey: "Player_crownLocations") as? [CGPoint] {
            self.crown_Locations = data
        }
        if let data = aDecoder.decodeObject(forKey: "Player_level1Locations") as? [CGPoint] {
            self.level1_Locations = data
        }
        if let data = aDecoder.decodeObject(forKey: "Player_level2Locations") as? [CGPoint] {
            self.level2_Locations = data
        }
        if let data = aDecoder.decodeObject(forKey: "Player_level3Locations") as? [CGPoint] {
            self.level3_Locations = data
        }
        if let data = aDecoder.decodeObject(forKey: "Player_counterLocations") as? [CGPoint] {
            self.counter_Locations = data
        }

        self.availableCounters = aDecoder.decodeInteger(forKey: "Player_availableCounters")
        self.availableLevel1 = aDecoder.decodeInteger(forKey: "Player_availableLevel1")
        self.availableLevel2 = aDecoder.decodeInteger(forKey: "Player_availableLevel2")
        self.availableLevel3 = aDecoder.decodeInteger(forKey: "Player_availableLevel3")
        self.crownHealth = aDecoder.decodeInteger(forKey: "Player_crownHealth")
    }
}
