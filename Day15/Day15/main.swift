//
//  main.swift
//  Day15
//
//  Created by Andrew R Madsen on 12/14/18.
//  Copyright © 2018 Open Reel Software. All rights reserved.
//

import Foundation

let test = true

let args = ProcessInfo.processInfo.arguments
let inputPath = (args[1] as NSString).expandingTildeInPath as String

let inputString = try! String(contentsOfFile: inputPath)
let testInputString = """
#########
#G......#
#.E.#...#
#..##..G#
#...##..#
#...#...#
#.G...G.#
#.....G.#
#########
"""
let input = (test ? testInputString : inputString)

struct Location: Hashable {
    var x, y: Int

    func numberOfMoves(to location: Location) -> Int {
        return Int((location.x - x).magnitude +
            (location.y - y).magnitude)
    }

    func inReadingOrderIsBefore(_ location: Location) -> Bool {
        return y == location.y ? x < location.x : y < location.y
    }
}

class Piece: Equatable {
    init(type: PieceType, location: Location) {
        self.type = type
        self.location = location
    }

    convenience init?(character: Character, location: Location) {
        guard let type = PieceType(rawValue: character) else { return nil }
        self.init(type: type, location: location)
    }

    enum PieceType: Character, Hashable {
        case wall = "#"
        case empty = "."
        case elf = "E"
        case goblin = "G"

        var enemyType: PieceType {
            switch self {
            case .elf: return .goblin
            case .goblin: return .elf
            default: return self
            }
        }
    }

    static func ==(lhs: Piece, rhs: Piece) -> Bool {
        if lhs.type != rhs.type { return false }
        if lhs.location != rhs.location { return false }
        if lhs.hitPoints != rhs.hitPoints { return false }
        if lhs.attackPower != rhs.attackPower { return false }
        return true
    }

    let type: PieceType
    var location: Location
    let attackPower = 3
    var hitPoints = 200

    var isPlayer: Bool {
        return [.elf, .goblin].contains(type)
    }
}

class PathNode: Hashable {
    init(location: Location) {
        self.location = location
    }
    let location: Location
    var nextSteps: Set<PathNode> = []

    func hash(into hasher: inout Hasher) {
        hasher.combine(location)
        for step in nextSteps {
            hasher.combine(step)
        }
    }

    static func ==(lhs: PathNode, rhs: PathNode) -> Bool {
        if lhs.location != rhs.location { return false }
        return lhs.nextSteps == rhs.nextSteps
    }

    var minDepth: Int {
        if nextSteps.count == 0 { return 0 }
        return (nextSteps.map { $0.minDepth }.min() ?? 0) + 1
    }

    var shortestNextSteps: Set<PathNode> {
        var result = Set<PathNode>()
        var subPathsByMinDepth = [Int : Set<PathNode>]()
        for step in nextSteps {
            subPathsByMinDepth[step.minDepth, default: []].insert(step)
        }
        if let minKey = subPathsByMinDepth.keys.min(),
            let subPaths = subPathsByMinDepth[minKey] {
            result.formUnion(subPaths)
        }
        return result
    }
}


func pieceAt(_ location: Location, in pieces: [Piece]) -> Piece? {
    return pieces.first { $0.location == location }
}

func locationsInReadingOrder(_ locations: [Location]) -> [Location] {
    return locations.sorted { $0.inReadingOrderIsBefore($1) }
}

func piecesInReadingOrder(_ pieces: [Piece]) -> [Piece] {
    return pieces.sorted { $0.location.inReadingOrderIsBefore($1.location) }
}

func squaresAdjacentTo(location: Location, in pieces: [Piece]) -> [Piece] {
    let x = location.x
    let y = location.y
    var result = [Piece]()
    if let p = pieceAt(Location(x: x-1, y: y), in: pieces) { result.append(p) }
    if let p = pieceAt(Location(x: x+1, y: y), in: pieces) { result.append(p) }
    if let p = pieceAt(Location(x: x, y: y-1), in: pieces) { result.append(p) }
    if let p = pieceAt(Location(x: x, y: y+1), in: pieces) { result.append(p) }
    return result
}

func emptySquaresAdjacentTo(location: Location, in pieces: [Piece]) -> [Piece] {
    return squaresAdjacentTo(location: location, in: pieces).filter { $0.type == .empty }
}

func piecesByDistance(from start: Piece, in pieces: [Piece], including: [Piece]? = nil) -> [Int : [Piece]] {
    var result = [Int : [Piece]]()
    for piece in pieces {
        if let including = including, !including.contains(piece) {
            continue
        }
        let distance = paths(from: start.location, to: piece.location, in: pieces)?.minDepth ?? Int.max
        result[distance, default: []].append(piece)
    }
    return result
}

func paths(from start: Location, to end: Location, in pieces: [Piece], excluding: [Location] = []) -> PathNode? {
    var toExclude = excluding
    toExclude.append(start)

    let result = PathNode(location: start)
    let numberOfMoves = start.numberOfMoves(to: end)
    if numberOfMoves == 0 { return result }
    let allAdjacent = emptySquaresAdjacentTo(location: start, in: pieces).map { $0.location }
    for adjacent in allAdjacent where !toExclude.contains(adjacent){
        if let paths = paths(from: adjacent, to: end, in: pieces, excluding: toExclude) {
            result.nextSteps.insert(paths)
        }
    }
    if result.nextSteps.count == 0 { return nil }
    return result
}

let rows = input.components(separatedBy: "\n")
let board = rows.map { Array($0) }

let maxX = rows[0].count - 1
let maxY = rows.count - 1

var pieces = [Piece]()
for y in 0...maxY {
    for x in 0...maxX {
        let location = Location(x: x, y: y)
        let character = board[y][x]
        pieces.append(Piece(character: character, location: location)!)
    }
}

func printBoard(_ theBoard: [Piece]) {
    for y in 0...maxY {
        var rowString = ""
        var piecesInRow = [Piece]()
        for x in 0...maxX {
            let location = Location(x: x, y: y)
            guard let piece = pieceAt(location, in: theBoard) else {
                rowString.append("x")
                continue
            }
            rowString.append(piece.type.rawValue)
            if piece.isPlayer {
                piecesInRow.append(piece)
            }
        }
        rowString += "   " + piecesInRow.map { "\(String($0.type.rawValue).uppercased())(\($0.hitPoints))" }.joined(separator: ", ")
        print(rowString)
    }
}

func move(piece: Piece, to location: Location, in pieces: [Piece]) {
    let oldLocation = piece.location
    if let spaceMovedTo = pieceAt(location, in: pieces) {
        spaceMovedTo.location = oldLocation
    }
    piece.location = location
}

func remove(piece: Piece, from pieces: inout [Piece]) {
    pieces.removeAll { $0 == piece }
    pieces.append(Piece(type: .empty, location: piece.location))
}

// Bool in result is false if no units were found and combat should stop
func playRound(inputPieces: [Piece]) -> ([Piece], Bool) {
    var newPieces = inputPieces
    var unitsToMove = piecesInReadingOrder(inputPieces.filter { $0.isPlayer })
    for piece in unitsToMove {
        switch piece.type {
        case .elf: fallthrough
        case .goblin:
            // Move
            var adjacentEnemies = squaresAdjacentTo(location: piece.location, in: newPieces).filter { $0.type == piece.type.enemyType }
            if adjacentEnemies.count == 0 {
                let allEnemies = newPieces.filter { $0.type == piece.type.enemyType }
                if allEnemies.count == 0 { return (newPieces, false) }
                var inRangeSquares = [Piece]()
                for enemy in allEnemies {
                    let adjacentSquares = emptySquaresAdjacentTo(location: enemy.location, in: newPieces)
                    inRangeSquares.append(contentsOf: adjacentSquares)
                }
                let piecesByDist = piecesByDistance(from: piece, in: pieces, including: inRangeSquares)
                guard let shortestGoalDistance = piecesByDist.keys.sorted().first(where: {
                    piecesByDist[$0]!.filter { inRangeSquares.contains($0) } != [piece]
                }) else { continue }
                let shortestGoals = piecesByDist[shortestGoalDistance]!.filter { inRangeSquares.contains($0) && $0 != piece }
                guard let firstGoal = piecesInReadingOrder(shortestGoals).first else { continue }

                if let pathTreeToGoal = paths(from: piece.location, to: firstGoal.location, in: newPieces, excluding: [piece.location]),
                    let firstStep = pathTreeToGoal.shortestNextSteps.map({ $0.location }).sorted(by: { $0.inReadingOrderIsBefore($1) }).first {

                    // Move to first step along path
                    move(piece: piece, to: firstStep, in: newPieces)
                }

                adjacentEnemies = squaresAdjacentTo(location: piece.location, in: newPieces).filter { $0.type == piece.type.enemyType }
            }

            // Attack
            if adjacentEnemies.count == 0 { continue }
            var enemiesByHitPoints: [Int : [Piece]] = adjacentEnemies.reduce([Int :[Piece]]()) {
                var scratch = $0
                scratch[$1.hitPoints, default:[]].append($1)
                return scratch
            }
            let weakest = enemiesByHitPoints[enemiesByHitPoints.keys.min()!]!
            let veryWeakest = piecesInReadingOrder(weakest)[0]
            veryWeakest.hitPoints -= piece.attackPower
            if veryWeakest.hitPoints <= 0 {
                // Dies
                unitsToMove.removeAll { $0 == veryWeakest }
                remove(piece: veryWeakest, from: &newPieces)
            }
        default:
            continue
        }
    }
    return (newPieces, true)
}

var numRounds = 0
var shouldStop = false
gameLoop: while (true) {
    print("\nAfter \(numRounds) rounds:")
    printBoard(pieces)

    (pieces, shouldStop) = playRound(inputPieces: pieces)
    if !shouldStop { break gameLoop }
    numRounds += 1
}

let remainingHitPoints = pieces.filter { $0.isPlayer }.map { $0.hitPoints }.reduce(0, +)
print("part 1: \(numRounds) * \(remainingHitPoints) = \(remainingHitPoints * numRounds)")
