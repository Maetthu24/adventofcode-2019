//
//  File.swift
//  
//
//  Created by Matthias Felix on 13.12.19.
//

import Foundation

final class Day13: Day {

    let intcode: [Int]

    init(input: String) {
        self.intcode = input.split(separator: ",").map({ Int($0)! })
    }

    var answerMetric: String { "block tiles" }

    func solvePartOne() -> CustomStringConvertible {
//        let game = Amplifier()
//        game.prepare(intcode: self.intcode)
//
//        var blockCount = 0
//        var counter = 1
//
//        while !game.halted {
//            let output = game.run(with: [])
//            if output == 2 && counter % 3 == 0 { blockCount += 1 }
//            counter += 1
//        }
//
//        return blockCount
        0
    }

    func solvePartTwo() -> CustomStringConvertible {
        let game = Amplifier()
        game.prepare(intcode: self.intcode)

        var tiles = [(x: Int, y: Int, tile: Tile)]()

        var ball = (x: 0, y: 0)
        var paddle = (x: 0, y: 0)

        while !game.halted {
            let joystick: Joystick
            print("Ball position: \(ball.x)/\(ball.y)")
            print("Paddle position: \(paddle.x)/\(paddle.y)")
            if ball.x < paddle.x {
                joystick = .left
            } else if ball.x > paddle.x {
                joystick = .right
            } else {
                joystick = .neutral
            }

            let x = game.run(with: [joystick.rawValue])
            if game.halted { break }
            let y = game.run(with: [])
            if game.halted { break }
            let tileId = game.run(with: [])

            if x == -1 && y == 0 {
                print("NEW SCORE = \(tileId)")
                let maxX = tiles.map({$0.x}).max()!
                let maxY = tiles.map({$0.y}).max()!

                var lines = [[Character]]()
                for _ in 0...maxY {
                    var s = [Character]()
                    for _ in 0...maxX {
                        s.append(".")
                    }
                    lines.append(s)
                }

                for tile in tiles {
                    lines[tile.y][tile.x] = tile.tile.repr
                }

                let strings = lines.map { array -> String in
                    array.reduce("") { (res, c) -> String in
                        return "\(res)\(c)"
                    }
                }

                strings.forEach({print($0)})

//                tiles = []
            } else {
                let tile = Tile(rawValue: tileId)!
                if tile == .ball {
                    ball = (x, y)
                } else if tile == .paddle {
                    paddle = (x, y)
                }
                tiles.append((x, y, tile))
            }
        }

        return 0
    }

    
}


extension Day13 {

    enum Tile: Int {
        case empty = 0
        case wall = 1
        case block = 2
        case paddle = 3
        case ball = 4

        var repr: Character {
            switch self {
            case .empty:
                return " "
            case .wall:
                return "W"
            case .block:
                return "B"
            case .paddle:
                return "_"
            case .ball:
                return "o"
            }
        }
    }

    enum Joystick: Int {
        case neutral = 0
        case left = -1
        case right = 1
    }

    class Amplifier {

        var inputs: [Int] = []
        var intcode: [Int] = []

        var pointer = 0
        var relativeBase = 0

        var output: Int?
        var lastOutput: Int?
        var halted = false

        func prepare(intcode: [Int]) {
            self.intcode = intcode

            for _ in 0...10000000 {
                self.intcode.append(0)
            }
        }

        func run(with inputs: [Int]) -> Int {
            lastOutput = output
            output = nil
            self.inputs = inputs

            while output == nil && !self.halted {
                let instruction = getOpcodeAndParameterModes(instruction: self.intcode[self.pointer])
                carryOutInstruction(intcode: &self.intcode, pointer: &self.pointer, instruction: instruction)
            }

            return self.halted ? (output != nil ? output! : lastOutput!) : output!
        }

        private func carryOutInstruction(intcode: inout [Int], pointer: inout Int, instruction: Instruction) {

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
                let input = self.inputs.remove(at: 0)
                print("Taking input \(input)")
                saveValue(intcode: &intcode, pointer: pointer + 1, value: input, mode: instruction.1[0])
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

        private func getValue(intcode: [Int], pointer: Int, mode: ParameterMode) -> Int {
            switch mode {
            case .immediate:
                return intcode[pointer]
            case .position:
                return intcode[intcode[pointer]]
            case .relative:
                return intcode[intcode[pointer] + relativeBase]
            }
        }

        private func saveValue(intcode: inout [Int], pointer: Int, value: Int, mode: ParameterMode) {
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

        private func getOpcodeAndParameterModes(instruction: Int) -> Instruction {
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
