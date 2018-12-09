import Cocoa

class Marble {

    init(index: Int) {
        self.index = index
    }

    func marble(offset: Int) -> Marble {
        var result = self
        if offset == 0 { return result }
        for _ in 0..<offset.magnitude {
            if offset > 0 {
                result = result.nextMarble!
            } else {
                result = result.previousMarble!
            }
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
        let left = previousMarble
        let right = nextMarble
        left?.nextMarble = right
        right?.previousMarble = left
        self.nextMarble = nil
        self.previousMarble = nil
    }

    let index: Int

    var previousMarble: Marble?
    var nextMarble: Marble?
}

class Player {

    init(index: Int) {
        self.index = index
    }

    let index: Int

    var marbles = [Marble]()

    var score: Int {
        return marbles.reduce(0) {
            $0 + $1.index
        }
    }
}

func highScoreInGameWith(numberOfPlayers: Int, lastMarble: Int) -> Int {
    var currentMarble = Marble(index: 0)
    currentMarble.insert(between: currentMarble, and: currentMarble)

    let players = Array(0..<numberOfPlayers).map { Player(index: $0) }

    var i = 0
    while true {
        for player in players {
            i += 1
            let newMarble = Marble(index: i)
            if newMarble.index % 23 == 0 && newMarble.index > 0 {
                player.marbles.append(newMarble)
                let marbleToKeep = currentMarble.marble(offset: -7)
                currentMarble = marbleToKeep.nextMarble!
                marbleToKeep.remove()
                player.marbles.append(marbleToKeep)
            } else {
                let mar1 = currentMarble.marble(offset: 1)
                let mar2 = currentMarble.marble(offset: 2)
                newMarble.insert(between: mar1, and: mar2)
                currentMarble = newMarble
            }
            if newMarble.index == lastMarble {
                return players.map { $0.score }.max()!
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