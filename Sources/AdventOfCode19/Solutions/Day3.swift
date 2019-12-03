//
//  Day3.swift
//  AdventOfCode
//
//  Created by Bradley Mackey on 02/12/2019.
//  Copyright © 2019 Bradley Mackey. All rights reserved.
//

/// --- Day 3: Crossed Wires ---
final class Day3: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    var answerMetric: String {
        "distance"
    }

    lazy var parts = input.split(separator: "\n").map { $0.split(separator: ",") }
    lazy var part1 = parts[0]
    lazy var part2 = parts[1]

    var current = (0, 0)

    var intersects = [(Int, Int)]()

    func solvePartOne() -> CustomStringConvertible {
        var hlines1 = [HLine]()
        var vlines1 = [VLine]()

        for point in part1 {
            let dir = String(point.first!)
            let length = Int(point.suffix(from: point.index(after: point.startIndex)))!

            switch dir {
            case "U":
                vlines1.append(VLine(x: current.0, y1: current.1, y2: current.1 + length))
                current = (current.0, current.1 + length)
            case "D":
                vlines1.append(VLine(x: current.0, y1: current.1 - length, y2: current.1))
                current = (current.0, current.1 - length)
            case "R":
                hlines1.append(HLine(x1: current.0, x2: current.0 + length, y: current.1))
                current = (current.0 + length, current.1)
            default: // "L"
                hlines1.append(HLine(x1: current.0 - length, x2: current.0, y: current.1))
                current = (current.0 - length, current.1)
            }
        }

        current = (0, 0)

        var hlines2 = [HLine]()
        var vlines2 = [VLine]()

        for point in part2 {
            let dir = String(point.first!)
            let length = Int(point.suffix(from: point.index(after: point.startIndex)))!

            switch dir {
            case "U":
                vlines2.append(VLine(x: current.0, y1: current.1, y2: current.1 + length))
                current = (current.0, current.1 + length)
            case "D":
                vlines2.append(VLine(x: current.0, y1: current.1 - length, y2: current.1))
                current = (current.0, current.1 - length)
            case "R":
                hlines2.append(HLine(x1: current.0, x2: current.0 + length, y: current.1))
                current = (current.0 + length, current.1)
            default: // "L"
                hlines2.append(HLine(x1: current.0 - length, x2: current.0, y: current.1))
                current = (current.0 - length, current.1)
            }
        }

        for l1 in hlines1 {
            for l2 in vlines2 {
                if let i = intersection(hline: l1, vline: l2) {
                    intersects.append(i)
                }
            }
        }

        for l1 in hlines2 {
            for l2 in vlines1 {
                if let i = intersection(hline: l1, vline: l2) {
                    intersects.append(i)
                }
            }
        }

        // Minimum distance
        return intersects.map({ abs($0.0) + abs($0.1) }).min()!
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        var combinedSteps = [Int]()

        intersects.forEach { (x, y) in
            current = (0, 0)
            var steps = 0

            var shouldBreak = false

            for point in part1 {
                let dir = String(point.first!)
                let length = Int(point.suffix(from: point.index(after: point.startIndex)))!

                for _ in 0..<length {
                    if current.0 == x && current.1 == y {
                        shouldBreak = true
                        break
                    } else {
                        switch dir {
                        case "U":
                            current = (current.0, current.1 + 1)
                        case "D":
                            current = (current.0, current.1 - 1)
                        case "R":
                            current = (current.0 + 1, current.1)
                        default: // "L"
                            current = (current.0 - 1, current.1)
                        }
                        steps += 1
                    }
                }

                if shouldBreak { break }
            }

            current = (0, 0)
            shouldBreak = false

            for point in part2 {
                let dir = String(point.first!)
                let length = Int(point.suffix(from: point.index(after: point.startIndex)))!

                for _ in 0..<length {
                    if current.0 == x && current.1 == y {
                        combinedSteps.append(steps)
                        shouldBreak = true
                        break
                    } else {
                        switch dir {
                        case "U":
                            current = (current.0, current.1 + 1)
                        case "D":
                            current = (current.0, current.1 - 1)
                        case "R":
                            current = (current.0 + 1, current.1)
                        default: // "L"
                            current = (current.0 - 1, current.1)
                        }
                        steps += 1
                    }
                }

                if shouldBreak { break }
            }
        }

        return combinedSteps.min()!
    }
    
}

extension Day3 {
    
    struct Point: Equatable {
        let x: Int
        let y: Int

        static func ==(_ lhs: Point, _ rhs: Point) -> Bool {
            lhs.x == rhs.x && lhs.y == rhs.y
        }

        var manhattanDistance: Int { abs(x) + abs(y) }
    }

    struct HLine {
        let x1, x2, y: Int
    }

    struct VLine {
        let x, y1, y2: Int
    }

    func intersection(hline: HLine, vline: VLine) -> (Int, Int)? {
        if vline.x > hline.x1 && vline.x < hline.x2 && hline.y > vline.y1 && hline.y < vline.y2 {
            return (vline.x, hline.y)
        } else {
            return nil
        }
    }
    
}
