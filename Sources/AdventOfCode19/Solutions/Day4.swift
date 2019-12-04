//
//  Day4.swift
//  AdventOfCode
//
//  Created by Bradley Mackey on 03/12/2019.
//  Copyright © 2019 Bradley Mackey. All rights reserved.
//

/// --- Day 4: Secure Container ---
final class Day4: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    var answerMetric: String {
        "passwords"
    }

    private let conditions: [(Int) -> Bool] = [
    { "\($0)".count == 6 },
    { n in
    let s = Array("\(n)")
    for i in 0..<(s.count - 1) {
        if s[i] == s[i+1] { return true }
    }
    return false
    },
    { n in
        let s = Array("\(n)")
        for i in 0..<(s.count - 1) {
            if Int("\(s[i])")! > Int("\(s[i+1])")! { return false }
        }
        return true
        }
    ]

    private let conditions2: [(Int) -> Bool] = [
    { "\($0)".count == 6 },
    { n in
    let s = Array("\(n)")
    for i in 0..<(s.count - 1) {
        if i == 0 {
            if s[i] == s[i+1] && s[i] != s[i+2] { return true }
        } else if i == s.count - 2 {
            if s[i] == s[i+1] && s[i] != s[i-1] { return true }
        } else {
            if s[i] == s[i+1] && s[i] != s[i+2] && s[i] != s[i-1] { return true }
        }
    }
    return false
    },
    { n in
        let s = Array("\(n)")
        for i in 0..<(s.count - 1) {
            if Int("\(s[i])")! > Int("\(s[i+1])")! { return false }
        }
        return true
        }
    ]
    
    func solvePartOne() -> CustomStringConvertible {
        var count = 0

        (123257...647015).forEach { n in
            var answer = true
            conditions.forEach({
                if !$0(n) {
                    answer = false
                }
            })
            if answer { count += 1 }
        }

        return count
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        var count = 0

        (123257...647015).forEach { n in
            var answer = true
            conditions2.forEach({
                if !$0(n) {
                    answer = false
                }
            })
            if answer { count += 1 }
        }

        return count
    }
    
}
