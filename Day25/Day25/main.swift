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
1,-1,-1,-2
-2,-2,0,1
0,2,1,3
-2,3,-2,1
0,2,3,-2
-1,-1,1,-2
0,-2,-1,0
-2,2,3,-1
1,2,2,0
-1,-2,0,-2
"""

let input = (test ? testInputString : inputString)

struct Point: Hashable {
    var x, y, z, t: Int
}

extension Point {
    init(line: String) {
        let comps = line.components(separatedBy: ",").map { Int($0)! }
        self.init(x: comps[0], y: comps[1], z: comps[2], t: comps[3])
    }

    func distance(to point: Point) -> Int {
        return Int((point.x - x).magnitude + (point.y - y).magnitude + (point.z - z).magnitude + (point.t - t).magnitude)
    }
}

class Constellation: Hashable {

    init(points: [Point]) {
        self.points = Set(points)
    }

    func canAdd(point: Point) -> Bool {
        if points.contains(point) { return false }
        if points.isEmpty { return true }
        for p in points {
            if p.distance(to: point) <= 3 { return true }
        }
        return false
    }

    func add(point: Point) -> Bool {
        guard canAdd(point: point) else { return false }
        points.insert(point)
        return true
    }

    func adding(point: Point) -> Constellation? {
        guard canAdd(point: point) else { return nil }
        let scratch = self
        scratch.points.insert(point)
        return scratch
    }

    static func ==(lhs: Constellation, rhs: Constellation) -> Bool {
        return lhs.points == rhs.points
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(points)
    }

    private(set) var points = Set<Point>()
}

let lines = input.components(separatedBy: "\n")
var points = lines.map { Point(line: $0) }

var constellations = [Constellation]()

while true {
    guard !points.isEmpty else { break }
    constellations.append(Constellation(points: [points.removeFirst()]))

    let pointScratch = points
    for c in constellations {
        var addedAPoint = false
        repeat {
            addedAPoint = false
            for point in pointScratch {
                if c.add(point: point) {
                    addedAPoint = true
                    points.removeAll { $0 == point }
                }
            }
        } while addedAPoint
    }
}
print(constellations.count)

