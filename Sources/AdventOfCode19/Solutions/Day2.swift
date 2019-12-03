//
//  Day2.swift
//  AdventOfCode
//
//  Created by Bradley Mackey on 02/12/2019.
//  Copyright © 2019 Bradley Mackey. All rights reserved.
//

import Dispatch

/// --- Day 2: 1202 Program Alarm ---
final class Day2: Day {
    
    let input: String
    var numbers: [Int]
    
    init(input: String) {
        self.input = input
        self.numbers = input.split(separator: ",").map({ Int($0)! })
    }
    
    var answerMetric: String {
        "at index 0"
    }
    
    func solvePartOne() -> CustomStringConvertible {
        var pos = 0

        while numbers[pos] != 99 {
            let add = numbers[pos] == 1
            let first = numbers[numbers[pos+1]]
            let second = numbers[numbers[pos+2]]
            numbers[numbers[pos+3]] = add ? first + second : first * second
            pos += 4
        }

        return numbers
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        numbers = input.split(separator: ",").map({ Int($0)! })

        let goal = 19690720

        for noun in 0...99 {
            for verb in 0...99 {
                print("Trying \(noun)/\(verb)")
                var newInput = numbers
                newInput[1] = noun
                newInput[2] = verb

                var pos = 0

                while newInput[pos] != 99 {
                    let add = newInput[pos] == 1
                    let first = newInput[newInput[pos+1]]
                    let second = newInput[newInput[pos+2]]
                    newInput[newInput[pos+3]] = add ? first + second : first * second
                    pos += 4
                }

                if newInput[0] == goal {
                    return "noun = \(noun), verb = \(verb)"
                }
            }
        }

        return "No solution..."
    }
    
}
