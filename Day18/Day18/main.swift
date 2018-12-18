//
//  main.swift
//  Day16
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
.#.#...|#.
.....#|##|
.|..|...#.
..|#.....#
#.#|||#|#|
...#.||...
.|....|...
||...#|.#|
|.||||..|.
...#.|..|.
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

enum GroundType: Character, Hashable {
    case open = "."
    case trees = "|"
    case lumberyard = "#"

    var nextType: GroundType {
        switch self {
        case .open: return .trees
        case .trees: return .lumberyard
        case .lumberyard: return .open
        }
    }
}

struct Acre: Hashable {

    init(type: GroundType, location: Location) {
        self.type = type
        self.location = location
    }

    init?(character: Character, location: Location) {
        guard let type = GroundType(rawValue: character) else { return nil }
        self.init(type: type, location: location)
    }

    static func ==(lhs: Acre, rhs: Acre) -> Bool {
        if lhs.type != rhs.type { return false }
        if lhs.location != rhs.location { return false }
        return true
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(location)
    }

    var type: GroundType
    let location: Location
}

extension Collection {
    func get(_ index: Index) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}

func acreAt(_ location: Location, in field: [Acre]) -> Acre? {
    return field.first { $0.location == location }
}

extension Location {
    var adjacent:  [Location] {
        return [Location(x: x-1, y: y-1),
                Location(x: x, y: y-1),
                Location(x: x+1, y: y-1),
                Location(x: x-1, y: y),
                Location(x: x+1, y: y),
                Location(x: x-1, y: y+1),
                Location(x: x, y: y+1),
                Location(x: x+1, y: y+1),]
    }
}

let rows = input.components(separatedBy: "\n")
let board = rows.map { Array($0) }

let maxX = rows[0].count - 1
let maxY = rows.count - 1

var acres = [Acre]()
for y in 0...maxY {
    for x in 0...maxX {
        let location = Location(x: x, y: y)
        let character = board[y][x]
        acres.append(Acre(character: character, location: location)!)
    }
}

let originalAcres = acres

func printBoard(_ field: [Acre]) {
    for y in 0...maxY {
        var rowString = ""
        for x in 0...maxX {
            let location = Location(x: x, y: y)
            guard let acre = acreAt(location, in: field) else {
                rowString.append("x")
                continue
            }
            rowString.append(acre.type.rawValue)
        }
        print(rowString)
    }
}

func processOneMinute() {
    var scratch = [Acre]()
    for y in 0...maxY {
        for x in 0...maxX {
            let location = Location(x: x, y: y)
            let acre = acreAt(location, in: acres)!
            let adjAcres = location.adjacent.compactMap { acreAt($0, in: acres) }
            var transforms = false
            switch acre.type {
                case .open:
                    transforms = adjAcres.filter { $0.type == .trees }.count >= 3
                case .trees:
                    transforms = adjAcres.filter { $0.type == .lumberyard }.count >= 3
                case .lumberyard:
                    let numTrees = adjAcres.filter { $0.type == .trees }.count
                    let numLYs = adjAcres.filter { $0.type == .lumberyard }.count
                    transforms = !(numTrees >= 1 && numLYs >= 1)
            }
            let newAcre: Acre
            if transforms {
                newAcre = Acre(type: acre.type.nextType, location: location)
            } else {
                newAcre = acre
            }
            scratch.append(newAcre)
        }
    }
    acres = scratch
}

for i in 0..<10 {
    processOneMinute()
    print("\nAfter \(i+1) rounds:")
    printBoard(acres)
}

let wooded = acres.filter { $0.type == .trees }.count
let lumberyards = acres.filter( { $0.type == .lumberyard }).count
print("Part 1: \(wooded * lumberyards)")
