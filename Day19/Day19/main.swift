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
seti 5 0 1
seti 6 0 2
addi 0 1 0
addr 1 2 3
setr 1 0 0
seti 8 0 4
seti 9 0 5
"""

let input = (test ? testInputString : inputString)

typealias Instruction = (Int, Int, Int, inout [Int]) -> Void

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

func instructionNamed(_ name: String) -> Instruction {
    let instrs: [String : Instruction] = [
        "addr" : addr,
        "addi" : addi,
        "mulr" : mulr,
        "muli" : muli,
        "banr" : banr,
        "bani" : bani,
        "borr" : borr,
        "bori" : bori,
        "setr" : setr,
        "seti" : seti,
        "gtir" : gtir,
        "gtri" : gtri,
        "gtrr" : gtrr,
        "eqir" : eqir,
        "eqri" : eqri,
        "eqrr" : eqrr,
        ]
    return instrs[name]!
}

func regString(_ regs: [Int]) -> String {
    return String(describing: regs)
//    return "[\(regs.map({ String($0) }).joined(separator: ", "))]"
}

func instrString(_ line: [String]) -> String {
    return String(describing: line)
//    return line.joined(separator: " ")
}

let program = input.components(separatedBy: "\n").map { line in
    line.components(separatedBy: " ")
}

let ipr = test ? 0 : 5

func part1() {
    var registers = [0, 0, 0, 0, 0, 0]
    var ip = 0

    while ip < program.count {
        let line = program[ip]
        let operands = line.dropFirst().map { Int($0)! }
        registers[ipr] = ip
        instructionNamed(line[0])(operands[0], operands[1], operands[2], &registers)
        ip = registers[ipr] + 1
    }

    print("Part 1: \(registers[0])")
}

part1()

// Disassembly for my input, where r[0] = 1 at launch, reduces down to this:
var result = 0
for r3 in 1...10551410 {
    for r2 in 1...10551410 {
        if r3 * r2 == 10551410 {
            result += r3
        }
    }
}

/* It's calculating the sum of all the factors of 10551410, which are:
 1, 2, 5, 10, 1055141, 2110282, 5275705, and 10551410
 So the sum is 18992556
 */

