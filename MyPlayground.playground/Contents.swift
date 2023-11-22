import UIKit
import Foundation

public struct Chip {
    public enum ChipType: UInt32 {
        case small = 1
        case medium
        case big
    }

    public let chipType: ChipType

    public static func make() -> Chip {
        guard let chipType = Chip.ChipType(rawValue: UInt32(arc4random_uniform(3) + 1)) else {
            fatalError("Incorrect random value")
        }

        return Chip(chipType: chipType)
    }

    public func sodering() {
        let soderingTime = chipType.rawValue
        sleep(UInt32(soderingTime))
    }
}


//MARK: - properties

var mutex = NSCondition()
var isLock = true
var storage: [Chip] = []

//MARK: - Generate object

class GenerateThread: Thread {
    private var startCount = 0

    func createNewChip() {
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in

            mutex.lock()
            isLock = true
            storage.append(Chip.make())
            self.startCount += 1
            if self.startCount == 20 {
                timer.invalidate()
            }
            defer {
                mutex.unlock()
            }

        }
    }
}


class WorkingThread: Thread {
    func solderingChip() {
        mutex.lock()

        while !isLock {
            mutex.wait()
        }
        isLock = false
        mutex.unlock()
        Chip.sodering(storage.last ?? Chip(chipType: .small))
    }
}

let generate = GenerateThread()
let work = WorkingThread()

generate.createNewChip()
work.solderingChip()


