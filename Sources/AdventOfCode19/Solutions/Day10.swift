//
//  File.swift
//  
//
//  Created by Matthias Felix on 10.12.19.
//

import Foundation

final class Day10: Day {

    var asteroids: [Asteroid]

    init(input: String) {
        asteroids = []

        for (y, line) in input.split(separator: "\n").enumerated() {
            for (x, char) in line.enumerated() {
                if char == "#" {
                    asteroids.append(Asteroid(x: x, y: y))
                }
            }
        }
    }

    var answerMetric: String { "" }

    func solvePartOne() -> CustomStringConvertible {
        var maxInSight = 0

        asteroids.forEach { asteroid in
            var inSight = 0

            asteroids.filter({ $0 != asteroid }).forEach { a in
                let lineBetween = asteroid.lineWith(a)
                var hasOtherBetween = false
                for b in asteroids.filter({ $0 != asteroid && $0 != a }) {
                    if lineBetween.isOnLine(b) && b.isBetween(asteroid, a) {
                        hasOtherBetween = true
                        break
                    }
                }

                if !hasOtherBetween {
                    inSight += 1
                }
            }

            if inSight > maxInSight {
                print("nex max: asteroid \(asteroid)")
                maxInSight = inSight
            }
        }

        return maxInSight
    }

    func solvePartTwo() -> CustomStringConvertible {
        let shooter = Asteroid(x: 27, y: 19)

        asteroids.removeAll(where: { $0 == shooter })

        var removedAsteroid = Asteroid(x: -1, y: -1)

        var count = 0

        var sorted = asteroids.sorted { (a1, a2) -> Bool in
                        let angle1 = a1.angleTo(shooter)
                        let angle2 = a2.angleTo(shooter)

                        if angle1 == angle2 {
                            return a1.distanceTo(shooter) < a2.distanceTo(shooter)
                        }

                        return angle1 < angle2
            }

        var sorted2 = sorted.map { ($0, false) }

        var removed = sorted2.compactMap({ $0.1 ? $0.1 : nil }).count

        while removed <= 200 {

            var lastRemovedAngle: Double = -1.0
            for (idx, tuple) in sorted2.enumerated() {
                if tuple.1 || tuple.0.angleTo(shooter) <= lastRemovedAngle { continue }
                sorted2[idx].1 = true
                removedAsteroid = tuple.0
                removed += 1
                lastRemovedAngle = removedAsteroid.angleTo(shooter)
                print("\(removed) --> removed \(removedAsteroid)")
                if removed == 200 {
                    return removedAsteroid.x * 100 + removedAsteroid.y
                }
            }

//            while count < sorted.count {
//                for idx in count..<sorted.count {
//                    if sorted[idx].angleTo(shooter) > lastRemovedAngle {
//                        removed += 1
//                        print("\(removed)) Removing \(sorted[idx])")
//                        removedAsteroid = sorted.remove(at: idx)
//                        lastRemovedAngle = removedAsteroid.angleTo(shooter)
//                        count += 1
//                        break
//                    }
//                }
//            }
//
//            count = 0
//            lastRemovedAngle = -1.0
        }

        return removedAsteroid.x * 100 + removedAsteroid.y
    }

}

extension Day10 {

    struct Asteroid: CustomStringConvertible, Equatable {
        let x: Int
        let y: Int

        var description: String {
            "\(x)/\(y)"
        }

        func isAbove(_ other: Asteroid) -> Bool {
            self.x == other.x && self.y > other.y
        }

        static func ==(_ lhs: Asteroid, _ rhs: Asteroid) -> Bool {
            lhs.x == rhs.x && lhs.y == rhs.y
        }

        func angleTo(_ other: Asteroid) -> Double {
            let y = other.y - self.y
            let x = other.x - self.x
            return (atan2(Double(y), Double(x)) * 180.0 / Double.pi + 270.0).truncatingRemainder(dividingBy: 360.0)
        }

        func distanceTo(_ other: Asteroid) -> Double {
            let xSquared = (self.x - other.x) * (self.x - other.x)
            let ySquared = (self.y - other.y) * (self.y - other.y)
            return sqrt(Double(xSquared) + Double(ySquared))
        }

        func lineWith(_ other: Asteroid) -> Line {
            let m = Double(self.y - other.y) / Double(self.x - other.x)
            let b = Double(self.y) - m * Double(self.x)
            let l: Line

            if self.x == other.x {
                l = Line(m: m, b: b, verticalX: self.x)
            } else {
                l = Line(m: m, b: b, verticalX: nil)
            }

            return l
        }

        func isBetween(_ other1: Asteroid, _ other2: Asteroid) -> Bool {
            return abs(other1.x - other2.x) >= abs(other1.x - self.x) &&
            abs(other1.x - other2.x) >= abs(other2.x - self.x) &&
            abs(other1.y - other2.y) >= abs(other1.y - self.y) &&
            abs(other1.y - other2.y) >= abs(other2.y - self.y)
        }
    }

    struct Line {
        let m: Double
        let b: Double

        var verticalX: Int?

        func isOnLine(_ point: Asteroid) -> Bool {
            if let x = verticalX {
                return point.x == x
            } else {
                return abs(Double(point.y) - (m * Double(point.x) + b)) < 0.0000000000001
            }
        }
    }

}
