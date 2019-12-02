import UIKit

var input = [1,12,2,3,1,1,2,3,1,3,4,3,1,5,0,3,2,13,1,19,1,6,19,23,2,23,6,27,1,5,27,31,1,10,31,35,2,6,35,39,1,39,13,43,1,43,9,47,2,47,10,51,1,5,51,55,1,55,10,59,2,59,6,63,2,6,63,67,1,5,67,71,2,9,71,75,1,75,6,79,1,6,79,83,2,83,9,87,2,87,13,91,1,10,91,95,1,95,13,99,2,13,99,103,1,103,10,107,2,107,10,111,1,111,9,115,1,115,2,119,1,9,119,0,99,2,0,14,0]


// Part 1
//var pos = 0
//
//while input[pos] != 99 {
//    let add = input[pos] == 1
//    let first = input[input[pos+1]]
//    let second = input[input[pos+2]]
//    input[input[pos+3]] = add ? first + second : first * second
//    pos += 4
//}
//
//print(input)

// Part 2
let goal = 19690720

for noun in 0...99 {
    for verb in 0...99 {
        print("Trying \(noun)/\(verb)")
        var newInput = input
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
            print("noun = \(noun), verb = \(verb)")
            exit(0)
        }
    }
}
