//
//  main.swift
//  Day15
//
//  Created by Andrew R Madsen on 12/14/18.
//  Copyright © 2018 Open Reel Software. All rights reserved.
//

import Foundation

let test = false

let args = ProcessInfo.processInfo.arguments
let inputPath = (args[1] as NSString).expandingTildeInPath as String

let inputString = try! String(contentsOfFile: inputPath)
let testInputString = """
#######
#E..EG#
#.#G.E#
#E.##E#
#G..#.#
#..E#.#
#######
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

class Piece: Hashable {
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

    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(location)
        hasher.combine(hitPoints)
    }

    let type: PieceType
    var location: Location
    let attackPower = 3
    var hitPoints = 200

    var isPlayer: Bool {
        return [.elf, .goblin].contains(type)
    }
}

extension Collection {
    func get(_ index: Index) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}

func pieceAt(_ location: Location, in pieces: [Piece]) -> Piece? {
    return pieces.first { $0.location == location }
}

extension Location {
    var adjacent:  [Location] {
        return [Location(x: x-1, y: y),
                Location(x: x+1, y: y),
                Location(x: x, y: y-1),
                Location(x: x, y: y+1)]
    }

    func distances(in pieces: [Piece]) -> [Location : Int] {
        var queue = adjacent.map { ($0, 1) } // Space, distance
        var result = [self : 0]
        while let (next, distance) = queue.first {
            queue.remove(at: 0)
            guard let nextPiece = pieceAt(next, in: pieces),
                nextPiece.type == .empty,
                result[next] == nil else { continue }
            result[next] = distance
            queue.append(contentsOf: next.adjacent.lazy.map({ ($0, distance + 1) }))
        }
        return result
    }
}

func locationsInReadingOrder(_ locations: [Location]) -> [Location] {
    return locations.sorted { $0.inReadingOrderIsBefore($1) }
}

func piecesInReadingOrder(_ pieces: [Piece]) -> [Piece] {
    return pieces.sorted { $0.location.inReadingOrderIsBefore($1.location) }
}

func squaresAdjacentTo(location: Location, in pieces: [Piece]) -> [Piece] {
    return location.adjacent.compactMap { pieceAt($0, in: pieces) }
}

func emptySquaresAdjacentTo(location: Location, in pieces: [Piece]) -> [Piece] {
    return squaresAdjacentTo(location: location, in: pieces).filter { $0.type == .empty }
}

//func pathsForPieces(from start: Piece, in pieces: [Piece], including: [Piece]? = nil) -> [Piece : PathNode] {
//    var result = [Piece : PathNode]()
//    for piece in pieces {
//        if let including = including, !including.contains(piece) { continue }
//        if let paths = paths(from: start.location, to: piece.location, in: pieces, excluding: []) {
//            result[piece] = paths
//        }
//    }
//    return result
//}

//func piecesByDistance(from start: Piece, in pieces: [Piece], including: [Piece]? = nil) -> [Int : [Piece]] {
//    var result = [Int : [Piece]]()
//    for piece in pieces {
//        if let including = including, !including.contains(piece) {
//            continue
//        }
//        let distance = paths(from: start.location, to: piece.location, in: pieces, excluding: [])?.minDepth ?? Int.max
//        result[distance, default: []].append(piece)
//    }
//    return result
//}

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
    for piece in unitsToMove where piece.hitPoints > 0 {
        let allEnemies = newPieces.filter { $0.type == piece.type.enemyType }
        if allEnemies.isEmpty { return (newPieces, false) }

        let inRangeSquares = allEnemies.flatMap { $0.location.adjacent } // Not just empty squares
        if !inRangeSquares.contains(piece.location) { // Move closer to an enemy

            let distances = piece.location.distances(in: newPieces) // Only open squares
            var squaresByDistance = [Int: [Location]]()
            for square in inRangeSquares {
                if let distance = distances[square] {
                    squaresByDistance[distance, default:[]].append(square)
                }
            }
            if let shortestGoalDistance = squaresByDistance.keys.min(),
                let candidateSpaces = squaresByDistance[shortestGoalDistance],
                let firstGoal = locationsInReadingOrder(candidateSpaces).first {

                let targets = firstGoal.distances(in: newPieces)
                // Calculate best next step by finding the square adjacent to the current position that has the
                // shortest distance to firstGoal
                let candidateSteps = piece.location.adjacent.filter { pieceAt($0, in: newPieces)?.type == .empty }
                var candidateStepsByDistance = [Int : [Location]]()
                for step in candidateSteps {
                    guard let distance = targets[step] else { continue }
                    candidateStepsByDistance[distance, default: []].append(step)
                }
                if let bestStepDistance = candidateStepsByDistance.keys.min(),
                    let bestSteps = candidateStepsByDistance[bestStepDistance],
                    let firstStep = locationsInReadingOrder(bestSteps).first {
                    move(piece: piece, to: firstStep, in: newPieces)
                }
            }
        }

        let adjacentEnemies = squaresAdjacentTo(location: piece.location, in: newPieces).filter { $0.type == piece.type.enemyType }
        if adjacentEnemies.count > 0 { // Attack
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
                print("\(veryWeakest.type) died")
            }
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

print("\nAfter \(numRounds) rounds:")
printBoard(pieces)
let remainingHitPoints = pieces.filter { $0.isPlayer }.map { $0.hitPoints }.reduce(0, +)
print("part 1: \(numRounds) * \(remainingHitPoints) = \(remainingHitPoints * numRounds)")
