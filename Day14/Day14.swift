import Foundation

let input = 825401

var scoreboard = [3, 7]
var elf1 = 0
var elf2 = 1

func combineAndCreateNewRecipe1() {
    let sum = scoreboard[elf1] + scoreboard[elf2]
    let digits = Array(String(sum)).map { Int(String($0))! }
    scoreboard.append(digits[0])
}

func combineAndCreateNewRecipe2() {
    let sum = scoreboard[elf1] + scoreboard[elf2]
    let digits = Array(String(sum)).map { Int(String($0))! }
    if digits.count < 2 { return }
    scoreboard.append(digits[1])
}

let inputAsArray = Array(String(input).map { Int(String($0))! })
let inputLength = inputAsArray.count
func checkForPart2() -> Int? {
    guard scoreboard.count-inputLength >= 0 else { return nil }
    let lastDigits = scoreboard.suffix(inputLength)
    for (index, digit) in inputAsArray.enumerated() {
        if digit != lastDigits[lastDigits.index(lastDigits.startIndex, offsetBy: index)] { return nil }
    }
    return scoreboard.count - inputLength
}

func part1() -> String {
    while true {    
        combineAndCreateNewRecipe1()
        combineAndCreateNewRecipe2()

        elf1 = (elf1 + (scoreboard[elf1] + 1)) % scoreboard.count
        elf2 = (elf2 + (scoreboard[elf2] + 1)) % scoreboard.count
        
        if scoreboard.count >= input + 10 {
            return scoreboard[input..<input+10].map { String($0) }.joined()
        }
    }
}

func part2() -> Int {
    while true {
        combineAndCreateNewRecipe1()
        if let part2 = checkForPart2() { return part2 }
        combineAndCreateNewRecipe2()
        if let part2 = checkForPart2() { return part2 }

        elf1 = (elf1 + (scoreboard[elf1] + 1)) % scoreboard.count
        elf2 = (elf2 + (scoreboard[elf2] + 1)) % scoreboard.count
    }
}

print(part1())
print(part2())