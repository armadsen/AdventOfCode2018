//
//  main.swift
//  Day22
//
//  Created by Andrew R Madsen on 12/21/18.
//  Copyright © 2018 Open Reel Software. All rights reserved.
//

import Foundation

func erosionLevelOf(geologicIndex: Int) -> Int {
    return ((geologicIndex + depth) % 20183)
}

struct Location: Hashable {

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    init() {
        self.init(x: 0, y: 0)
    }

    init(_ l: (Int, Int)) {
        self.init(x: l.0, y: l.1)
    }

    var x, y: Int
}

enum SquareType: Character, Hashable, CaseIterable {
    case rocky = "."
    case wet = "="
    case narrow = "|"
    case target = "T"
    case unknown = "?"

    init(geologicIndex: Int) {
        switch erosionLevelOf(geologicIndex: geologicIndex) % 3 {
        case 0: self = .rocky
        case 1: self = .wet
        case 2: self = .narrow
        default: fatalError()
        }
    }

    var risk: Int {
        switch self {
        case .target: return 0
        case .rocky: return 0
        case .wet: return 1
        case .narrow: return 2
        case .unknown: fatalError()
        }
    }
}

class Square {

    init(location: Location, type: SquareType) {
        self.location = location
        self.type = type
    }

    let location: Location
    var type: SquareType
    var erosionLevel: Int? = nil
}

let depth = 11739
let target = Location((11, 718))
//let depth = 510
//let target = Location((10, 10))

func geologicIndexOf(_ location: Location, in cave: [[Square]]) -> Int {
    if location == Location((0, 0)) || location == target {
        return 0
    } else if location.y == 0 {
        return location.x * 16807
    } else if location.x == 0 {
        return location.y * 48271
    } else {
        let s1l = Location(x: location.x-1, y: location.y)
        let s2l = Location(x: location.x, y: location.y-1)
        let s1 = cave[s1l.y][s1l.x]
        let s2 = cave[s2l.y][s2l.x]
        let e1 = s1.erosionLevel ?? erosionLevelOf(geologicIndex: geologicIndexOf(s1l, in: cave))
        let e2 = s2.erosionLevel ?? erosionLevelOf(geologicIndex: geologicIndexOf(s2l, in: cave))
        return e1*e2
    }
}

let overshoot = 20

var cave = [[Square]]()
for y in 0...target.y+overshoot {
    var row = [Square]()
    for x in 0...target.x+overshoot {
        row.append(Square(location: Location(x: x, y: y), type: .unknown))
    }
    cave.append(row)
}

for y in 0...target.y+overshoot {
    for x in 0...target.x+overshoot {
        let square = cave[y][x]
        let geoIndex = geologicIndexOf(square.location, in: cave)
        let erosionLevel = erosionLevelOf(geologicIndex: geoIndex)
        square.erosionLevel = erosionLevel
        square.type = SquareType(geologicIndex: geoIndex)
    }
}
cave[target.y][target.x].type = .target

var part1 = 0
for y in 0...target.y {
    for x in 0...target.x {
        part1 += cave[y][x].type.risk
    }
}
print("Part 1: \(part1)")

enum Gear {
    case climbing
    case torch
    case neither
}

extension SquareType {
    var validGear: Set<Gear> {
        switch self {
        case .target: return [.torch]
        case .rocky: return [.climbing, .torch]
        case .wet: return [.climbing, .neither]
        case .narrow: return [.torch, .neither]
        case .unknown: fatalError()
        }
    }
}

extension Location {
    func adjacent(in cave: [[Square]]) -> [Location] {
        let maxX = cave[0].count-1
        let maxY = cave.count-1
        var result = [Location]()
        if x > 0 { result.append(Location(x: x-1, y: y)) }
        if y > 0 { result.append(Location(x: x, y: y-1)) }
        if x < maxX { result.append(Location(x: x+1, y: y)) }
        if y < maxY { result.append(Location(x: x, y: y+1)) }
        return result
    }

    func distance(to: Location) -> Int {
        return Int((x - to.x).magnitude + (y - to.y).magnitude)
    }
}

struct LocGearPair: Hashable {
    let location: Location
    let gear: Gear
}

func timeToMove(from pair1: LocGearPair, to pair2: LocGearPair) -> Int? {
    let type1 = cave[pair1.location.y][pair1.location.x].type
    guard type1.validGear.contains(pair2.gear) else { return nil } // Can't switch
    return (pair1.gear == pair2.gear ? 1 : 8)
}

var unvisited = Set(cave.flatMap({ $0 }).flatMap { s in
    s.type.validGear.map { LocGearPair(location: s.location, gear: $0) }
})

let targetPair = LocGearPair(location: target, gear: .torch)
var currentPair: LocGearPair!
var distances = [LocGearPair(location: Location(), gear: .torch) : 0]

repeat {
    currentPair = unvisited.min(by: { distances[$0, default: .max] < distances[$1, default: .max] })!
    let currDist = distances[currentPair, default: .max]
    let adjacent = currentPair.location.adjacent(in: cave)
    let adjacentPairs = adjacent.flatMap { l in
        cave[l.y][l.x].type.validGear.map { LocGearPair(location: l, gear: $0) }
    }
    for p in adjacentPairs {
        if let dist = timeToMove(from: currentPair, to: p),
            dist+currDist < distances[p, default: .max] {
            distances[p] = dist + currDist
        }
    }
    unvisited.remove(currentPair)
} while unvisited.contains(targetPair)
print("part 2: \(distances[targetPair]!)")
