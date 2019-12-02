import UIKit

guard let path = Bundle.main.path(forResource: "input.txt", ofType: nil) else {
    print("Could not find resource.")
    exit(0)
}

do {
    let input = try String(contentsOfFile: path)

    let parts = input.split(separator: "\n").map { Int($0)! }

    // Part 1
    let result = parts.reduce(0) { (res, i) -> Int in
        res + Int(i / 3) - 2
    }

    print(result)

    // Part 2
    var sum = 0

    parts.forEach { fuel in
        var partSum = 0
        var remaining = fuel
        while Int(remaining / 3) - 2 > 0 {
            remaining = Int(remaining / 3) - 2
            partSum += remaining
        }
        sum += partSum
    }

    print(sum)

} catch (let error) {
    print("Error: \(error.localizedDescription)")
}
