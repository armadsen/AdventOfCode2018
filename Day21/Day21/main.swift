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

"""

let input = String((test ? testInputString : inputString))

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
}

func instrString(_ line: [String]) -> String {
    return String(describing: line)
}

struct Statement {

    init(line: String) {
        let comps = line.components(separatedBy: " ")
        self.instruction = instructionNamed(comps[0])
        let operands = comps.dropFirst().map { Int($0)! }
        self.opA = operands[0]
        self.opB = operands[1]
        self.opC = operands[2]
    }

    func run(registers: inout [Int]) {
        instruction(opA, opB, opC, &registers)
    }
    private let instruction: Instruction
    let opA: Int
    let opB: Int
    let opC: Int
}

let program = input.components(separatedBy: "\n").map { Statement(line: $0) }

let ipr = 5

func part1() {
    var registers = [0, 0, 0, 0, 0, 0]
    var ip = 0

    var possible = Set<Int>()

    var lastValid = 0
    while ip < program.count {
        registers[ipr] = ip
        program[ip].run(registers: &registers)
        if ip == 28 {
            if possible.count == 0 { print("Part 1: \(registers[4])") }
            if possible.contains(registers[4]) {
                print("Part 2: \(lastValid)")
                break
            }
            possible.insert(registers[4])
            lastValid = registers[4]
        }
        ip = registers[ipr] + 1
    }
}

part1()
