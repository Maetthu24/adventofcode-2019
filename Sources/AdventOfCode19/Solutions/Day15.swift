//
//  File.swift
//  
//
//  Created by Matthias Felix on 15.12.19.
//

import Foundation

final class Day15: Day {

    let intcode: [Int]

    init(input: String) {
        self.intcode = input.split(separator: ",").map({ Int($0)! })
    }

    var answerMetric: String { "movement commands" }

    let droid = Amplifier()
    let start = Position(x: 0, y: 0)

    var queue = [Position]()
    var visited: [Position] = []

    var solution = 0

    func printMaze() {
        let minX = visited.map({ $0.x }).min()!
        let maxX = visited.map({ $0.x }).max()!
        let xRange = abs(maxX - minX)
        let xOffset = abs(minX)

        let minY = visited.map({ $0.y }).min()!
        let maxY = visited.map({ $0.y }).max()!
        let yRange = abs(maxY - minY)
        let yOffset = abs(minY)

        var grid = [[Character]]()
        for _ in minY...maxY {
            var line = [Character]()
            for _ in minX...maxX { line.append(" ") }
            grid.append(line)
        }

        for p in visited {
            grid[p.y + yOffset][p.x + xOffset] = p.character
        }

        print("")
        grid.forEach { print(String($0)) }
        print("")
    }

    func solvePartOne() -> CustomStringConvertible {
        droid.prepare(intcode: self.intcode)

        queue = [start]

        start.moves = 0
        start.droid = droid

        while !queue.isEmpty {
            let current = queue.remove(at: 0)
            if !visited.contains(current) {
                visited.append(current)
                let program = current.droid!
                let moves = current.moves + 1

                for dir in Direction.allCases {
                    let newPos = current.newPosition(dir: dir)
                    newPos.moves = moves
                    newPos.droid = program.copy()
                    let result = StatusCode(rawValue: newPos.droid!.run(with: [dir.rawValue]))!
                    print("Exploring \(newPos): \(result)")
                    printMaze()
                    newPos.status = result
                    switch result {
                    case .wall:
                        visited.append(newPos)
                        newPos.droid = nil
                    case .oxygen:
                        queue.append(newPos)
                        oxygenStart = newPos
                        solution = moves
                    case .moved:
                        queue.append(newPos)
                    }
                }
            }
        }

        return solution
    }

    var oxygenStart: Position?

    func solvePartTwo() -> CustomStringConvertible {
        var minutes = 0

        var oxygenPositions = [Position]()
        oxygenStart!.filled = true
        oxygenPositions.append(oxygenStart!)

        var toFill: [Position] = visited.filter({ $0.status != nil && $0.status! == .moved })

        while !toFill.isEmpty {
            var newOxygenPositions = [Position]()
            for pos in oxygenPositions {
                let neighbours = toFill.filter({ $0.isNeighbour(pos) })
                neighbours.forEach({
                    $0.filled = true
                    let idx = toFill.firstIndex(of: $0)!
                    toFill.remove(at: idx)
                })
                newOxygenPositions.append(contentsOf: neighbours)
            }
            oxygenPositions = newOxygenPositions
            minutes += 1
        }

        return minutes
    }

}

extension Day15 {

    class Position: Equatable, CustomStringConvertible {
        let x, y: Int
        var moves = 0
        var droid: Amplifier?
        var status: StatusCode?
        var filled = false

        var character: Character {
            if filled {
                return "O"
            }

            if let s = self.status {
                switch s {
                case .wall: return "#"
                case .moved: return "."
                case .oxygen: return "X"
                }

            } else {
                return " "
            }
        }

        init(x: Int, y: Int) {
            self.x = x
            self.y = y
        }

        func newPosition(dir: Direction) -> Position {
            switch dir {
            case .north:
                return Position(x: self.x, y: self.y - 1)
            case .south:
                return Position(x: self.x, y: self.y + 1)
            case .west:
                return Position(x: self.x - 1, y: self.y)
            case .east:
                return Position(x: self.x + 1, y: self.y)
            }
        }

        func isNeighbour(_ other: Position) -> Bool {
            other == newPosition(dir: .north) ||
                other == newPosition(dir: .south) ||
                other == newPosition(dir: .east) ||
                other == newPosition(dir: .west)
        }

        static func ==(_ lhs: Position, _ rhs: Position) -> Bool {
            lhs.x == rhs.x && lhs.y == rhs.y
        }

        var description: String { "\(x)/\(y)" }
    }

    struct Point {
        let position: Position

        func newPosition(dir: Direction) -> Position {
            switch dir {
            case .north:
                return Position(x: self.position.x, y: self.position.y - 1)
            case .south:
                return Position(x: self.position.x, y: self.position.y + 1)
            case .west:
                return Position(x: self.position.x - 1, y: self.position.y)
            case .east:
                return Position(x: self.position.x + 1, y: self.position.y)
            }
        }
    }

    enum Direction: Int, CaseIterable {
        case north = 1
        case south = 2
        case west = 3
        case east = 4

        var opposite: Direction {
            switch self {
            case .north:
                return .south
            case .south:
                return .north
            case .west:
                return .east
            case .east:
                return .west
            }
        }
    }

    enum StatusCode: Int {
        case wall = 0
        case moved = 1
        case oxygen = 2
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

            for _ in 0...1000 {
                self.intcode.append(0)
            }
        }

        func copy() -> Amplifier {
            let copy = Amplifier()
            copy.prepare(intcode: self.intcode)
            copy.inputs = self.inputs
            copy.pointer = self.pointer
            copy.relativeBase = self.relativeBase
            copy.output = self.output
            copy.lastOutput = self.lastOutput
            copy.halted = self.halted
            return copy
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
