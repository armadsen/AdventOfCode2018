import Cocoa

let test = false

let inputString = try! String(contentsOfFile: "input.txt")
let testInputString = """
/>-<\\  
|   |  
| /<+-\\
| | | v
\\>+</ |
  |   ^
  \\<->/
"""
let input = (test ? testInputString : inputString)

enum Direction {
    case up, down, left, right
    
    var turningLeft: Direction {
        return [.up : .left, .left : .down, .down : .right, .right : .up][self]!
    }
    
    var turningRight: Direction {
        return [.up : .right, .right : .down, .down : .left, .left : .up][self]!
    }
}

struct Location: Hashable {
    var x, y: Int
}

let grid = input.components(separatedBy: "\n").map { Array($0) }
let maxX = grid[0].count - 1
let maxY = grid.count - 1

func trackPiece(forCartPiece piece: Character) -> Character? {
    return [">" : "-", "<" : "-", "^" : "|", "v" : "|"][piece]
}

class Cart {
    
    init?(char: Character, location: Location) {
        let chars: [Character: Direction] = ["^" : .up, "v" : .down, "<" : .left, ">" : .right]
        guard let direction = chars[char] else { return nil }
        self.direction = direction
        self.location = location
    }
    
    private var intersectionCount = 0
    func tick() {
        move()
        turnIfNeeded()
    }
    
    func turnIfNeeded() {
        let currTrackPiece = trackPiece(forCartPiece: grid[location.y][location.x]) ?? grid[location.y][location.x]        
        
        switch currTrackPiece {
            case "+":
                switch intersectionCount % 3 {
                    case 0: direction = direction.turningLeft
                    case 1: break //direction = direction
                    case 2: direction = direction.turningRight
                    default: fatalError()
                }
                intersectionCount += 1
            case "\\":
                switch direction {
                    case .up: direction = direction.turningLeft
                    case .down: direction = direction.turningLeft
                    case .left: direction = direction.turningRight
                    case .right: direction = direction.turningRight
                }
            case "/":
                switch direction {
                    case .up: direction = direction.turningRight
                    case .down: direction = direction.turningRight
                    case .left: direction = direction.turningLeft
                    case .right: direction = direction.turningLeft
                }
            default: break // Don't need to turn
        }
    }
    
    func move() {
        switch direction {
            case .up: location.y -= 1
            case .down: location.y += 1
            case .left: location.x -= 1
            case .right: location.x += 1
        }
    }
    
    var direction: Direction
    var location: Location
    
    var icon: Character {
        return [.up : "^", .down : "v", .left : "<", .right: ">"][direction]!
    }
}

class Track: CustomStringConvertible {
    init(input: String) {
        self.grid = input.components(separatedBy: "\n").map { Array($0) }
        
        carts = [Cart]()
        for y in 0...maxY {
            for x in 0...maxX {
                if let cart = Cart(char: grid[y][x], location: Location(x: x, y: y)) {
                    carts.append(cart)
                }
            }
        }
    }
    
    func tick() {
        for cart in cartsInOrder {
            cart.tick()
            if let crash = locationOfCrash {
                print("Crash at \(crash.x), \(crash.y)")
                while (removeCartAt(crash)) { }
            }
        }
    }
    
    let grid: [[Character]]
    var maxX: Int { return grid[0].count - 1 }
    var maxY: Int { return grid.count - 1 }
    
    var carts: [Cart]
    var cartsInOrder: [Cart] {
        return carts.sorted { $0.location.y == $1.location.y ? $0.location.x < $1.location.x : $0.location.y < $1.location.y }
    }
    
    var locationOfCrash: Location? {
        let sortedCarts = cartsInOrder
        var lastLocation = sortedCarts[0].location
        for cart in sortedCarts.dropFirst() {
            if cart.location == lastLocation {
                return cart.location
            }
            lastLocation = cart.location
        }
        return nil
    }
    
    func removeCartAt(_ location: Location) -> Bool {
        var indexToRemove: Int?
        for (idx, cart) in carts.enumerated() {
            if cart.location == location {
                indexToRemove = idx
                break
            }
        }
        if let i = indexToRemove {
            carts.remove(at: i)
            return true
        }
        return false
    }
    
    var description: String {
        var rows = [String]()
        let xLabels = (0...maxX).map { String($0 % 10) }.joined()
        rows.append("   " + xLabels)
        for y in 0...maxY {
            var rowString = "\(y % 10): "
            for x in 0...maxX {
                let location = Location(x: x, y: y)
                let piece = trackPiece(forCartPiece: grid[y][x]) ?? grid[y][x]
                if let cart = carts.first(where: { $0.location == location }) {
                    rowString.append(cart.icon)
                } else {
                    rowString.append(piece)
                }
            }
            rows.append(rowString)
        }
        return rows.joined(separator: "\n")
    }
}

let track = Track(input: input)

while track.carts.count > 1 {
    track.tick()
    //print(track)
}

print("Last cart at: \(track.carts[0].location.x),\(track.carts[0].location.y)")
