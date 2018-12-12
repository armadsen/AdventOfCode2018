import Cocoa

let test = false

let initialString = try! String(contentsOfFile: "initial.txt")
let inputString = try! String(contentsOfFile: "input.txt")

let testInputString = """
...## => #
..#.. => #
.#... => #
.#.#. => #
.#.## => #
.##.. => #
.#### => #
#.#.# => #
#.### => #
##.#. => #
##.## => #
###.. => #
###.# => #
####. => #
"""

func desc(of pots: [Bool]) -> String {
    return pots.map { $0 ? "#" : "." }.joined()
}

let testInitialString = "#..#.#..##......###...###"

let initialInput = (test ? testInitialString : initialString)
let input = (test ? testInputString : inputString).components(separatedBy: "\n")

var pots = initialInput.map { $0 == "#" }
let padding = 5
pots.insert(contentsOf: Array<Bool>(repeating: false, count: padding), at: 0)
pots.append(contentsOf: Array<Bool>(repeating: false, count: padding))
var rules = [[Bool] : Bool]()
for line in input {
    let comps = line.components(separatedBy: " ")
    let rule = comps[0].map { $0 == "#" }
    let result = comps[2]
    rules[rule] = result == "#"
}
//print(rules.map { "\(desc(of: $0.0)) => \($0.1 ? "#" : ".")" }.joined(separator: "\n"))

//print("\(0):  \(desc(of: pots))")

func sum(of pots: [Bool]) -> Int {
    return pots.enumerated().reduce(0) {
        $0 + ($1.element ? $1.offset - padding : 0)
    }
}

var valAt1K = 0
for i in 1...2000 {
    var newPots = pots
    for index in 2..<pots.count {
        var pattern: [Bool]
        if index+2 >= pots.count {
            pattern = Array(pots[(index-2)..<pots.count])
            let padding = Array<Bool>(repeating: false, count: 5-pattern.count)
            pattern.append(contentsOf: padding)
            if !pattern.contains(true) { continue }
            newPots.append(contentsOf: padding)
        } else {
            pattern = Array(pots[(index-2)...(index+2)])
        }

        if let result = rules[pattern] {
            newPots[index] = result
        } else {
            newPots[index] = false
        }
    }
    //print("\(i):  \(desc(of: newPots))")

    if i == 20 {
        print("part 1: \(sum(of: newPots))")
    }

    if i == 1000 {
        valAt1K = sum(of: newPots)
    }

    if i == 2000 {
        let changePer1K = sum(of: newPots) - valAt1K
        let part2Result = sum(of: newPots) + ((50000000000 - 2000) / 1000) * changePer1K
        print("part 2: \(part2Result)")
    }

    pots = newPots
}