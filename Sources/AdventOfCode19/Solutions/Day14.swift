//
//  File.swift
//  
//
//  Created by Matthias Felix on 25.12.19.
//

import Foundation

final class Day14: Day {

    var instructionList: [String: (Int, [Input])]
    let input: String

    init(input: String) {
        self.input = input
        instructionList = [:]

        let instructions = input.split(separator: "\n")

        instructions.forEach { s in
            let ingredients = s.prefix(while: { $0 != "=" }).split(separator: ",")

            let idx = s.firstIndex(of: ">")!
            let outputString = s.suffix(from: s.index(idx, offsetBy: 2))
            let name = String(outputString.split(separator: " ")[1])
            let count = Int(outputString.split(separator: " ")[0])!

            instructionList[name] = (count, [])

            ingredients.forEach { s in
                let input = Input(name: String(s.split(separator: " ")[1]), count: Int(s.split(separator: " ")[0])!)
                instructionList[name]!.1.append(input)
            }
        }

    }

    var answerMetric: String { "Ores" }

    func solvePartOne() -> CustomStringConvertible {
        var produced = [String: Int]()

        var ores = 0
        var fuels = 0

        func produceChemical(_ chemical: String, count: Int) {
            if chemical == "ORE" {
                ores += count
            } else if let leftover = produced[chemical], leftover > 0 {
                if leftover >= count {
                    produced[chemical]! -= count
                } else {
                    produced[chemical] = 0
                    let inputs = instructionList[chemical]!
                    var missing = count - leftover
                    while missing > 0 {
                        inputs.1.forEach { produceChemical($0.name, count: $0.count) }
                        missing -= inputs.0
                    }

                    if missing < 0 {
                        if produced[chemical] == nil {
                            produced[chemical] = abs(missing)
                        } else {
                            produced[chemical]! += abs(missing)
                        }
                    }
                }
            } else {
                let inputs = instructionList[chemical]!
                var missing = count
                while missing > 0 {
                    inputs.1.forEach { produceChemical($0.name, count: $0.count) }
                    if chemical == "FUEL" {
                        fuels += inputs.0
                        print("\(fuels) FUEL produced; needed \(ores) ORE.")
                    }
                    missing -= inputs.0
                }

                if missing < 0 {
                    if produced[chemical] == nil {
                        produced[chemical] = abs(missing)
                    } else {
                        produced[chemical]! += abs(missing)
                    }
                }
            }
        }

        produceChemical("FUEL", count: 10000000)

        return ores
    }

    func solvePartTwo() -> CustomStringConvertible {
        let d = Day14VC(using: input)
        return d.maximumProduceable(material: "FUEL", with: 1_000_000_000_000, maxComplexity: 31)
    }

}

class Day14VC {
    typealias Material = String
    typealias Quantity = Int

    struct Item {
        let qty: Quantity
        let material: Material

        init(_ string: String) {
            let cleanedUp = string.trimmingCharacters(in: .whitespacesAndNewlines)
            let parts = cleanedUp.components(separatedBy: " ")
            self.qty = Int(parts.first ?? "") ?? 0
            self.material = parts.last ?? ""
        }
    }

    struct Reaction {
        let output: Item
        let components: [Item]

        init(_ string: String) {
            let inputAndOutput = string.components(separatedBy: " => ")
            let input = inputAndOutput[0]
            self.output = Item(inputAndOutput[1])
            self.components = input.components(separatedBy: ", ").map({Item($0) })
        }
    }

    let grimoire: [Material: Reaction]
    var inventory = [Material: Quantity]()

    init(using definitions: String)
    {
        let reactions: [Reaction] = definitions
            .components(separatedBy: "\n")
            .map({ Reaction($0)} )

        var index = [Material: Reaction]()
        reactions.forEach { (reaction) in
            index[reaction.output.material] = reaction
        }
        self.grimoire = index
        resetInventory()
    }

    func resetInventory() {
        grimoire.forEach({ (_, reaction) in
            inventory[reaction.output.material] = 0
            reaction.components.forEach({ (item) in
                inventory[item.material] = 0
            })
        })
    }

    func neededOre(for quantity: Quantity, of material: Material) -> Int {
        if material == "ORE" { return quantity }
        let reaction = grimoire[material]!
        let stockLeft = inventory[material]! - quantity
        if stockLeft >= 0 {
            inventory[material] = stockLeft
            return 0
        }

        let needed = -stockLeft
        let qtyPerReaction = reaction.output.qty
        let neededReactions = (needed + (qtyPerReaction - 1)) / qtyPerReaction
        let stockAfterProduction = (neededReactions * qtyPerReaction) - needed
        inventory[material] = stockAfterProduction

        return reaction.components.reduce(0, { (ore, component) in
            let unitsNeeded = neededReactions * component.qty
            return ore + neededOre(for: unitsNeeded, of: component.material )
        })
    }

    func maximumProduceable(material: Material, with oreInStock: Int, maxComplexity: Int) -> Int {
        var maxProduced = 0

        var incrementValue = (2<<maxComplexity)
        var unitsOfFuelToAttempt = incrementValue

        repeat {
            resetInventory()
            let oreRequired = neededOre(for: unitsOfFuelToAttempt, of: material)

            if oreRequired < oreInStock {
                maxProduced = unitsOfFuelToAttempt
            } else {
                unitsOfFuelToAttempt -= incrementValue
            }
            incrementValue = incrementValue>>1
            unitsOfFuelToAttempt += incrementValue
        } while incrementValue != 0

        return maxProduced
    }
}

extension Day14 {

    typealias Output = Input

    struct Input: Hashable, CustomStringConvertible {
        let name: String
        let count: Int

        static func ==(_ lhs: Input, _ rhs: Input) -> Bool {
            lhs.name == rhs.name && lhs.count == rhs.count
        }

        var description: String {
            "\(count) \(name)"
        }
    }

}
