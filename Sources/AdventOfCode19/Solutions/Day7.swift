//
//  File.swift
//  
//
//  Created by Matthias Felix on 07.12.19.
//

import Foundation

final class Day7: Day {

    var input: [Int]

    init(input: String) {
        self.input = input.split(separator: ",").map({ Int($0)! })
    }

    var answerMetric: String { " = highest signal" }

    func solvePartOne() -> CustomStringConvertible {
        let phaseSettings = [0,1,2,3,4].permutations

        var maxSignal = 0

        phaseSettings.forEach { phaseSetting in
            let amp1 = Amplifier()
            let amp2 = Amplifier()
            let amp3 = Amplifier()
            let amp4 = Amplifier()
            let amp5 = Amplifier()

            let output1 = amp1.start(with: [phaseSetting[0], 0], intcode: self.input)
            let output2 = amp2.start(with: [phaseSetting[1], output1], intcode: self.input)
            let output3 = amp3.start(with: [phaseSetting[2], output2], intcode: self.input)
            let output4 = amp4.start(with: [phaseSetting[3], output3], intcode: self.input)
            let signal = amp5.start(with: [phaseSetting[4], output4], intcode: self.input)

            if signal > maxSignal {
                maxSignal = signal
            }
        }

        return maxSignal
    }

    func solvePartTwo() -> CustomStringConvertible {
        let phaseSettings = [5,6,7,8,9].permutations

        var maxSignal = 0

        phaseSettings.forEach { phaseSetting in
            let amp1 = Amplifier()
            let amp2 = Amplifier()
            let amp3 = Amplifier()
            let amp4 = Amplifier()
            let amp5 = Amplifier()

            var output1 = amp1.start(with: [phaseSetting[0], 0], intcode: self.input)
            var output2 = amp2.start(with: [phaseSetting[1], output1], intcode: self.input)
            var output3 = amp3.start(with: [phaseSetting[2], output2], intcode: self.input)
            var output4 = amp4.start(with: [phaseSetting[3], output3], intcode: self.input)
            var output5 = amp5.start(with: [phaseSetting[4], output4], intcode: self.input)

            while !amp5.halted {
                output1 = amp1.continueWith(input: output5)
                output2 = amp2.continueWith(input: output1)
                output3 = amp3.continueWith(input: output2)
                output4 = amp4.continueWith(input: output3)
                output5 = amp5.continueWith(input: output4)
            }

            print("signal for \(phaseSetting) = \(output5)")
            if output5 > maxSignal {
                maxSignal = output5
            }
        }

        return maxSignal
    }

}

extension Day7 {

    class Amplifier {

        var inputs: [Int] = []
        var intcode: [Int] = []

        var pointer = 0

        var output: Int?
        var lastOutput: Int?
        var halted = false

        func start(with inputs: [Int], intcode: [Int]) -> Int {
            self.inputs = inputs
            self.intcode = intcode

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
                let p1 = instruction.1[0] == .immediate ? intcode[pointer+1] : intcode[intcode[pointer+1]]
                let p2 = instruction.1[1] == .immediate ? intcode[pointer+2] : intcode[intcode[pointer+2]]
                intcode[intcode[pointer+3]] = p1 + p2
                pointer += 4
            case .two:
                let p1 = instruction.1[0] == .immediate ? intcode[pointer+1] : intcode[intcode[pointer+1]]
                let p2 = instruction.1[1] == .immediate ? intcode[pointer+2] : intcode[intcode[pointer+2]]
                intcode[intcode[pointer+3]] = p1 * p2
                pointer += 4
            case .three:
                intcode[intcode[pointer+1]] = self.inputs.remove(at: 0)
                pointer += 2
            case .four:
                let p1 = instruction.1[0] == .immediate ? intcode[pointer+1] : intcode[intcode[pointer+1]]
                self.output = p1
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
                self.halted = true
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

extension Array {
    func chopped() -> (Element, [Element])? {
        guard let x = self.first else { return nil }
        return (x, Array(self.suffix(from: 1)))
    }
}

extension Array {
    func interleaved(_ element: Element) -> [[Element]] {
        guard let (head, rest) = self.chopped() else { return [[element]] }
        return [[element] + self] + rest.interleaved(element).map { [head] + $0 }
    }
}

extension Array {
    var permutations: [[Element]] {
        guard let (head, rest) = self.chopped() else { return [[]] }
        return rest.permutations.flatMap { $0.interleaved(head) }
    }
}
