//
//  File.swift
//  
//
//  Created by Matthias Felix on 16.12.19.
//

import Foundation

final class Day16: Day {

    var input: [Int]

    var basePattern = [0, 1, 0, -1]

    init(input: String) {
        self.input = input.map({ Int(String($0))! })
    }

    var answerMetric: String { "" }

    func solvePartOne() -> CustomStringConvertible {

        var step = 0

        func calculateOutput(pattern: [Int]) -> Int {
            var sum = 0

            for (idx, value) in input.enumerated() {
//                print("Adding \(value)*\(pattern[(idx+1) % pattern.count])")
                sum += value * pattern[(idx+1) % pattern.count]
            }

//            print("New digit: \(abs(sum % 10))")

            return abs(sum % 10)
        }

        var solution = ""

//        while step < 100 {
//            var newInput = [Int]()
//
//            for idx in 0..<input.count {
//                var pattern = [Int]()
//                pattern.append(contentsOf: Array(repeating: basePattern[0], count: idx + 1))
//                pattern.append(contentsOf: Array(repeating: basePattern[1], count: idx + 1))
//                pattern.append(contentsOf: Array(repeating: basePattern[2], count: idx + 1))
//                pattern.append(contentsOf: Array(repeating: basePattern[3], count: idx + 1))
//
//                newInput.append(calculateOutput(pattern: pattern))
//            }
//
//            input = newInput
//
//            solution = ""
//            for i in 0..<8 {
//                solution.append(contentsOf: "\(input[i])")
//            }
//
//            step += 1
//            print("After \(step) steps: \(solution)")
//        }

        return solution
    }

    func solvePartTwo() -> CustomStringConvertible {
        var step = 0

        func calculateOutput(pattern: [Int]) -> Int {
            var sum = 0

            for (idx, value) in input.enumerated() {
//                print("Adding \(value)*\(pattern[(idx+1) % pattern.count])")
                sum += value * pattern[(idx+1) % pattern.count]
            }

//            print("New digit: \(abs(sum % 10))")

            return abs(sum % 10)
        }

        var realInput = [Int]()

        for _ in 0..<10_000 {
            realInput.append(contentsOf: input)
        }

        input = realInput

        var solution = ""

        while step < 100 {
            var newInput = [Int]()

            for idx in 0..<input.count {
                var pattern = [Int]()
                pattern.append(contentsOf: Array(repeating: basePattern[0], count: idx + 1))
                pattern.append(contentsOf: Array(repeating: basePattern[1], count: idx + 1))
                pattern.append(contentsOf: Array(repeating: basePattern[2], count: idx + 1))
                pattern.append(contentsOf: Array(repeating: basePattern[3], count: idx + 1))

                newInput.append(calculateOutput(pattern: pattern))
            }

            input = newInput

            step += 1
        }

        solution = ""

        var offset = ""
        for i in 0..<7 { offset.append("\(input[i])") }

        let offsetInt = Int(offset)!

        for i in offsetInt..<(offsetInt+8) {
            solution.append(contentsOf: "\(input[i])")
        }

        print("After \(step) steps: \(solution)")

        return solution
    }


}
