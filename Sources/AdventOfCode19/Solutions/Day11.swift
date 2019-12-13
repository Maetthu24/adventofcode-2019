//
//  File.swift
//  
//
//  Created by Matthias Felix on 11.12.19.
//

import Foundation

final class Day11: Day {

    var intcode: [Int]

    init(input: String) {
        self.intcode = input.split(separator: ",").map({ Int($0)! })
    }

    var answerMetric: String { "panels" }

    func solvePartOne() -> CustomStringConvertible {
//        var paintedPanels = [Panel]()
//
//        var currentPanel = Panel(x: 0, y: 0)
//        var direction: Direction = .up
//
//        let robot = Amplifier()
//        robot.prepare(intcode: self.intcode)
//
//        while !robot.halted {
//            let paint = robot.run(with: [currentPanel.paintedWhite ? 1 : 0])
//            if robot.halted { break }
//            let turn = robot.run(with: [])
//            print("Output: Paint \(paint) / Turn \(turn)")
//
//            currentPanel.paintedWhite = paint == 1
//            paintedPanels.filter({ $0 == currentPanel }).forEach({ $0.paintedWhite = paint == 1 })
//            if !paintedPanels.contains(where: { $0 == currentPanel }) {
//                paintedPanels.append(currentPanel)
//            }
//            print("Painting \(currentPanel): \(currentPanel.paintedWhite ? "white" : "black")")
//            print("number of visited panels: \(paintedPanels.count)")
//
//            direction = direction.next(input: turn)
//            currentPanel = direction.nextPanel(current: currentPanel)
//
//            if let alreadyVisited = paintedPanels.filter({ $0.x == currentPanel.x && $0.y == currentPanel.y }).first {
//                currentPanel.paintedWhite = alreadyVisited.paintedWhite
//            }
//
//            print("Turning \(direction), moving to \(currentPanel)")
//        }
//
//        return paintedPanels.count
        0
    }

    func solvePartTwo() -> CustomStringConvertible {
        var paintedPanels = [Panel]()

        var currentPanel = Panel(x: 0, y: 0)
        currentPanel.paintedWhite = true
        var direction: Direction = .up

        let robot = Amplifier()
        robot.prepare(intcode: self.intcode)

        while !robot.halted {
            let paint = robot.run(with: [currentPanel.paintedWhite ? 1 : 0])
            if robot.halted { break }
            let turn = robot.run(with: [])
            print("Output: Paint \(paint) / Turn \(turn)")

            currentPanel.paintedWhite = paint == 1
            paintedPanels.filter({ $0 == currentPanel }).forEach({ $0.paintedWhite = paint == 1 })
            if !paintedPanels.contains(where: { $0 == currentPanel }) {
                paintedPanels.append(currentPanel)
            }
            print("Painting \(currentPanel): \(currentPanel.paintedWhite ? "white" : "black")")
            print("number of visited panels: \(paintedPanels.count)")

            direction = direction.next(input: turn)
            currentPanel = direction.nextPanel(current: currentPanel)

            if let alreadyVisited = paintedPanels.filter({ $0.x == currentPanel.x && $0.y == currentPanel.y }).first {
                currentPanel.paintedWhite = alreadyVisited.paintedWhite
            }

            print("Turning \(direction), moving to \(currentPanel)")
        }

        let minX = paintedPanels.map({ $0.x }).min()!
        let minY = paintedPanels.map({ $0.y }).min()!

        paintedPanels.forEach { p in
            p.x += abs(minX)
            p.y += abs(minY)
        }

        let maxX = paintedPanels.map({ $0.x }).max()!
        let maxY = paintedPanels.map({ $0.y }).max()!

        var lines = [[Character]]()
        for i in 0...maxX {
            var s = [Character]()
            for j in 0...maxY {
                s.append(".")
            }
            lines.append(s)
        }

        paintedPanels.forEach { panel in
            if panel.paintedWhite {
                lines[panel.x][panel.y] = "#"
            }
        }

        lines.forEach({ print($0) })

        return paintedPanels.count
    }

}

extension Day11 {

    enum Direction {
        case up, left, down, right

        func next(input: Int) -> Direction {
            switch (self, input) {
            case (.up, let i):
                return i == 0 ? .left : .right
            case (.left, let i):
            return i == 0 ? .down : .up
            case (.down, let i):
                return i == 0 ? .right : .left
            case (.right, let i):
                return i == 0 ? .up : .down
            }
        }

        func nextPanel(current: Panel) -> Panel {
            switch self {
            case .up:
                return Panel(x: current.x, y: current.y + 1)
            case .right:
                return Panel(x: current.x + 1, y: current.y)
            case .down:
                return Panel(x: current.x, y: current.y - 1)
            case .left:
                return Panel(x: current.x - 1, y: current.y)
            }
        }
    }

    class Panel: Equatable, CustomStringConvertible {
        var x, y: Int
        var paintedWhite: Bool = false

        init(x: Int, y: Int) {
            self.x = x
            self.y = y
        }

        static func ==(_ lhs: Panel, _ rhs: Panel) -> Bool {
            lhs.x == rhs.x && lhs.y == rhs.y
        }

        var description: String { "\(x)/\(y)" }
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
