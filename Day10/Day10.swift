import Cocoa

struct Coordinate: Hashable {
    var x: Int
    var y: Int
}

class Point {
    init(x: Int, y: Int, xV: Int, yV: Int) {
        self.coordinate = Coordinate(x: x, y: y)
        self.xV = xV
        self.yV = yV
    }
    
    var coordinate: Coordinate
    var x: Int { return coordinate.x }
    var y: Int { return coordinate.y }

    var xV: Int
    var yV: Int
    
    func move() {
        coordinate = Coordinate(x: x + xV, y: y + yV)
    }
}

var points: [Point] = [
Point(x: 9, y: 1, xV: 0, yV: 2),
Point(x: 7, y: 0, xV: -1, yV: 0),
Point(x: 3, y: -2, xV: -1, yV: 1),
Point(x: 6, y: 10, xV: -2, yV: -1),
Point(x: 2, y: -4, xV: 2, yV: 2),
Point(x: -6, y: 10, xV: 2, yV: -2),
Point(x: 1, y: 8, xV: 1, yV: -1),
Point(x: 1, y: 7, xV: 1, yV: 0),
Point(x: -3, y: 11, xV: 1, yV: -2),
Point(x: 7, y: 6, xV: -1, yV: -1),
Point(x: -2, y: 3, xV: 1, yV: 0),
Point(x: -4, y: 3, xV: 2, yV: 0),
Point(x: 10, y: -3, xV: -1, yV: 1),
Point(x: 5, y: 11, xV: 1, yV: -2),
Point(x: 4, y: 7, xV: 0, yV: -1),
Point(x: 8, y: -2, xV: 0, yV: 1),
Point(x: 15, y: 0, xV: -2, yV: 0),
Point(x: 1, y: 6, xV: 1, yV: 0),
Point(x: 8, y: 9, xV: 0, yV: -1),
Point(x: 3, y: 3, xV: -1, yV: 1),
Point(x: 0, y: 5, xV: 0, yV: -1),
Point(x: -2, y: 2, xV: 2, yV: 0),
Point(x: 5, y: -2, xV: 1, yV: 2),
Point(x: 1, y: 4, xV: 2, yV: 1),
Point(x: -2, y: 7, xV: 2, yV: -2),
Point(x: 3, y: 6, xV: -1, yV: -1),
Point(x: 5, y: 0, xV: 1, yV: 0),
Point(x: -6, y: 0, xV: 2, yV: 0),
Point(x: 5, y: 9, xV: 1, yV: -2),
Point(x: 14, y: 7, xV: -2, yV: 0),
Point(x: -3, y: 6, xV: 2, yV: -1),
]

func ranges() -> (minX: Int, maxX: Int, minY: Int, maxY: Int) {
    let maxX = points.map({ $0.x }).max()!
    let minX = points.map({ $0.x }).min()!
    let maxY = points.map({ $0.y }).max()!
    let minY = points.map({ $0.y }).min()!
    return (minX, maxX, minY, maxY)
}

func printPoints() {
    let (minX, maxX, minY, maxY) = ranges()
    let coordinates = Set(points.map { $0.coordinate })
    for y in minY...maxY {
        let line = String((minX...maxX).map({coordinates.contains(Coordinate(x: $0, y: y)) ? "#" : "."}))
        print(line)
    }
}

var t = 1
var lastWidth = Int.max
while true {
    defer { t += 1 }
    points.forEach { $0.move() }
    let (minX, maxX, _, _) = ranges()
    if maxX - minX > lastWidth { break }
    lastWidth = maxX - minX
    if maxX - minX < 70 {
        print("\n\n")
        print("t = \(t) seconds")
        printPoints()
        print("\n\n")        
    } 
}