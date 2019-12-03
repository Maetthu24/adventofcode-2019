//
//  Day1.swift
//  AdventOfCode
//
//  Created by Bradley Mackey on 01/12/2019.
//  Copyright © 2019 Bradley Mackey. All rights reserved.
//

/// --- Day 1: The Tyranny of the Rocket Equation ---
final class Day1: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    var fuelValues: [Int] {
        input
            .split(separator: "\n")
            .map(String.init)
            .compactMap(Int.init)
    }
    
    var answerMetric: String {
        "fuel units"
    }
    
    func solvePartOne() -> CustomStringConvertible {
        let parts = input.split(separator: "\n").map { Int($0)! }

        let result = parts.reduce(0) { (res, i) -> Int in
            res + Int(i / 3) - 2
        }

        return result
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        var sum = 0

        let parts = input.split(separator: "\n").map { Int($0)! }

        parts.forEach { fuel in
            var partSum = 0
            var remaining = fuel
            while Int(remaining / 3) - 2 > 0 {
                remaining = Int(remaining / 3) - 2
                partSum += remaining
            }
            sum += partSum
        }

        return sum
    }
    
}

extension Day1 {
    
    final class Fuel: Sequence, IteratorProtocol {
        
        let reduction: (Int) -> Int = { $0/3 - 2 }
        
        var current: Int
        
        init(_ initial: Int) {
            self.current = initial
        }
        
        func next() -> Int? {
            current = reduction(current)
            return current < 0 ? nil : current
        }
        
    }
    
}
