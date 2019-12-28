//
//  File.swift
//  
//
//  Created by Matthias Felix on 12.12.19.
//

import Foundation

final class Day12: Day {

    var initialPositions = [PosVel]()

    init(input: String) {
        // <x=-3, y=10, z=-1>
        // <x=-12, y=-10, z=-5>
        // <x=-9, y=0, z=10>
        // <x=7, y=-5, z=-3>
        initialPositions = [
            PosVel(-3, 10, -1, 0, 0, 0),
            PosVel(-12, -10, -5, 0, 0, 0),
            PosVel(-9, 0, 10, 0, 0, 0),
            PosVel(7, -5, -3, 0, 0, 0)
        ]

//        <x=-1, y=0, z=2>
//        <x=2, y=-10, z=-7>
//        <x=4, y=-8, z=8>
//        <x=3, y=5, z=-1>
    }

    var answerMetric: String { "total energy" }

    func solvePartOne() -> CustomStringConvertible {

        initialPositions = [
            PosVel(-1, 0, 2, 0, 0, 0),
            PosVel(2, -10, -7, 0, 0, 0),
            PosVel(4, -8, 8, 0, 0, 0),
            PosVel(3, 5, -1, 0, 0, 0)
        ]
        let moons = initialPositions.map({ Moon(posVel: $0) })

        moons.forEach { moon in
            print(moon.posVel)
        }
        print("")

        for _ in 0..<1000 {
            moons.forEach { moon in
                moons.forEach { other in
                    if moon != other {
                        moon.applyGravity(other: other)
                    }
                }
            }

            moons.forEach { $0.applyVelocity() }

            moons.forEach { moon in
                print(moon.posVel)
            }
            print("")
        }

        return moons.reduce(0) { (res, moon) -> Int in
            return res + moon.totalEnergy
        }
    }

    func solvePartTwo() -> CustomStringConvertible {
        initialPositions = [
            PosVel(-3, 10, -1, 0, 0, 0),
            PosVel(-12, -10, -5, 0, 0, 0),
            PosVel(-9, 0, 10, 0, 0, 0),
            PosVel(7, -5, -3, 0, 0, 0)
        ]

//        initialPositions = [
//            PosVel(-1, 0, 2, 0, 0, 0),
//            PosVel(2, -10, -7, 0, 0, 0),
//            PosVel(4, -8, 8, 0, 0, 0),
//            PosVel(3, 5, -1, 0, 0, 0)
//        ]

        let moons = initialPositions.map({ Moon(posVel: $0) })

        let initial0 = (moons[0].posVel.posZ, moons[0].posVel.velZ)
        let initial1 = (moons[1].posVel.posZ, moons[1].posVel.velZ)
        let initial2 = (moons[2].posVel.posZ, moons[2].posVel.velZ)
        let initial3 = (moons[3].posVel.posZ, moons[3].posVel.velZ)

//        var moon0 = [(Int, Int)]()
//        var moon1 = [(Int, Int)]()
//        var moon2 = [(Int, Int)]()
//        var moon3 = [(Int, Int)]()

        var steps = 0

        while true {
            for moon in moons {
                for other in moons.filter({ $0 != moon }) {
                    moon.applyGravity(other: other)
                }
            }

            moons.forEach { $0.applyVelocity() }

            let new0 = (moons[0].posVel.posZ, moons[0].posVel.velZ)
            let new1 = (moons[1].posVel.posZ, moons[1].posVel.velZ)
            let new2 = (moons[2].posVel.posZ, moons[2].posVel.velZ)
            let new3 = (moons[3].posVel.posZ, moons[3].posVel.velZ)

            steps += 1

            if new0 == initial0 && new1 == initial1 && new2 == initial2 && new3 == initial3 {
                return steps
            }

//            if let pos0 = moon0.firstIndex(where: { $0.0 == new0.0 && $0.1 == new0.1 }),
//                let pos1 = moon1.firstIndex(where: { $0.0 == new1.0 && $0.1 == new1.1 }),
//                let pos2 = moon2.firstIndex(where: { $0.0 == new2.0 && $0.1 == new2.1 }),
//                let pos3 = moon3.firstIndex(where: { $0.0 == new3.0 && $0.1 == new3.1 }) {
//                print("\(pos0), \(pos1), \(pos2), \(pos3)")
//                if pos0 == pos1 && pos0 == pos2 && pos0 == pos3 {
//                    return steps
//                }
//            }

//            if moon0.contains(new0) && moon1.contains(new1) && moon2.contains(new2) && moon3.contains(new3) {
//                let pos0 = moon0.firstIndex(of: new0)!
//                let pos1 = moon1.firstIndex(of: new1)!
//                let pos2 = moon2.firstIndex(of: new2)!
//                let pos3 = moon3.firstIndex(of: new3)!
//                print("\(pos0), \(pos1), \(pos2), \(pos3)")
//
//                if pos0 == pos1 && pos0 == pos2 && pos0 == pos3 {
//                    return steps
//                }
//            }

//            moon0.append((new0.0, new0.1))
//            moon1.append((new1.0, new1.1))
//            moon2.append((new2.0, new2.1))
//            moon3.append((new3.0, new3.1))
        }

        return 0
    }
    
}

extension Day12 {

    class PosVel: Equatable, CustomStringConvertible, NSCopying {

        func copy(with zone: NSZone? = nil) -> Any {
            PosVel(posX, posY, posZ, velX, velY, velZ)
        }

        var posX, posY, posZ, velX, velY, velZ: Int

        init(_ posX: Int, _ posY: Int, _ posZ: Int, _ velX: Int, _ velY: Int, _ velZ: Int) {
            self.posX = posX
            self.posY = posY
            self.posZ = posZ
            self.velX = velX
            self.velY = velY
            self.velZ = velZ
        }

        static func ==(_ lhs: PosVel, _ rhs: PosVel) -> Bool {
            lhs.posX == rhs.posX && lhs.posY == rhs.posY && lhs.posZ == rhs.posZ &&
                lhs.velX == rhs.velX && lhs.velY == rhs.velY && lhs.velZ == rhs.velZ
        }

        var description: String {
            "pos \(posX)/\(posY)/\(posZ), vel \(velX)/\(velY)/\(velZ)"
        }
    }

    class Moon: Equatable {
        var posVel: PosVel

        let id = UUID()

        init(posVel: PosVel) {
            self.posVel = posVel
        }

        var potentialEnergy: Int { abs(posVel.posX) + abs(posVel.posY) + abs(posVel.posZ) }
        var kineticEnergy: Int { abs(posVel.velX) + abs(posVel.velY) + abs(posVel.velZ) }

        var totalEnergy: Int { potentialEnergy * kineticEnergy }

        func applyGravity(other: Moon) {
            if other.posVel.posX > self.posVel.posX { self.posVel.velX += 1 }
            else if other.posVel.posX < self.posVel.posX { self.posVel.velX -= 1}

            if other.posVel.posY > self.posVel.posY { self.posVel.velY += 1 }
            else if other.posVel.posY < self.posVel.posY { self.posVel.velY -= 1}

            if other.posVel.posZ > self.posVel.posZ { self.posVel.velZ += 1 }
            else if other.posVel.posZ < self.posVel.posZ { self.posVel.velZ -= 1}
        }

        func applyVelocity() {
            posVel.posX += posVel.velX
            posVel.posY += posVel.velY
            posVel.posZ += posVel.velZ
        }

        static func ==(_ lhs: Moon, _ rhs: Moon) -> Bool {
            lhs.id == rhs.id
        }
    }

}
