import Cocoa

class Marble {

    init(index: Int) {
        self.index = index
    }

    func marble(atOffset offset: Int) -> Marble {
        var result = self
        for _ in 0..<offset.magnitude {
            result = offset > 0 ? result.nextMarble! : result.previousMarble!
        }
        return result
    }

    func insert(between left: Marble, and right: Marble) {
        left.nextMarble = self
        previousMarble = left
        right.previousMarble = self
        nextMarble = right
    }

    func remove() {
        previousMarble?.nextMarble = nextMarble
        nextMarble?.previousMarble = previousMarble
    }

    let index: Int

    var previousMarble: Marble?
    var nextMarble: Marble?
}

func highScoreInGameWith(numberOfPlayers: Int, lastMarble: Int) -> Int {
    var current = Marble(index: 0)
    current.insert(between: current, and: current)

    var scores = Array<Int>(repeating: 0, count: numberOfPlayers)

    var i = 0
    while true {
        for player in 0..<numberOfPlayers {
            i += 1
            let newMarble = Marble(index: i)
            if newMarble.index % 23 == 0 {
                scores[player] += newMarble.index
                let marbleToRemove = current.marble(atOffset: -7)
                current = marbleToRemove.nextMarble!
                marbleToRemove.remove()
                scores[player] += marbleToRemove.index
            } else {
                newMarble.insert(between: current.marble(atOffset: 1), and: current.marble(atOffset: 2))
                current = newMarble
            }
            
            if newMarble.index == lastMarble {
                return scores.max()!
            }
        }
    }

}

func part1() -> Int {
    return highScoreInGameWith(numberOfPlayers: 464, lastMarble: 71730)
}

func part2() -> Int {
    return highScoreInGameWith(numberOfPlayers: 464, lastMarble: 71730 * 100)
}

print("Part 1: \(part1())")
print("Part 2: \(part2())")