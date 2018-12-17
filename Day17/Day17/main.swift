//
//  main.swift
//  Day16
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
x=495, y=2..7
y=7, x=495..501
x=501, y=3..7
x=498, y=2..4
x=506, y=1..2
x=498, y=10..13
x=504, y=10..13
y=13, x=498..504
"""

let input = (test ? testInputString : inputString).components(separatedBy: "\n")

struct Location: Hashable {

    static func locations(from string: String) -> [Location] {
        let comps = string.components(separatedBy: ", ")
        guard let yCoords = comps.filter({ $0.hasPrefix("y=") }).first?.dropFirst(2),
            let xCoords = comps.filter({ $0.hasPrefix("x=") }).first?.dropFirst(2) else {
                return []
        }

        let firstY = Int(yCoords.components(separatedBy: "..").first!)!
        let lastY = Int(yCoords.components(separatedBy: "..").last!)!

        let firstX = Int(xCoords.components(separatedBy: "..").first!)!
        let lastX = Int(xCoords.components(separatedBy: "..").last!)!

        var result = [Location]()
        for y in firstY...lastY {
            for x in firstX...lastX {
                result.append(Location(x: x, y: y))
            }
        }
        return result
    }

    func relativeLocation(_ position: Position) -> Location {
        var scratch = self
        switch position {
        case .above: scratch.y -= 1
        case .below: scratch.y += 1
        case .left: scratch.x -= 1
        case .right: scratch.x += 1
        case .belowLeft:
            scratch.x -= 1
            scratch.y += 1
        case .belowRight:
            scratch.x += 1
            scratch.y += 1
        }
        return scratch
    }

    var x, y: Int
}

enum FillType: Character {
    case sand = "."
    case water = "~"
    case wetSand = "|"
    case clay = "#"
    case spring = "+"

    var isWet: Bool {
        return self == .water || self == .wetSand || self == .spring
    }
}

class Square {

    init(fillType: FillType, location: Location) {
        self._fillType = fillType
        self.location = location
    }

    var _fillType: FillType
    var fillType: FillType {
        get { return _fillType }
        set {
            guard _fillType != .clay else {
                return
            }
            _fillType = newValue
        }
    }
    let location: Location
}

func printScan(_ grid: [[Square]]) {
    let rows = grid.map { row in
        String(row.map { $0.fillType.rawValue })
    }
    for row in rows {
        print(row)
    }
    print("\n")
}

enum Position {
    case above, below, left, right, belowLeft, belowRight
}

func squareAt(location: Location, in grid: [[Square]]) -> Square? {
    return grid.flatMap({ $0 }).first(where: { $0.location == location })
}

func squareRelative(to location: Location, position: Position, in grid: [[Square]]) -> Square {
    let newLocation = location.relativeLocation(position)
    return squareAt(location: newLocation, in: grid) ?? Square(fillType: .sand, location: newLocation)
}

let spring = Location(x: 500, y: 0)

func waterCanEscapeLeft(of location: Location, in grid: [[Square]]) -> Bool {
    guard let row = grid.filter({ $0.first(where: { $0.location == location }) != nil }).first else {
        return true
    }
    let allClay = row.filter { $0.fillType == .clay }
    let clayOnLeft = allClay.last(where: { $0.location.x < location.x })
    if (clayOnLeft == nil) { return true }

    return location.relativeLocation(.below).fillType != .water
}

func waterCanEscapeRight(of location: Location, in grid: [[Square]]) -> Bool {
    guard let row = grid.filter({ $0.first(where: { $0.location == location }) != nil }).first else {
        return true
    }
    let allClay = row.filter { $0.fillType == .clay }
    let clayOnRight = allClay.first(where: { $0.location.x > location.x })
    if (clayOnRight == nil) { return true }

    let squareBelow = location.relativeLocation(.below)
}

func waterCanEscapeFrom(_ location: Location, in grid: [[Square]]) -> Bool {
    guard let row = grid.filter({ $0.first(where: { $0.location == location }) != nil }).first else {
        return true
    }
    let allClay = row.filter { $0.fillType == .clay }
    let clayOnLeft = allClay.last(where: { $0.location.x < location.x })
    let clayOnRight = allClay.first(where: { $0.location.x > location.x })
    if clayOnLeft == nil || clayOnRight == nil { return true }

    var hasFloor = false
    let squareBelow = location.relativeLocation(.below)
    if let nextRow = grid.filter({ $0.first(where: { $0.location == squareBelow }) != nil }).first {
        let floor = nextRow.filter({ $0.location.x >= clayOnLeft!.location.x && $0.location.x <= clayOnRight!.location.x })
        hasFloor = floor.filter { $0.fillType == .clay || $0.fillType == .water }.count == floor.count
    }

    return !hasFloor
}

func waterTick(grid: [[Square]]) {
    let allSquares = grid.flatMap { $0 }
    for square in allSquares where square.fillType.isWet {
        let below = squareRelative(to: square.location, position: .below, in: grid)
        let left = squareRelative(to: square.location, position: .left, in: grid)
        let right = squareRelative(to: square.location, position: .right, in: grid)
        switch square.fillType {
        case .spring: fallthrough
        case .wetSand:
            if !below.fillType.isWet {
                below.fillType = .wetSand
            } else {
                if !waterCanEscapeFrom(square.location, in: grid) {
                    square.fillType = .water
                    left.fillType = .water
                    right.fillType = .water
                } else {
                    if !waterCanEscapeLeft(of: square.location, in: grid) {
                        left.fillType = .wetSand
                    }
                    if !waterCanEscapeRight(of: square.location, in: grid) {
                        right.fillType = .wetSand
                    }
                }
            }
        case .water:
            if below.fillType == .clay || below.fillType.isWet {
                if left.fillType != .clay {
                    left.fillType = .water
                }
                if right.fillType != .clay {
                    right.fillType = .water
                }
            }
        default: break
        }
    }
}

let clayLocations = input.flatMap { Location.locations(from: $0) }
let minX = clayLocations.map { $0.x }.min()!-1
let maxX = clayLocations.map { $0.x }.max()!+1
let minY = clayLocations.map { $0.y }.min()!
let maxY = clayLocations.map { $0.y }.max()!

var grid = [[Square]]()
for y in 0...maxY {
    var row = [Square]()
    for x in minX...maxX {
        let loc = Location(x: x, y: y)
        if clayLocations.first(where: { $0 == loc }) != nil {
            row.append(Square(fillType: .clay, location: loc))
        } else if loc == spring {
            row.append(Square(fillType: .spring, location: loc))
        } else {
            row.append(Square(fillType: .sand, location: loc))
        }
    }
    grid.append(row)
}
print("Initial:")
printScan(grid)

var amountOfWater = 0
var numTicks = 0
while true {
    waterTick(grid: grid)
    numTicks += 1
    print("After \(numTicks)")
    printScan(grid)

    let allWater = grid.flatMap { $0 }.filter {
        $0.location.x >= minX &&
            $0.location.y >= minY &&
            $0.location.x <= maxX &&
            $0.location.y <= maxY
        }.filter {
            $0.fillType.isWet
    }
    let newAmountOfWater = allWater.count
    if newAmountOfWater == amountOfWater {
        amountOfWater = newAmountOfWater
        break
    }
    amountOfWater = newAmountOfWater
}
print("Part 1: \(amountOfWater)")


