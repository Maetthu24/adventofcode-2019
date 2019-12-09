//
//  File.swift
//  
//
//  Created by Matthias Felix on 09.12.19.
//

import Foundation

final class Day9: Day {

    var input: [Int]

    init(input: String) {
        self.input = input.split(separator: ",").map({ Int($0)! })
    }

    var answerMetric: String { "BOOST Keycode" }

    func solvePartOne() -> CustomStringConvertible {
        let amplifier = Amplifier()

        var output = amplifier.start(with: [1], intcode: self.input)
        print(output)
        while !amplifier.halted {
            output = amplifier.continueWith(input: output)
            print(output)
        }

        return output
    }

    func solvePartTwo() -> CustomStringConvertible {
        let amplifier = Amplifier()

        var output = amplifier.start(with: [2], intcode: self.input)
        print(output)
        while !amplifier.halted {
            output = amplifier.continueWith(input: output)
            print(output)
        }

        return output
    }

}

extension Day9 {

    class Amplifier {

        var inputs: [Int] = []
        var intcode: [Int] = []

        var pointer = 0
        var relativeBase = 0

        var output: Int?
        var lastOutput: Int?
        var halted = false

        func start(with inputs: [Int], intcode: [Int]) -> Int {
            self.inputs = inputs
            self.intcode = intcode

            for _ in 0...10000000 {
                self.intcode.append(0)
            }

            while output == nil {
                let instruction = getOpcodeAndParameterModes(instruction: self.intcode[self.pointer])
                carryOutInstruction(intcode: &self.intcode, pointer: &self.pointer, instruction: instruction)
            }

            return output!
        }

        func continueWith(input: Int) -> Int {
            lastOutput = output
            output = nil
            self.inputs = [input]

            while output == nil && !self.halted {
                let instruction = getOpcodeAndParameterModes(instruction: self.intcode[self.pointer])
                carryOutInstruction(intcode: &self.intcode, pointer: &self.pointer, instruction: instruction)
            }

            return self.halted ? lastOutput! : output!
        }

        func carryOutInstruction(intcode: inout [Int], pointer: inout Int, instruction: Instruction) {

            switch instruction.0 {
            case .one:
                let p1 = getValue(intcode: intcode, pointer: pointer + 1, mode: instruction.1[0])
                let p2 = getValue(intcode: intcode, pointer: pointer + 2, mode: instruction.1[1])

                saveValue(intcode: &intcode, pointer: pointer + 3, value: p1 + p2, mode: instruction.1[2])

                pointer += 4
            case .two:
                let p1 = getValue(intcode: intcode, pointer: pointer + 1, mode: instruction.1[0])
                let p2 = getValue(intcode: intcode, pointer: pointer + 2, mode: instruction.1[1])

                saveValue(intcode: &intcode, pointer: pointer + 3, value: p1 * p2, mode: instruction.1[2])
                pointer += 4
            case .three:
                saveValue(intcode: &intcode, pointer: pointer + 1, value: self.inputs.remove(at: 0), mode: instruction.1[0])
                pointer += 2
            case .four:
                let p1 = getValue(intcode: intcode, pointer: pointer + 1, mode: instruction.1[0])
                self.output = p1
                pointer += 2
            case .five:
                let p1 = getValue(intcode: intcode, pointer: pointer + 1, mode: instruction.1[0])
                if p1 == 0 {
                    pointer += 3
                    break
                }
                pointer = getValue(intcode: intcode, pointer: pointer + 2, mode: instruction.1[1])
            case .six:
                let p1 = getValue(intcode: intcode, pointer: pointer + 1, mode: instruction.1[0])
                if p1 != 0 {
                    pointer += 3
                    break
                }
                pointer = getValue(intcode: intcode, pointer: pointer + 2, mode: instruction.1[1])
            case .seven:
                let p1 = getValue(intcode: intcode, pointer: pointer + 1, mode: instruction.1[0])
                let p2 = getValue(intcode: intcode, pointer: pointer + 2, mode: instruction.1[1])

                let toStore = p1 < p2 ? 1 : 0

                saveValue(intcode: &intcode, pointer: pointer + 3, value: toStore, mode: instruction.1[2])
                pointer += 4
            case .eight:
                let p1 = getValue(intcode: intcode, pointer: pointer + 1, mode: instruction.1[0])
                let p2 = getValue(intcode: intcode, pointer: pointer + 2, mode: instruction.1[1])

                let toStore = p1 == p2 ? 1 : 0

                saveValue(intcode: &intcode, pointer: pointer + 3, value: toStore, mode: instruction.1[2])
                pointer += 4
            case .nine:
                let p1 = getValue(intcode: intcode, pointer: pointer + 1, mode: instruction.1[0])
                relativeBase += p1
                pointer += 2
            case .ninetynine:
                print("Halting program")
                self.halted = true
            }
        }

        func getValue(intcode: [Int], pointer: Int, mode: ParameterMode) -> Int {
            switch mode {
            case .immediate:
                return intcode[pointer]
            case .position:
                return intcode[intcode[pointer]]
            case .relative:
                return intcode[intcode[pointer] + relativeBase]
            }
        }

        func saveValue(intcode: inout [Int], pointer: Int, value: Int, mode: ParameterMode) {
            switch mode {
            case .immediate:
                print("Should not happen!")
                abort()
            case .position:
                intcode[intcode[pointer]] = value
            case .relative:
                intcode[intcode[pointer] + relativeBase] = value
            }
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

    }

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
        case nine = 9
        case ninetynine = 99

        var parameters: Int {
            switch self {
            case .one, .two:
                return 3
            case .three, .four, .nine:
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
        case relative = 2
    }

}
