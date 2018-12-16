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
let input2Path = (args[2] as NSString).expandingTildeInPath as String

let inputString = try! String(contentsOfFile: inputPath)
let testInputString = """
Before: [3, 2, 1, 1]
9 2 1 2
After:  [3, 2, 2, 1]
"""

let input = (test ? testInputString : inputString)
let input2 = try! String(contentsOfFile: input2Path)

func addr(a: Int, b: Int, c: Int, registers regs: inout [Int]) {
    regs[c] = regs[a] + regs[b]
}

func addi(a: Int, b: Int, c: Int, registers regs: inout [Int]) {
    regs[c] = regs[a] + b
}

func mulr(a: Int, b: Int, c: Int, registers regs: inout [Int]) {
    regs[c] = regs[a] * regs[b]
}

func muli(a: Int, b: Int, c: Int, registers regs: inout [Int]) {
    regs[c] = regs[a] * b
}

func banr(a: Int, b: Int, c: Int, registers regs: inout [Int]) {
    regs[c] = regs[a] & regs[b]
}

func bani(a: Int, b: Int, c: Int, registers regs: inout [Int]) {
    regs[c] = regs[a] & b
}

func borr(a: Int, b: Int, c: Int, registers regs: inout [Int]) {
    regs[c] = regs[a] | regs[b]
}

func bori(a: Int, b: Int, c: Int, registers regs: inout [Int]) {
    regs[c] = regs[a] | b
}

func setr(a: Int, b: Int, c: Int, registers regs: inout [Int]) {
    regs[c] = regs[a]
}

func seti(a: Int, b: Int, c: Int, registers regs: inout [Int]) {
    regs[c] = a
}

func gtir(a: Int, b: Int, c: Int, registers regs: inout [Int]) {
    regs[c] = a > regs[b] ? 1 : 0
}

func gtri(a: Int, b: Int, c: Int, registers regs: inout [Int]) {
    regs[c] = regs[a] > b ? 1 : 0
}

func gtrr(a: Int, b: Int, c: Int, registers regs: inout [Int]) {
    regs[c] = regs[a] > regs[b] ? 1 : 0
}

func eqir(a: Int, b: Int, c: Int, registers regs: inout [Int]) {
    regs[c] = a == regs[b] ? 1 : 0
}

func eqri(a: Int, b: Int, c: Int, registers regs: inout [Int]) {
    regs[c] = regs[a] == b ? 1 : 0
}

func eqrr(a: Int, b: Int, c: Int, registers regs: inout [Int]) {
    regs[c] = regs[a] == regs[b] ? 1 : 0
}

let instructions: [(Int, Int, Int, inout [Int]) -> Void] = [addr, addi, mulr, muli, banr, bani, borr, bori, setr, seti, gtir, gtri, gtrr, eqir, eqri, eqrr]

struct TestCase {
    init(string: String) {
        let comps = string.components(separatedBy: "\n")
        let beforeArray = comps[0].components(separatedBy: ": [")[1]
        let beforeRegs = beforeArray.dropLast().components(separatedBy: ", ").map { Int($0)! }
        let instruction = comps[1].components(separatedBy: " ").map { Int($0)! }
        let afterArray = comps[2].components(separatedBy: ":  [")[1]
        print(afterArray)
        let afterRegs = afterArray.dropLast().components(separatedBy: ", ").map { Int($0)! }

        self.instruction = instruction
        self.beforeRegisters = beforeRegs
        self.afterRegisters = afterRegs
    }

    var instruction: Array<Int>
    var beforeRegisters: Array<Int>
    var afterRegisters: Array<Int>
}

func opcode(_ opcode: (Int, Int, Int, inout [Int]) -> Void, behavesLike testCase: TestCase) -> Bool {
    var startingRegs = testCase.beforeRegisters
    let a = testCase.instruction[1]
    let b = testCase.instruction[2]
    let c = testCase.instruction[3]
    let endingRegs = testCase.afterRegisters

    opcode(a, b, c, &startingRegs)
    return startingRegs == endingRegs
}

let testCasesStrings = input.components(separatedBy: "\n\n")
let testCases = testCasesStrings.map { TestCase(string: $0) }

var numLikeAtLeastThree = 0
for test in testCases {
    var numLike = 0
    for instruction in instructions {
        if opcode(instruction, behavesLike: test) {
            numLike += 1
        }
    }
    if numLike >= 3 {
        numLikeAtLeastThree += 1
    }
}
print("Part 1: \(numLikeAtLeastThree)")

var possibleInstructionIndexesByOpcodeNumber = [Int : Set<Int>]()
for i in 0..<16 {
    possibleInstructionIndexesByOpcodeNumber[i] = Set(0..<16)
}

for test in testCases {
    let opcodeNumber = test.instruction[0]
    for (index, instruction) in instructions.enumerated() {
        if !opcode(instruction, behavesLike: test) {
            possibleInstructionIndexesByOpcodeNumber[opcodeNumber]!.remove(index)
        }
    }
}

func hasStrictOneToOneMapping(_ dict: [Int : Set<Int>]) -> Bool {
    for (_, value) in dict {
        if value.count != 1 { return false }
    }
    return true
}

func onlyOneToOneMappings(from dict: [Int : Set<Int>]) -> [Int : Int] {
    var result = [Int : Int]()
    for (key, value) in dict {
        if value.count != 1 { continue }
        result[key] = value.first!
    }
    return result
}

while !hasStrictOneToOneMapping(possibleInstructionIndexesByOpcodeNumber) {
    let oneToOnes = onlyOneToOneMappings(from: possibleInstructionIndexesByOpcodeNumber)
    let allResovlvedInstrs = Set(oneToOnes.values)
    for (key, _) in possibleInstructionIndexesByOpcodeNumber {
        if oneToOnes[key] != nil { continue }
        possibleInstructionIndexesByOpcodeNumber[key]!.subtract(allResovlvedInstrs)
    }
}

print(possibleInstructionIndexesByOpcodeNumber)

let instructionByOpcodeNumber = onlyOneToOneMappings(from: possibleInstructionIndexesByOpcodeNumber)

func instructionFor(opcode: Int) -> ((Int, Int, Int, inout [Int]) -> Void) {
    return instructions[instructionByOpcodeNumber[opcode]!]
}

let program = input2.components(separatedBy: "\n").map { line in
    line.components(separatedBy: " ").map { Int($0)! }
}

var regs = [0, 0, 0, 0]
for line in program {
    let instruction = instructionFor(opcode: line[0])
    instruction(line[1], line[2], line[3], &regs)
}

print("Part 2: \(regs[0])")
