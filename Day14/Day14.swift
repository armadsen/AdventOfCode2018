import Foundation

let input = 825401

var scoreboard = [3, 7]
var (elf1, elf2) = (0, 1)

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

var gotPart1 = false
while true {
    let sum = scoreboard[elf1] + scoreboard[elf2]
    if sum >= 10 {
        scoreboard.append(sum/10)
        if let part2 = checkForPart2() { print("part 2: \(part2)"); break; }
    }
    scoreboard.append(sum%10)
    if let part2 = checkForPart2() { print("part 2: \(part2)"); break; }

    elf1 = (elf1 + (scoreboard[elf1] + 1)) % scoreboard.count
    elf2 = (elf2 + (scoreboard[elf2] + 1)) % scoreboard.count
    
    if !gotPart1 && scoreboard.count >= input + 10 {
        print("part 1: \(scoreboard[input..<input+10].map { String($0) }.joined())") 
        gotPart1 = true
    }
}
