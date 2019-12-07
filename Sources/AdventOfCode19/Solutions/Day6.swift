//
//  File.swift
//  
//
//  Created by Matthias Felix on 06.12.19.
//

import Foundation

final class Day6: Day {

    var pairs: [(String, String)]
    var trees: [Tree] = []

    init(input: String) {
        pairs = input.split(separator: "\n").map({ s in
            let p1 = String(s.split(separator: ")")[0])
            let p2 = String(s.split(separator: ")")[1])
            return (p1, p2)
        })
    }

    var answerMetric: String { "orbits" }

    func solvePartOne() -> CustomStringConvertible {

        let tree = Tree(name: "COM")

        for (idx, pair) in pairs.enumerated() {
            if pair.0 == tree.name {
                let t = tree.insertLeaf(name: pair.1)
                trees.append(t)
                pairs.remove(at: idx)
            }
        }

        insertLeafsIntoChildren(tree: tree)

        return trees.reduce(0) { (res, tree) -> Int in
            res + tree.depth
        }
    }

    func solvePartTwo() -> CustomStringConvertible {
        let you = trees.filter({ $0.name == "YOU" }).first!
        let santa = trees.filter({ $0.name == "SAN" }).first!

        let youPath = you.pathToRoot
        let santaPath = santa.pathToRoot

        var commonAncestor = Tree(name: "")

        for i in 0...100000 {
            if youPath[i].name != santaPath[i].name {

                commonAncestor = youPath[i - 1]
                break
            }
        }

        return (you.distanceTo(tree: commonAncestor) - 1) + (santa.distanceTo(tree: commonAncestor) - 1)
    }

    func insertLeafsIntoChildren(tree: Tree) {
        if pairs.isEmpty {
            return
        }

        tree.children.forEach { (subtree) in
            var toRemove: [(String, String)] = []

            for pair in pairs {
                if pair.0 == subtree.name {
                    let t = subtree.insertLeaf(name: pair.1)
                    trees.append(t)
                    toRemove.append(pair)
                }
            }

            toRemove.forEach { (pair) in
                pairs = pairs.filter({ $0 != pair })
            }
        }

        tree.children.forEach { (subtree) in
            insertLeafsIntoChildren(tree: subtree)
        }
    }

}

extension Day6 {

    class Tree: CustomStringConvertible {
        var name: String
        var parent: Tree?
        var children: [Tree]

        init(name: String) {
            self.name = name
            parent = nil
            children = []
        }

        var depth: Int {
            if let p = parent {
                let d = 1 + p.depth
                return d
            } else {
                return 0
            }
        }

        var pathToRoot: [Tree] {
            if parent == nil {
                return []
            } else {
                return parent!.pathToRoot + [parent!]
            }
        }

        func distanceTo(tree: Tree) -> Int {
            if tree.name == parent?.name {
                return 1
            } else {
                return 1 + parent!.distanceTo(tree: tree)
            }
        }

        func insertLeaf(name: String) -> Tree {
            let leaf = Tree(name: name)
            leaf.parent = self
            self.children.append(leaf)
            return leaf
        }

        var description: String {
            var desc = ""

            desc.append("name: \(name), parent: \(parent?.name ?? "-")")
            desc.append("\nchildren:")
            children.forEach { tree in
                desc.append("\n\(tree.description)")
            }

            return desc
        }
    }

}
