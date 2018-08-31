//
// Created by Aleksandr Grin on 12/13/17.
// Copyright (c) 2017 AleksandrGrin. All rights reserved.
//

import Foundation
import GameplayKit

enum TileTypes:Int {
    case empty = 0  //This value is used to represent tiles not filled in at all
    case neutral = 1
    case level1
    case level2
    case level3
    case crown
    case counter
}

//Because tile definitions cannot store tile-specific info we will make a 2D array to represent
// the game board and then update the tile information inside this 2D array to translate to the
// board manually.
class TileInformation:NSObject, NSCoding {
    // 0 - false: tile is not adjacent
    // 1+  true: tile is adjacent and with playerID
    var isTileAdjacent:Int?
    //Shows which direction has adjacent tiles of the same player
    var tileAdjacencyMatrix:Array<TileAdjacencyDirections>?
    //Which player controls this tile, a nil indicates unclaimed
    var owningPlayer:Player?
    //The type of tile this is. Even if it is player owned, we will use neutral tile names.
    var tileType:TileTypes?
    //If your crown only borders one enemy tile.
    var isBorderingPlayer:Bool?

    override init(){
        self.isTileAdjacent = 0
        self.tileAdjacencyMatrix = []
        self.owningPlayer = nil
        self.tileType = .empty
        self.isBorderingPlayer = false
    }

    convenience init(isTileAdjacent:Int?, tileAdjacencyMatrix:[TileAdjacencyDirections]?, owningPlayer: Player?, tileType:TileTypes?, isBorderingPlayer:Bool?){
        self.init()
        self.isTileAdjacent = isTileAdjacent
        self.tileAdjacencyMatrix = tileAdjacencyMatrix
        self.owningPlayer = owningPlayer
        self.tileType = tileType
        self.isBorderingPlayer = isBorderingPlayer
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.isTileAdjacent!, forKey: "TileInformation_isTileAdjacent")
        let adjacencyMatrix = self.tileAdjacencyMatrix!.map{ $0.rawValue }
        aCoder.encode(adjacencyMatrix, forKey: "TileInformation_tileAdjacencyMatrix")
        aCoder.encode(self.owningPlayer, forKey: "TileInformation_owningPlayer")
        aCoder.encode(self.tileType!.rawValue, forKey: "TileInformation_tileType")
        aCoder.encode(self.isBorderingPlayer!, forKey: "TileInformaiton_isBorderingPlayer")
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        self.isTileAdjacent = aDecoder.decodeInteger(forKey: "TileInformation_isTileAdjacent")

        if let data = aDecoder.decodeObject(forKey: "TileInformation_tileAdjacencyMatrix") as? [Int]{
            let adjacencyMatrix = data.map{TileAdjacencyDirections(rawValue: $0)!}
            self.tileAdjacencyMatrix = adjacencyMatrix
        }
        if let data = aDecoder.decodeObject(forKey: "TileInformation_owningPlayer") as? Player {
            self.owningPlayer = data
        }

        let data = aDecoder.decodeInteger(forKey: "TileInformation_tileType")
        self.tileType = TileTypes(rawValue: data)!

        self.isBorderingPlayer = aDecoder.decodeBool(forKey: "TileInformaiton_isBorderingPlayer")
    }

    public class func init2DCollection(rows: Int, columns:Int) -> [[TileInformation]]{
        var collection:[[TileInformation]] = []
        for i in 0..<rows {
            collection.append([TileInformation]())

            for _ in 0..<columns{
                collection[i].append(TileInformation())
            }
        }
        return collection
    }
}


class GameModel: NSObject, NSCoding, NSCopying, GKGameModel {

    //Note when accessing its [row][col] format. Used in CGPoint as CGPoint(x: col, y: row)
    var gameMapModel:[[TileInformation]]? = nil
    var players: [GKGameModelPlayer]? = nil
    var activePlayer: GKGameModelPlayer? = nil
    var difficulty:Difficulty? = nil

    required init(tileMap:[[TileInformation]], players: [GKGameModelPlayer] ){
        self.gameMapModel = tileMap
        self.players = players
    }

    ///**********************************Functions needed by Gameplay Kit AI to run the AI***********************************///
    // GK needs to be able to copy game models to create a search depth. It runs its possible moves on copies not originals
    func copy(with zone: NSZone?) -> Any {
        let copy = GameModel(tileMap: self.gameMapModel!, players: self.players!)
        copy.setGameModel(self)
        return copy

    }

    //Helper to the copy method, implemented from GKGameModel.
    func setGameModel(_ gameModel: GKGameModel) {
        if let inputModel = gameModel as? GameModel {
            self.gameMapModel = inputModel.gameMapModel
            self.players = inputModel.players
            self.activePlayer = inputModel.activePlayer
            self.difficulty = inputModel.difficulty
        }
    }

    //Determines all possible moves that can be made by this player.
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        if let playerObject = player as? Player {
            //Check for 'obvious' win and counter availability. First filtering step.
            if isWin(for: playerObject){ return nil }
            if playerObject.availableCounters == 0 { return nil }

            //Gather possible moves for player:
            var possibleMoves:[Move] = []
            possibleMoves.append(contentsOf: getMovesForPlayer(tileLocations: playerObject.counter_Locations!))
            possibleMoves.append(contentsOf: getMovesForPlayer(tileLocations: playerObject.crown_Locations!))
            possibleMoves.append(contentsOf: getMovesForPlayer(tileLocations: playerObject.level1_Locations!))
            possibleMoves.append(contentsOf: getMovesForPlayer(tileLocations: playerObject.level2_Locations!))
            possibleMoves.append(contentsOf: getMovesForPlayer(tileLocations: playerObject.level3_Locations!))

            //Some of the moves are duplicates so we must filter only for unique moves.
            var duplicateFilteredPossibleMoves:[Move] = []
            for move in possibleMoves {
                let existingMove = duplicateFilteredPossibleMoves.filter({$0.position == move.position})
                if existingMove.count == 0 {
                    duplicateFilteredPossibleMoves.append(move)
                }
            }

            //Get all possibleMoves which are related to neutral tiles. (have no owner)
            var possibleNeutralMoves:[Move] = duplicateFilteredPossibleMoves.filter({ $0.previousOwner == nil })
            var neutralMove:Move?

            if possibleNeutralMoves.count > 0 {
                //Sort the neutral tiles by value. The highest value tile is level 3, the lowest is level unclaimed.
                possibleNeutralMoves.sort(by: {
                    if $0.previousTile == .level3 {
                        return true //First is greater than second
                    }
                    if $0.previousTile == .level2 && $1.previousTile == .level3 {
                        return false //Second is greater than first
                    }
                    if $0.previousTile == .level1 && ($1.previousTile == .level3 || $1.previousTile == .level2) {
                        return false //Second is greater than first
                    }
                    if $0.previousTile == .neutral && ($1.previousTile != .neutral){
                        return false //Second is greater than first
                    }
                    return true //Should never be reached
                })

                //Since we sorted based on the value of the tile, we take the first which is highest value (Best Neutral Move).
                neutralMove = possibleNeutralMoves.first!
            }

            //I need a fancy sort function for the move...
            //I think I had one somewhere...
            //hmmmm

            //Get all the possible moves which involve attacking other players.
            let attackingMoves:[Move] = duplicateFilteredPossibleMoves.filter({
                if $0.previousOwner != nil{
                    return $0.previousOwner.playerId != playerObject.playerId
                }else { return false }
            })

            //We now sort the possible attacking moves into a 2D array where the rows are the moves related to one player
            var attackingMovesByPlayer:[[Move]] = []
            for _ in 0..<8 {
                attackingMovesByPlayer.append([])
            }
            for _player in self.players! {
                attackingMovesByPlayer[((_player as! Player).playerId - 1)].append(contentsOf: attackingMoves.filter({ $0.previousOwner!.playerId == _player.playerId &&
                                                                                    $0.previousOwner!.playerId != playerObject.playerId}))
            }

            //Next we sort the players by relative power. Weakest to strongest.
            var playerStrength:[Player] = self.players!.sorted(by: { getPower(of: $0 as! Player) < getPower(of: $1 as! Player)}) as! [Player]

            //Sort the playerStrength by crown distance. Closest crown is a better target.
            playerStrength.sort(by: {
                taxiCabDistanceFor(locA: $0.crown_Locations!.first!, locB: playerObject.crown_Locations!.first!) <
                        taxiCabDistanceFor(locA: $1.crown_Locations!.first!, locB: playerObject.crown_Locations!.first!)
            })

            //From out previous 2D array of possible attacking moves, we select the 1D array of the weakest player chosen.
            var targetPlayer:Player = playerStrength.first!
            for _player in playerStrength {
                if attackingMovesByPlayer[(_player.playerId - 1)].count != 0 {
                    targetPlayer = _player
                    break
                }
            }
            let chosenAttackingMoves:[Move] = attackingMovesByPlayer[(targetPlayer.playerId - 1)]

            //We now have a set of neutral moves and attacking moves to decide with.
            if self.difficulty != nil {
                switch self.difficulty! {
                    case .easy:
                        return self.calculateMoveForEasyAI(neutralMove: neutralMove,
                                chosenAttackingMoves: chosenAttackingMoves,
                                possibleNeutralMoves: possibleNeutralMoves,
                                playerObject: playerObject,
                                targetPlayer: targetPlayer)
                    case .medium:
                        return self.calculateMoveForMediumAI(neutralMove: neutralMove,
                                chosenAttackingMoves: chosenAttackingMoves,
                                possibleNeutralMoves: possibleNeutralMoves,
                                playerObject: playerObject,
                                targetPlayer: targetPlayer)
                    case .hard, .unfair1, .unfair2:
                        //The unfair difficulties use the hard AI with additional moves per turn.
                        return self.calculateMoveForHardAI(neutralMove: neutralMove,
                                chosenAttackingMoves: chosenAttackingMoves,
                                possibleNeutralMoves: possibleNeutralMoves,
                                playerObject: playerObject,
                                targetPlayer: targetPlayer)
                }
            }else{
                //Shouldn't happen, but just in case somehow the difficulty wasn't set.
                return self.calculateMoveForHardAI(neutralMove: neutralMove,
                        chosenAttackingMoves: chosenAttackingMoves,
                        possibleNeutralMoves: possibleNeutralMoves,
                        playerObject: playerObject,
                        targetPlayer: targetPlayer)
            }
        }
        return nil
    }

    private func calculateMoveForHardAI(neutralMove: Move?, chosenAttackingMoves:[Move], possibleNeutralMoves:[Move], playerObject:Player, targetPlayer:Player) -> [Move]?{
        var finalizedMove:[Move] = []

        //Special Priority1: If in the position to eliminate a player, kill the player. This increases agression.
        for move in chosenAttackingMoves {
            if move.previousTile == .crown{
                if let health = self.gameMapModel![Int(move.position.y)][Int(move.position.x)].owningPlayer!.crownHealth {
                    if playerObject.availableCounters! < health {
                        finalizedMove.append(move)
                        return finalizedMove
                    }
                }
            }
        }

        //Special Prioirity2: If we have a big advantage, try to drill towards the enemy crown to eliminate the player.
        if (playerObject.availableCounters! + playerObject.deployedCounters! >= 5) && (playerObject.availableCounters! > targetPlayer.availableCounters!){
            //Sort the attack moves by move closest to enemy crown.
            let attackingMoves:[Move] = chosenAttackingMoves.sorted(by: {
                self.taxiCabDistanceFor(locA: $0.position, locB: targetPlayer.crown_Locations!.first!) <
                        self.taxiCabDistanceFor(locA: $1.position, locB: targetPlayer.crown_Locations!.first!)
            })
            finalizedMove.append(attackingMoves.first!)
            return finalizedMove
        }

        //Priority 1: Take neutral level 3 tiles.
        if neutralMove != nil {
            if neutralMove!.previousTile == .level3{
                finalizedMove.append(neutralMove!)
                return finalizedMove
            }
        }
        //Priority 2: Take care of enemy tiles threatening your crown.
        for move in chosenAttackingMoves {
            if taxiCabDistanceFor(locA: move.position, locB: playerObject.crown_Locations!.first!) <= 3 {
                finalizedMove.append(move)
                return finalizedMove
            }
        }
        //Priority 3:Attack enemy crown
        for move in chosenAttackingMoves {
            if move.previousTile == .crown {
                finalizedMove.append(move)
                return finalizedMove
            }
        }
        //Priority 4: Take enemy tile which has a 3+ tile adjacency. If player has many tiles, attack deep into enemy
        //territory since this increases likelihood of splitting enemy.
        if playerObject.availableCounters! > 5 {
            for move in chosenAttackingMoves {
                if self.gameMapModel![Int(move.position.y)][Int(move.position.x)].tileAdjacencyMatrix!.count >= 4 {
                    finalizedMove.append(move)
                }
            }
        }else{
            for move in chosenAttackingMoves {
                if self.gameMapModel![Int(move.position.y)][Int(move.position.x)].tileAdjacencyMatrix!.count >= 3 {
                    finalizedMove.append(move)
                }
            }
        }
        if finalizedMove.count >= 1 {
            finalizedMove.sort(by: {
                taxiCabDistanceFor(locA: $0.position, locB: targetPlayer.crown_Locations!.first!) <
                        taxiCabDistanceFor(locA: $1.position, locB: targetPlayer.crown_Locations!.first!)
            })
            finalizedMove.append(finalizedMove[0])
            return finalizedMove
        }
        //Priority 5: Fortify the crown by taking empty adjacent spaces.
        for move in possibleNeutralMoves {
            if taxiCabDistanceFor(locA: move.position, locB: playerObject.crown_Locations!.first!) <= 2 {
                finalizedMove.append(move)
                return finalizedMove
            }
        }
        //Priority 6: Take neutral level 2
        if neutralMove != nil {
            if neutralMove!.previousTile == .level2 || neutralMove!.previousTile == .level1 || neutralMove!.previousTile == .neutral {
                finalizedMove.append(neutralMove!)
                return finalizedMove
            }
        }
        //Priority 7: Take enemy tile which has a 1+ tile adjacency.
        for move in chosenAttackingMoves {
            if self.gameMapModel![Int(move.position.y)][Int(move.position.x)].tileAdjacencyMatrix!.count >= 1 {
                finalizedMove.append(move)
            }
        }
        if finalizedMove.count >= 1 {
            finalizedMove.sort(by: {
                taxiCabDistanceFor(locA: $0.position, locB: targetPlayer.crown_Locations!.first!) <
                        taxiCabDistanceFor(locA: $1.position, locB: targetPlayer.crown_Locations!.first!)
            })
            finalizedMove.append(finalizedMove[0])
            return finalizedMove
        }
        //Priority 8: Take neutral level 1 and unclaimed tiles.
        if neutralMove != nil {
            if neutralMove!.previousTile == .level1 || neutralMove!.previousTile == .neutral {
                finalizedMove.append(neutralMove!)
                return finalizedMove
            }
        }

        //Priority 9: Further Fortify the crown by taking empty adjacent spaces.
        for move in possibleNeutralMoves {
            if taxiCabDistanceFor(locA: move.position, locB: playerObject.crown_Locations!.first!) <= 3 {
                finalizedMove.append(move)
                return finalizedMove
            }
        }
        //Default Priority
        if chosenAttackingMoves.count >= 1 {
            finalizedMove.append(chosenAttackingMoves.first!)
            return finalizedMove
        }else{
            return nil  //Shouldnt happen.
        }
    }

    private func calculateMoveForMediumAI(neutralMove: Move?, chosenAttackingMoves:[Move], possibleNeutralMoves:[Move], playerObject:Player, targetPlayer:Player) -> [Move]? {
        var finalizedMove:[Move] = []
        //Priority 1: Take care of enemy tiles threatening your crown.
        for move in chosenAttackingMoves {
            if taxiCabDistanceFor(locA: move.position, locB: playerObject.crown_Locations!.first!) <= 2 {
                finalizedMove.append(move)
                return finalizedMove
            }
        }
        //Priority 2: If there is an empty level 3 or level 2 tile take it
        if neutralMove != nil {
            if neutralMove!.previousTile == .level3 || neutralMove!.previousTile == .level2 {
                finalizedMove.append(neutralMove!)
                return finalizedMove
            }
        }
        //Priority 3: Fortify the crown by taking empty adjacent spaces.
        for move in possibleNeutralMoves {
            if taxiCabDistanceFor(locA: move.position, locB: playerObject.crown_Locations!.first!) <= 2 {
                finalizedMove.append(move)
                return finalizedMove
            }
        }
        //Priority 4: Take enemy tile which has a 3 tile adjacency.
        for move in chosenAttackingMoves {
            if self.gameMapModel![Int(move.position.y)][Int(move.position.x)].tileAdjacencyMatrix!.count >= 3 {
                finalizedMove.append(move)
            }
        }
        if finalizedMove.count >= 1 {
            finalizedMove.sort(by: {
                taxiCabDistanceFor(locA: $0.position, locB: targetPlayer.crown_Locations!.first!) <
                taxiCabDistanceFor(locA: $1.position, locB: targetPlayer.crown_Locations!.first!)
            })
            finalizedMove.append(finalizedMove[0])
            return finalizedMove
        }
        //Priority 5: Take neutral level 1 and unclaimed Tiles.
        if neutralMove != nil {
            if neutralMove!.previousTile == .level1 || neutralMove!.previousTile == .neutral {
                finalizedMove.append(neutralMove!)
                return finalizedMove
            }
        }
        //Priority 6: Take enemy tiles having 2 tile adjacency.
        for move in chosenAttackingMoves {
            if self.gameMapModel![Int(move.position.y)][Int(move.position.x)].tileAdjacencyMatrix!.count >= 2 {
                finalizedMove.append(move)
            }
        }
        if finalizedMove.count >= 1 {
            finalizedMove.sort(by: {
                taxiCabDistanceFor(locA: $0.position, locB: targetPlayer.crown_Locations!.first!) <
                        taxiCabDistanceFor(locA: $1.position, locB: targetPlayer.crown_Locations!.first!)
            })
            finalizedMove.append(finalizedMove[0])
            return finalizedMove
        }
        //Priority 7:Attack enemy crown
        for move in chosenAttackingMoves {
            if move.previousTile == .crown {
                finalizedMove.append(move)
                return finalizedMove
            }
        }
        //Defualt Priority
        if chosenAttackingMoves.count >= 1 {
            finalizedMove.append(chosenAttackingMoves.first!)
            return finalizedMove
        }else{
            return nil  //Shouldnt happen.
        }
    }

    private func calculateMoveForEasyAI(neutralMove: Move?, chosenAttackingMoves:[Move], possibleNeutralMoves:[Move], playerObject:Player, targetPlayer:Player) -> [Move]?{
        var finalizedMove:[Move] = []
        //Priority 1: Take neutral level 3 tiles.
        if neutralMove != nil {
            if neutralMove!.previousTile == .level3{
                finalizedMove.append(neutralMove!)
                return finalizedMove
            }
        }
        //Priority 2: Take neutral level 2, level 1, and unclaimed Tiles.
        if neutralMove != nil {
            if neutralMove!.previousTile == .level2 || neutralMove!.previousTile == .level1 || neutralMove!.previousTile == .neutral {
                finalizedMove.append(neutralMove!)
                return finalizedMove
            }
        }
        //Priority 3: Fortify the crown by taking empty adjacent spaces.
        for move in possibleNeutralMoves {
            if taxiCabDistanceFor(locA: move.position, locB: playerObject.crown_Locations!.first!) <= 2 {
                finalizedMove.append(move)
                return finalizedMove
            }
        }
        //Priority 4: Take enemy tile which has a 1+ tile adjacency.
        for move in chosenAttackingMoves {
            if self.gameMapModel![Int(move.position.y)][Int(move.position.x)].tileAdjacencyMatrix!.count >= 1 {
                finalizedMove.append(move)
            }
        }
        if finalizedMove.count >= 1 {
            finalizedMove.sort(by: {
                taxiCabDistanceFor(locA: $0.position, locB: targetPlayer.crown_Locations!.first!) <
                        taxiCabDistanceFor(locA: $1.position, locB: targetPlayer.crown_Locations!.first!)
            })
            finalizedMove.append(finalizedMove[0])
            return finalizedMove
        }
        let stupidMoveModifier:Int = Int(arc4random_uniform(6))

        //Priority 5:Attack enemy crown
        if stupidMoveModifier <= 5 {
            for move in chosenAttackingMoves {
                if move.previousTile == .crown {
                    finalizedMove.append(move)
                    return finalizedMove
                }
            }
        }
        //Default Priority
        if chosenAttackingMoves.count >= 1 {
            finalizedMove.append(chosenAttackingMoves.first!)
            return finalizedMove
        }else{
            return nil  //Shouldnt happen.
        }
    }

    //Get a set of moves from the player tile locations passed in.
    private func getMovesForPlayer(tileLocations: [CGPoint]) -> [Move]{
        let directionsToCheck:Array<TileAdjacencyDirections> = [.E, .NE, .NW, .W, .SW, .SE]
        var possibleMoves:[Move] = []

        //Check each tile in player owned tiles.
        for location in tileLocations {
            //Check all 6 directly adjacent tiles around this tile.
            for direction in directionsToCheck {
                let adjacentTile = findOddRNeighboringTile(for: location, direction: direction)
                if self.doesTileExistAt(location: adjacentTile) == true{

                    //If the tile exists then we can move there so add it to our possibleMoves.
                    //let realRow = self.gameMapModel!.count - Int(adjacentTile.y) - 1
                    let newMove = Move(tileBiengPlaced: .counter, at: CGPoint(x: Int(adjacentTile.x), y: Int(adjacentTile.y)))
                    //Add the tileType so we can filter out different tile precedence.
                    newMove.previousTile = self.gameMapModel![Int(adjacentTile.y)][Int(adjacentTile.x)].tileType!

                    if self.gameMapModel![Int(adjacentTile.y)][Int(adjacentTile.x)].owningPlayer != nil {
                        //Add the previousOwner so we can distinguish which tiles are enemy and which are neutral.
                        newMove.previousOwner = self.gameMapModel![Int(adjacentTile.y)][Int(adjacentTile.x)].owningPlayer!
                    }
                    //Only add the move to the array if we do not already contain it.
                    let existingMove = possibleMoves.filter({$0.position == newMove.position})
                    if existingMove.count == 0 {
                        possibleMoves.append(newMove)
                    }
                }
            }
        }

        return possibleMoves
    }

    //Returns the taxi cab distance between two points A and B.
    private func taxiCabDistanceFor(locA: CGPoint, locB: CGPoint) -> Int{
        return Int(abs(locA.x - locB.x) + abs(locA.y - locB.y))
    }

    //Returns the power measure of a player based on how many tiles the player has.
    private func getPower(of player:Player) -> Int {
        return (player.deployedCounters! + player.numberOfLevel1! + player.numberOfLevel2! * 2 + player.numberOfLevel3! * 3)
    }

    //Executes moves on a game board. Does not however, change the actual Game Tile Map
    func apply(_ gameModelUpdate: GKGameModelUpdate) {

    }

    func unapplyGameModelUpdate(_ gameModelUpdate: GKGameModelUpdate) {

    }

    //Figures out the current score of the player to determine whether a move just made was advantageous
    func score(for player: GKGameModelPlayer) -> Int {
        return 1    //All of the move evaluation is actually done in the gameplay model updates function.
    }

    //If this is the only player left on the board they win.
    func isWin(for player: GKGameModelPlayer) -> Bool {
        if self.players!.count == 1{
            return true
        }else{
            return false
        }
    }

    func isLoss(for player: GKGameModelPlayer) -> Bool {
        if (player as! Player).numberOfCrowns == 0 {
            return true
        }else{
            return false
        }
    }

    ///**********************************Functions supporting the choice of possible moves for AI*************************///

    // Uses functions from the group adjacency chain of functions to check whether a tapped location is a valid build
    // location. This is needed because you may only build adjacent to your existing territory.
    func isValidBuildLocation(of player:Player, for tile: CGPoint) -> Bool{
        let directionsToCheck:Array<TileAdjacencyDirections> = [.E, .NE, .NW, .W, .SW, .SE]
        for direction in directionsToCheck {
            if self.doesTileExistAt(location: tile) == false{
                return false
            }
            if self.gameMapModel![Int(tile.y)][Int(tile.x)].owningPlayer != nil{
                if self.gameMapModel![Int(tile.y)][Int(tile.x)].owningPlayer!.playerId == player.playerId{
                    return false
                }
            }
            let adjacentTile = findOddRNeighboringTile(for: tile, direction: direction)
            if self.doesTileExistAt(location: adjacentTile) == true {
                if self.gameMapModel![Int(adjacentTile.y)][Int(adjacentTile.x)].owningPlayer != nil {
                    if self.gameMapModel![Int(adjacentTile.y)][Int(adjacentTile.x)].owningPlayer!.playerId == player.playerId{
                        return true
                    }
                }
            }
        }
        return false
    }

    //Checks to make sure a tile actully exists at the location. Note this is not the same as an "Unclaimed" tile.
    private func doesTileExistAt(location: CGPoint) -> Bool{
        if Int(location.x) < 0 || Int(location.y) < 0 {
            return false
        }
        if Int(location.x) > self.gameMapModel![0].count-1 || Int(location.y) > self.gameMapModel!.count-1 {
            return false
        }
        if self.gameMapModel != nil {
            if self.gameMapModel![Int(location.y)][Int(location.x)].tileType != TileTypes.empty {
                return true
            }else{
                return false
            }
        }else{
            print("FATAL ERROR NO GAME BOARD \(#function)")
        }
        return false
    }

    //Uses a mapping to get coordinatess of an adjacent tile. Tile coordinates are in (x: col, y: row)
    private func findOddRNeighboringTile(for tile:CGPoint, direction: TileAdjacencyDirections) -> CGPoint{
        let parity = Int(tile.y) & 1
        let offset = oddR_Directions[parity][direction.rawValue]
        return CGPoint(x: Int(tile.x) + offset.dCol, y: Int(tile.y) + offset.dRow)
    }

    private func checkForPlayerLoss(){
        for player in self.players! as! [Player]{
            if player.numberOfCrowns == 0{
                if let index = self.players!.index(where: {($0 as! Player) == player}){
                    self.players!.remove(at: index)
                }

            }
        }
    }

    private func advancePlayer(){
        //self.updateAvailableTilesToBuild(for: self.activePlayer! as! Player)
        if self.players!.count != 1 {
            for player in self.players! {
                if player.playerId == self.activePlayer!.playerId {
                    let index = Int(self.players!.index(where: {$0.playerId == player.playerId })!)
                    if index < self.players!.count - 1 {
                        self.activePlayer! = self.players![index + 1]
                        return
                    }else{
                        self.activePlayer! = self.players!.first!
                        return
                    }
                }
            }
        }
    }

    private func revertPlayer(){
        if self.players!.count != 1{
            for player in self.players! {
                if player.playerId == self.activePlayer!.playerId {
                    let index = Int(self.players!.index(where: {$0.playerId == player.playerId })!)
                    if index > 0{
                        self.activePlayer! = self.players![index - 1]
                        return
                    }else{
                        self.activePlayer! = self.players![self.players!.count - 1]
                        return
                    }
                }
            }
        }
    }

    ///*********************************Functions updating the GameModel Tile Data**************************************///

    func addTilesToPlayer(player: Player, tile: TileTypes, location: CGPoint){
        switch tile {
            case .crown:
                player.crown_Locations!.append(location)
                player.numberOfCrowns! += 1
                break
            case .counter:
                player.counter_Locations!.append(location)
                player.deployedCounters! += 1
                break
            case .level1:
                player.level1_Locations!.append(location)
                player.numberOfLevel1! += 1
                break
            case .level2:
                player.level2_Locations!.append(location)
                player.numberOfLevel2! += 1
                break
            case .level3:
                player.level3_Locations!.append(location)
                player.numberOfLevel3! += 1
                break
        default:
        break
        }
    }

    func removeTileFromPlayer(player: Player, tile: TileTypes, location: CGPoint){
        switch tile {
        case .crown:
            if let index = player.crown_Locations!.index(of: location) {
                player.crown_Locations!.remove(at: index)
                player.numberOfCrowns! -= 1
            }
            break
        case .counter:
            if let index = player.counter_Locations!.index(of: location){
                player.counter_Locations!.remove(at: index)
                player.deployedCounters! -= 1
            }
            break
        case .level1:
            if let index = player.level1_Locations!.index(of: location) {
                player.level1_Locations!.remove(at: index)
                player.numberOfLevel1! -= 1
            }
            break
        case .level2:
            if let index = player.level2_Locations!.index(of: location) {
                player.level2_Locations!.remove(at: index)
                player.numberOfLevel2! -= 1
            }
            break
        case .level3:
            if let index = player.level3_Locations!.index(of: location) {
                player.level3_Locations!.remove(at: index)
                player.numberOfLevel3! -= 1
            }
            break
        default:
            break
        }
    }
    //Scans the board and updates the number of each tile a player owns on the map.
    func updateAmountOfTiles(for player:Player){
        let countedCrowns = countTiles(of: .crown, playerID: player.playerId)
        player.crown_Locations = countedCrowns
        player.numberOfCrowns = countedCrowns.count

        let countedLevel1 = countTiles(of: .level1, playerID: player.playerId)
        player.level1_Locations = countedLevel1
        player.numberOfLevel1 = countedLevel1.count

        let countedLevel2 = countTiles(of: .level2, playerID: player.playerId)
        player.level2_Locations = countedLevel2
        player.numberOfLevel2 = countedLevel2.count

        let countedLevel3 = countTiles(of: .level3, playerID: player.playerId)
        player.level3_Locations = countedLevel3
        player.numberOfLevel3 = countedLevel3.count

        let countedCounters = countTiles(of: .counter, playerID: player.playerId)
        player.counter_Locations = countedCounters
        player.deployedCounters = countedCounters.count
    }

    //Need a function to count the number of tile objects.
    //Counts the number of tiles owned by a player of a single type. This is used by the model for the AI calculations
    func countTiles(of type: TileTypes, playerID:Int) -> Array<CGPoint>{
        var locationsOfTiles:Array<CGPoint> = []

        for row in 0..<self.gameMapModel!.count{
            for col in 0..<self.gameMapModel![row].count{
                if self.gameMapModel![row][col].owningPlayer != nil{
                    if self.gameMapModel![row][col].tileType == type && self.gameMapModel![row][col].owningPlayer!.playerId == playerID{
                        locationsOfTiles.append(CGPoint(x: col, y: row))
                    }
                }
            }
        }
        return locationsOfTiles
    }
    //Yeah. Its that easy.

    //Counts the number of tiles a player can build on their turn
    func updateAvailableTilesToBuild(for player:Player, difficulty:Difficulty){
        var difficultyModifier = 0
        if player.isPlayerHuman == false {
            if difficulty == .unfair2 {
                difficultyModifier = 2
            }
            if difficulty == .unfair1 {
                difficultyModifier = 1
            }
        }

        player.availableCounters! = (player.availableCounters! + (player.numberOfCrowns! + player.numberOfLevel3!)) + difficultyModifier

        player.availableLevel1! = {()->Int in
            if (player.deployedCounters! / tileConstructionRatios.level0_RequiredForLevel1) > 0 {
                return (player.deployedCounters! / tileConstructionRatios.level0_RequiredForLevel1)
            }else{ return 0 }
        }()

        player.availableLevel2 = {()->Int in
            if (((player.numberOfLevel1! + player.numberOfLevel2!) / tileConstructionRatios.level1_RequiredForLevel2) - player.numberOfLevel2!) > 0 {
                return ((player.numberOfLevel1! / tileConstructionRatios.level1_RequiredForLevel2) - player.numberOfLevel2!)
            }else{ return 0 }
        }()

        player.availableLevel3 = {()->Int in
            if (((player.numberOfLevel2! + player.numberOfLevel3!) / tileConstructionRatios.level2_RequiredForLevel3) - player.numberOfLevel3!) > 0 {
                return  ((player.numberOfLevel2! / tileConstructionRatios.level2_RequiredForLevel3) - player.numberOfLevel3!)
            }else{ return 0 }
        }()

    }

    ///**********************************Tile Adjacency Functions, called after each update****************************///

    //Checks adjacency of player placed tiles in reference to thier crowns, because all tiles must be connected to a crown.
    // The primary use case is figuring out if a player has cut off another players tiles and therefore caused a "surround"
    // whereby the cut-off tiles will cease to exist.
    func findAdjacentGroups(for players:Array<Player>){
        for row in 0..<self.gameMapModel!.count{
            for col in 0..<self.gameMapModel![row].count{
                for player in players {
                    if self.gameMapModel![row][col].isTileAdjacent == player.playerId {
                        self.gameMapModel![row][col].isTileAdjacent = 0
                    }
                }
            }
        }
        if self.gameMapModel != nil {
            for player in players{
                for crown in player.crown_Locations! {
                    checkAdjacency(for: crown, directions: [.E, .NE, .NW, .W, .SW, .SE], player: player)
                }
            }
        }else{
            print("FATAL ERROR NO GAME MODEL \(#function)")
        }
    }

    //Recursive function that does the actual "heavy-lifting" of checking whether there are adjacent tiles in the
    // directions outlined. For our purpose we will check every direction.
    private func checkAdjacency(for tile: CGPoint, directions: Array<TileAdjacencyDirections>, player:Player) {
        let tileTypeOfTile = self.gameMapModel![Int(tile.y)][Int(tile.x)].tileType!
        if self.gameMapModel![Int(tile.y)][Int(tile.x)].isTileAdjacent == 0 {
            self.gameMapModel![Int(tile.y)][Int(tile.x)] = TileInformation(isTileAdjacent: player.playerId,
                    tileAdjacencyMatrix: [],
                    owningPlayer: player,
                    tileType: tileTypeOfTile,
                    isBorderingPlayer: false
            )
        }
        var tilesToCheck: Array<CGPoint> = []
        var adjacentTiles: Array<TileAdjacencyDirections> = []
        var isBorderingPlayer: Bool = false

        for direction in directions {
            let adjacentTile = findOddRNeighboringTile(for: tile, direction: direction)
            if doesTileExistAt(location: adjacentTile) == true {
                if self.gameMapModel != nil {
                    //If the adjacentTile found is already marked as adjacent then there is no need to mark again.
                    if self.gameMapModel![Int(adjacentTile.y)][Int(adjacentTile.x)].isTileAdjacent! == 0 {
                        if self.gameMapModel![Int(adjacentTile.y)][Int(adjacentTile.x)].owningPlayer != nil {
                            if self.gameMapModel![Int(adjacentTile.y)][Int(adjacentTile.x)].owningPlayer!.playerId == player.playerId {
                                //If the adjacent tile belongs to the current player we will check its adjacent tiles as well.
                                adjacentTiles.append(direction)
                                tilesToCheck.append(adjacentTile)

                            } else if self.gameMapModel![Int(adjacentTile.y)][Int(adjacentTile.x)].owningPlayer!.playerId == self.activePlayer!.playerId {
                                //If the adjacent tile belongs to another player then we will not check adjacency but will indicate a border.
                                isBorderingPlayer = true
                            }
                        }
                    } else {
                        if self.gameMapModel![Int(adjacentTile.y)][Int(adjacentTile.x)].owningPlayer != nil {
                            //Even though we wont check a redundantly adjacent tile, we need to know in child tile that it is adjacent to the parent
                            // This is mostly for the wall making algorithm.
                            if self.gameMapModel![Int(adjacentTile.y)][Int(adjacentTile.x)].owningPlayer!.playerId == player.playerId {
                                //If the adjacent tile belongs to the current player we will check its adjacent tiles as well.
                                adjacentTiles.append(direction)

                            } else if self.gameMapModel![Int(adjacentTile.y)][Int(adjacentTile.x)].owningPlayer!.playerId == self.activePlayer!.playerId {
                                isBorderingPlayer = true
                            }
                        }
                    }
                }
            }
        }

        if adjacentTiles.count != 0 {
            if self.gameMapModel != nil {
                //Fix the tile type!
                self.gameMapModel![Int(tile.y)][Int(tile.x)] = TileInformation(isTileAdjacent: player.playerId,
                        tileAdjacencyMatrix: adjacentTiles,
                        owningPlayer: player,
                        tileType: tileTypeOfTile,
                        isBorderingPlayer: isBorderingPlayer)
            }
        } else {
            if isBorderingPlayer == true {
                //This is a special case for singular crown tiles. Because adjacentTiles only counts friendly tiles, it will be 0 even with 1 enemy tile.
                self.gameMapModel![Int(tile.y)][Int(tile.x)].isBorderingPlayer = isBorderingPlayer
            }
        }

        if tilesToCheck.count != 0 {
            for tile in tilesToCheck {
                checkAdjacency(for: tile, directions: directions, player: player)
            }
        } else {
            return
        }
    }

    ///***********************************************debug**********************************************************///

    func debug_printOwnerShip(){
        var output = ""
        for i in 0..<self.gameMapModel!.count {
            for j in 0..<self.gameMapModel![i].count {
                let realRow = self.gameMapModel!.count - i - 1
                if j % self.gameMapModel![0].count == 0 {
                    output += "\n"
                }
                if self.gameMapModel![realRow][j].owningPlayer != nil {
                    output += "[\(self.gameMapModel![realRow][j].owningPlayer!.playerId)]"
                }else{
                    output += "[0]"
                }
            }
        }
        print(output)
    }

    func debug_printTileType(){
        var output = ""
        for i in 0..<self.gameMapModel!.count {
            for j in 0..<self.gameMapModel![i].count {
                let realRow = self.gameMapModel!.count - i - 1
                if j % self.gameMapModel![0].count == 0 {
                    output += "\n"
                }
                if self.gameMapModel![realRow][j].tileType != nil {
                    output += "[\(self.gameMapModel![realRow][j].tileType!.rawValue)]"
                }else{
                    output += "[0]"
                }
            }
        }
        print(output)
    }

    func debug_printAdjacency(){
        var output = ""
        for i in 0..<self.gameMapModel!.count {
            for j in 0..<self.gameMapModel![i].count {
                let realRow = self.gameMapModel!.count - i - 1
                if j % self.gameMapModel![0].count == 0 {
                    output += "\n"
                }
                if self.gameMapModel![realRow][j].isTileAdjacent != nil {
                    output += "[\(self.gameMapModel![realRow][j].isTileAdjacent!)]"
                }else{
                    output += "[0]"
                }
            }
        }
        print(output)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.gameMapModel!, forKey: "GameModel_gameMapModel")
        aCoder.encode((self.players! as! [Player]), forKey: "GameModel_players")
        aCoder.encode((self.activePlayer! as! Player), forKey: "GameModel_activePlayer")
        aCoder.encode(self.difficulty!.rawValue, forKey: "GameModel_difficulty")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init()
        if let data = aDecoder.decodeObject(forKey: "GameModel_gameMapModel") as? [[TileInformation]]{
            self.gameMapModel = data
        }
        if let data = aDecoder.decodeObject(forKey: "GameModel_players") as? [Player]{
            self.players = (data as [GKGameModelPlayer])
        }
        if let data = aDecoder.decodeObject(forKey: "GameModel_activePlayer") as? Player {
            self.activePlayer = data
        }
        let data = aDecoder.decodeInteger(forKey: "GameModel_difficulty")
        self.difficulty = Difficulty(rawValue: data)!
    }
}
