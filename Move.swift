//
// Created by Aleksandr Grin on 12/13/17.
// Copyright (c) 2017 AleksandrGrin. All rights reserved.
//

import Foundation
import GameplayKit

//This defines what a move looks like for the AI. In our case we have a tile to place and a position to place it.
class Move: NSObject, NSCoding, GKGameModelUpdate {
    var tileToPlace:TileTypes = .empty
    var position:CGPoint = CGPoint(x: 0, y: 0)
    var value: Int = 0
    var previousTile:TileTypes = .empty
    var previousOwner:GKGameModelPlayer!

    init(tileBiengPlaced: TileTypes, at position: CGPoint){
        self.tileToPlace = tileBiengPlaced
        self.position = position
        self.previousOwner = nil
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.tileToPlace.rawValue, forKey: "Move_tileToPlace")
        aCoder.encode(self.position, forKey: "Move_position")
        aCoder.encode(self.value, forKey: "Move_value")
        aCoder.encode(self.previousTile.rawValue, forKey: "Move_previousTIle")
        aCoder.encode(self.previousOwner, forKey: "Move_previousOwner")
    }

    required init?(coder aDecoder: NSCoder) {
        if let data = aDecoder.decodeObject(forKey: "Move_tileToPlace") as? Int {
            self.tileToPlace = TileTypes(rawValue: data)!
        }
        if let data = aDecoder.decodeObject(forKey: "Move_position") as? CGPoint {
            self.position = data
        }
        self.value = aDecoder.decodeInteger(forKey: "Move_value")
        if let data = aDecoder.decodeObject(forKey: "Move_previousTIle") as? Int {
            self.previousTile = TileTypes(rawValue: data)!
        }
        if let data = aDecoder.decodeInteger(forKey: "Move_previousOwner") as? GKGameModelPlayer {
            self.previousOwner = data
        }
    }
}