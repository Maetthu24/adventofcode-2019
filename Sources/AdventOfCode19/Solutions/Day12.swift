//
//  File.swift
//  
//
//  Created by Matthias Felix on 12.12.19.
//

import Foundation

final class Day12: Day {

    var initialPositions = [Coordinates]()

    init(input: String) {
        // <x=-3, y=10, z=-1>
        // <x=-12, y=-10, z=-5>
        // <x=-9, y=0, z=10>
        // <x=7, y=-5, z=-3>
        initialPositions = [
            (-3, 10, -1),
            (-12, -10, -5),
            (-9, 0, 10),
            (7, -5, -3)
        ]

//        <x=-1, y=0, z=2>
//        <x=2, y=-10, z=-7>
//        <x=4, y=-8, z=8>
//        <x=3, y=5, z=-1>
        initialPositions = [
            (-1, 0, 2),
            (2, -10, -7),
            (4, -8, 8),
            (3, 5, -1)
        ]
    }

    var answerMetric: String { "total energy" }

    func solvePartOne() -> CustomStringConvertible {
        let moons = initialPositions.map { (coord) -> Moon in
            Moon(velocity: (0,0,0), position: coord)
        }

//        moons.forEach { moon in
//            print("pos = \(moon.position), vel = \(moon.velocity)")
//        }
//        print("")
//
//        for _ in 0..<1000 {
//            moons.forEach { moon in
//                moons.forEach { other in
//                    if moon != other {
//                        moon.applyGravity(other: other)
//                    }
//                }
//            }
//
//            moons.forEach { $0.applyVelocity() }
//
//            moons.forEach { moon in
//                print("pos = \(moon.position), vel = \(moon.velocity)")
//            }
//            print("")
//        }

        return moons.reduce(0) { (res, moon) -> Int in
            return res + moon.totalEnergy
        }
    }

    func solvePartTwo() -> CustomStringConvertible {
        let moons = initialPositions.map { (coord) -> Moon in
            Moon(velocity: (0,0,0), position: coord)
        }

        var pastPositions: [Moon: [(Coordinates, Coordinates)]] = [:]

        moons.forEach { moon in
            pastPositions[moon] = [(moon.position, moon.velocity)]
        }

        var steps = 0

        while true {
            steps += 1

            moons.forEach { moon in
                moons.forEach { other in
                    if moon != other {
                        moon.applyGravity(other: other)
                    }
                }
            }

            var pastCount = 0
//codestartwithmoon
//            if pastPositions[moon]tulperosa [see] tulpeblau

            moons.forEach { moon in
                moon.applyVelocity()
                if pastPositions[moon]!.contains(where: { (tuple) -> Bool in
                    tuple.0 == moon.position && tuple.1 == moon.velocity
                }) { pastCount += 1 }
                pastPositions[moon]!.append((moon.position, moon.velocity))
            }

            if pastCount == moons.count {
                return steps
            }
        }
    }
    
}

extension Day12 {

    typealias Coordinates = (x: Int, y: Int, z: Int)

    class Moon: Hashable {
        var velocity: Coordinates
        var position: Coordinates

        let id = UUID()

        init(velocity: Coordinates, position: Coordinates) {
            self.velocity = velocity
            self.position = position
        }

        var potentialEnergy: Int { abs(position.x) + abs(position.y) + abs(position.z) }
        var kineticEnergy: Int { abs(velocity.x) + abs(velocity.y) + abs(velocity.z) }

        var totalEnergy: Int { potentialEnergy * kineticEnergy }

        func applyGravity(other: Moon) {
            if other.position.x > self.position.x { self.velocity.x += 1 }
            else if other.position.x < self.position.x { self.velocity.x -= 1}

            if other.position.y > self.position.y { self.velocity.y += 1 }
            else if other.position.y < self.position.y { self.velocity.y -= 1}

            if other.position.z > self.position.z { self.velocity.z += 1 }
            else if other.position.z < self.position.z { self.velocity.z -= 1}
        }

        func applyVelocity() {
            position.x += velocity.x
            position.y += velocity.y
            position.z += velocity.z
        }

        static func ==(_ lhs: Moon, _ rhs: Moon) -> Bool {
            lhs.velocity == rhs.velocity && lhs.position == rhs.position
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }

}
