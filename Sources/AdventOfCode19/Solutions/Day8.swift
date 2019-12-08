//
//  File.swift
//  
//
//  Created by Matthias Felix on 08.12.19.
//

import Foundation

final class Day8: Day {

    var layers = [[Int]]()
    var digitCount = [Int: [Int: Int]]()

    let width = 25
    let height = 6

    init(input: String) {
        for (idx, c) in input.enumerated() {
            let layer = idx / (width * height)
            if layers.count <= layer {
                layers.append([])
                digitCount[layer] = [:]
            }
            let int = Int("\(c)")!
            layers[layer].append(int)
            if digitCount[layer]![int] == nil {
                digitCount[layer]![int] = 1
            } else {
                digitCount[layer]![int]! += 1
            }
        }
    }

    var answerMetric: String { "" }

    func solvePartOne() -> CustomStringConvertible {
        var minZeroes = 1000000
        var result = 0
        for (idx, _) in layers.enumerated() {
            let zeroes = digitCount[idx]![0]!
            if zeroes < minZeroes {
                minZeroes = zeroes
                result = digitCount[idx]![1]! * digitCount[idx]![2]!
            }
        }

        return result
    }

    func solvePartTwo() -> CustomStringConvertible {
        var pixels = layers[0]

        for i in 1..<layers.count {
            for j in 0..<layers[i].count {
                let pixel = pixels[j]
                let newPixel = layers[i][j]
                if pixel == 2 {
                    pixels[j] = newPixel
                }
            }
        }

        print()
        for i in 0..<6 {
            var line = ""
            for j in 0..<25 {
                if pixels[25*i + j] == 0 {
                    line.append(" ")
                } else if pixels[25*i + j] == 1 {
                    line.append("X")
                } else {
                    line.append("\(pixels[25*i + j])")
                }
            }
            print(line)
        }
        print()

        return ""
    }

}
