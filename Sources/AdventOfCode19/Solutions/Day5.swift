//
//  File.swift
//  
//
//  Created by Matthias Felix on 05.12.19.
//

import Foundation

/// --- Day 5: Sunny with a Chance of Asteroids ---
final class Day5: Day {

    let input: String
    var intcode: [Int]

    init(input: String) {
        self.input = input
        self.intcode = input.split(separator: ",").map({ Int($0)! })
    }

    var answerMetric: String {
        "diagnostic code"
    }

    func solvePartOne() -> CustomStringConvertible {
        var pointer = 0

        while true {
            let instruction = getOpcodeAndParameterModes(instruction: intcode[pointer])
            carryOutInstruction(intcode: &self.intcode, pointer: &pointer, instruction: instruction)
        }

    }

    func carryOutInstruction(intcode: inout [Int], pointer: inout Int, instruction: Instruction) {

        print("Pointer = \(pointer)")
        print("Intcode = \(intcode)")

        switch instruction.0 {
        case .one:
            let p1 = instruction.1[0] == .immediate ? intcode[pointer+1] : intcode[intcode[pointer+1]]
            let p2 = instruction.1[1] == .immediate ? intcode[pointer+2] : intcode[intcode[pointer+2]]
            intcode[intcode[pointer+3]] = p1 + p2
            print("Adding parameters")
            pointer += 4
        case .two:
            let p1 = instruction.1[0] == .immediate ? intcode[pointer+1] : intcode[intcode[pointer+1]]
            let p2 = instruction.1[1] == .immediate ? intcode[pointer+2] : intcode[intcode[pointer+2]]
            intcode[intcode[pointer+3]] = p1 * p2
            print("Multiplying parameters")
            pointer += 4
        case .three:
            intcode[intcode[pointer+1]] = 5
            print("Writing Input 5")
            pointer += 2
        case .four:
            let p1 = instruction.1[0] == .immediate ? intcode[pointer+1] : intcode[intcode[pointer+1]]
            print("Outputting \(p1)")
            pointer += 2
        case .five:
            let p1 = instruction.1[0] == .immediate ? intcode[pointer+1] : intcode[intcode[pointer+1]]
            if p1 == 0 {
                pointer += 3
                break
            }
            pointer = instruction.1[1] == .immediate ? intcode[pointer+2] : intcode[intcode[pointer+2]]
        case .six:
            let p1 = instruction.1[0] == .immediate ? intcode[pointer+1] : intcode[intcode[pointer+1]]
            if p1 != 0 {
                pointer += 3
                break
            }
            pointer = instruction.1[1] == .immediate ? intcode[pointer+2] : intcode[intcode[pointer+2]]
        case .seven:
            let p1 = instruction.1[0] == .immediate ? intcode[pointer+1] : intcode[intcode[pointer+1]]
            let p2 = instruction.1[1] == .immediate ? intcode[pointer+2] : intcode[intcode[pointer+2]]
            let toStore = p1 < p2 ? 1 : 0
            intcode[intcode[pointer+3]] = toStore
            pointer += 4
        case .eight:
            let p1 = instruction.1[0] == .immediate ? intcode[pointer+1] : intcode[intcode[pointer+1]]
            let p2 = instruction.1[1] == .immediate ? intcode[pointer+2] : intcode[intcode[pointer+2]]
            let toStore = p1 == p2 ? 1 : 0
            intcode[intcode[pointer+3]] = toStore
            pointer += 4
        case .ninetynine:
            print("Halting program")
            exit(0)
        }

        print("Setting pointer to \(pointer)")
    }

    func getOpcodeAndParameterModes(instruction: Int) -> Instruction {
        guard let opcode = Opcode(rawValue: instruction % 100) else {
            print("Invalid opcode: \(instruction % 100)")
            exit(0)
        }

        let paddedInstruction = "00000\(instruction)".dropLast(2)
        var params = [ParameterMode]()
        for i in 0..<opcode.parameters {
            let index = paddedInstruction.index(paddedInstruction.endIndex, offsetBy: -(i+1))
            let modeChar = paddedInstruction[index]
            params.append(ParameterMode(rawValue: Int("\(modeChar)")!)!)
        }

        return (opcode, params)
    }

    func solvePartTwo() -> CustomStringConvertible {
        ""
    }

}

extension Day5 {

    typealias Instruction = (Opcode, [ParameterMode])

    enum Opcode: Int {
        case one = 1
        case two = 2
        case three = 3
        case four = 4
        case five = 5
        case six = 6
        case seven = 7
        case eight = 8
        case ninetynine = 99

        var parameters: Int {
            switch self {
            case .one, .two:
                return 3
            case .three, .four:
                return 1
            case .five, .six:
                return 2
            case .seven, .eight:
                return 3
            case .ninetynine:
                return 0
            }
        }
    }

    enum ParameterMode: Int {
        case position = 0
        case immediate = 1
    }

}
