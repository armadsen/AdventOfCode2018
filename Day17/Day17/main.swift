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
    case clay = "#"
    case sand = "."
    case wetSand = "|"
    case water = "~"
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
    print("\n\n")
    print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
    print("\n\n")
}

enum Position {
    case above, below, left, right, belowLeft, belowRight
}

func rowFor(y: Int, in grid: [[Square]]) -> [Square]? {
    let minY = grid[0][0].location.y
    let yi = y - minY
    guard 0 < yi && yi < grid.count else { return nil }
    return grid[yi]
}

func squareAt(location: Location, in grid: [[Square]]) -> Square? {
    guard let row = rowFor(y: location.y, in: grid) else { return nil }
    let minX = grid[0][0].location.x
    let x = location.x - minX
    guard 0 < x && x < row.count else { return nil }
    return row[x]
}

func squareRelative(to location: Location, position: Position, in grid: [[Square]]) -> Square {
    let newLocation = location.relativeLocation(position)
    return squareAt(location: newLocation, in: grid) ?? Square(fillType: .sand, location: newLocation)
}

func clayToLeft(of square: Square, in grid: [[Square]]) -> Square? {
    let sl = square.location
    let minX = grid[0][0].location.x
    for xo in 0..<(sl.x - minX) {
        let x = sl.x - xo
        if let square = squareAt(location: Location(x: x, y: sl.y), in: grid) {
            if square.fillType == .clay { return square }
        }
    }
    return nil
}

func clayToRight(of square: Square, in grid: [[Square]]) -> Square? {
    let sl = square.location
    let maxX = grid[0].last!.location.x
    for x in (sl.x+1)...maxX {
        if let square = squareAt(location: Location(x: x, y: sl.y), in: grid) {
            if square.fillType == .clay { return square }
        }
    }
    return nil
}

func waterTick(grid: [[Square]]) {
    let minX = grid[0][0].location.x
    let maxX = grid[0].last!.location.x
    let allSquares = grid.flatMap { $0 }.reversed()
    for row in grid.reversed() {
        for square in row.reversed() where square.fillType.isWet {
            let below = squareRelative(to: square.location, position: .below, in: grid)
            let left = squareRelative(to: square.location, position: .left, in: grid)
            let right = squareRelative(to: square.location, position: .right, in: grid)
            square.fillType = .wetSand
            var didMove = false

            func wet(square: Square) -> Bool {
                switch square.fillType {
                case .sand:
                    square.fillType = .wetSand
                    return true
                case .wetSand:
                    return true
                default: return false
                }
            }

            if below.fillType == .sand || below.fillType == .wetSand {
                below.fillType = .wetSand
                continue
            }

            // Hit either clay or a water surface, so fill left/right until we hit a drop.
            let leftBoundary = clayToLeft(of: square, in: grid)?.location.x ?? minX
            let rightBoundary = clayToRight(of: square, in: grid)?.location.x ?? maxX
            var squaresFilled = [Square]()
            var foundDrop = false
            for xo in 0..<(square.location.x - leftBoundary) {
                let x = square.location.x - xo
                guard let s = squareAt(location: Location(x: x, y: square.location.y), in: grid),
                    s.fillType != .clay else { continue }
                let sb = squareRelative(to: s.location, position: .below, in: grid)
                s.fillType = .water
                squaresFilled.append(s)
                if sb.fillType != .clay && sb.fillType != .water {
                    foundDrop = true
                    break
                }
            }

            for x in square.location.x+1...rightBoundary {
                guard let s = squareAt(location: Location(x: x, y: square.location.y), in: grid),
                    s.fillType != .clay else { continue }
                let sb = squareRelative(to: s.location, position: .below, in: grid)
                s.fillType = .water
                squaresFilled.append(s)
                if sb.fillType != .clay && sb.fillType != .water {
                    foundDrop = true
                    break
                }
            }

            if foundDrop {
                for s in squaresFilled {
                    s.fillType = .wetSand
                }
            }
        }
    }
}

let clayLocations = Set(input.flatMap { Location.locations(from: $0) })
let minX = clayLocations.map { $0.x }.min()!-1
let maxX = clayLocations.map { $0.x }.max()!+1
let minY = clayLocations.map { $0.y }.min()!
let maxY = clayLocations.map { $0.y }.max()!
let spring = Location(x: 500, y: 0)

var grid = [[Square]]()
for y in 0...maxY {
    var row = [Square]()
    for x in minX...maxX {
        let loc = Location(x: x, y: y)
        if clayLocations.contains(loc) {
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

func waterAmount(range: (xMin: Int, xMax: Int, yMin: Int, yMax: Int), in grid: [[Square]]) -> Int {
    let allWater = grid.flatMap { $0 }.filter {
        $0.location.x >= range.xMin &&
            $0.location.y >= range.yMin &&
            $0.location.x <= range.xMax &&
            $0.location.y <= range.yMax
        }.filter {
            $0.fillType.isWet
    }
    return allWater.count
}

var amountOfWater = 0
var numTicks = 0
while true {
    waterTick(grid: grid)
    numTicks += 1
    print("Tick \(numTicks) done")
    if numTicks % 1000 == 0 {
        print("After \(numTicks)")
        printScan(grid)
    }

    let newAmountOfWater = waterAmount(range: (minX, maxX, 0, maxY), in: grid)
    if newAmountOfWater == amountOfWater { break }
    amountOfWater = newAmountOfWater
}

print("After \(numTicks)")
printScan(grid)
print("Part 1: \(waterAmount(range: (minX, maxX, minY, maxY), in: grid))")


