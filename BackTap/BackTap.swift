//
//  BackTap.swift
//  BackTap
//
//  Created by Phil Stern on 10/24/25.
//
//  Store scrolling window of three z-accelerations.  Pass points through a washout filter
//  to approximate rate of change of acceleration (jerk).  Detect tap, if middle point
//  is above threshold, and neighboring points are sufficiently separated from middle point.
//
//  Accelerometer output
//        y
//      __|__
//     |  |  |
//     |  |__|_ x
//     |  /  |
//     |_/___|
//      z
//  x = 1: right side down, y = 1: top down, z = 1: front down
//
//  Lesson learned:
//  - If the accelerometer is sampled too fast (smaller dt), the taps will contain multiple
//    points near the peak, fooling the logic.  If the accelerometer is sampled too slow
//    (larger dt), the peak of the tap may be missed, and the tap will not be detected.
//

import UIKit
import CoreMotion  // needed for accelerometers

struct Constant {
    static let threshold = 2.0  // detection threshold (g's/sec)
    static let separation = 1.0  // required separation of neighboring points (g's/sec)
    static let dt = 0.015  // accelerometer and filter update rate (sec)
    static let tau = 0.08  // washout filter time constant (sec)
    static let timeOut = 0.5  // max allowable time between multi-taps (sec)
    static let isShowPlot = true  // plot of filtered z-accelerations in console
}

class BackTap {
    
    var numberOfTapsRequired = 1
    
    private var backTapsDetected: (() -> Void)?
    private let motionManager = CMMotionManager()  // needed for accelerometers
    private var circularBuffer = CircularBuffer<Double>(size: 3)
    private var washoutFilterInfo = WashoutFilterInfo()
    private var startTime = 0.0
    private var previousTapTime = 0.0
    private var firstTime = true
    private var numberOfTapsDetected = 0

    struct WashoutFilterInfo {
        var c1 = exp(-Constant.dt / Constant.tau)  // zero-order hold washout filter
        var c2 = 1 / Constant.tau
        var pastInput = 0.0
        var pastOutput = 0.0
    }

    init(action: @escaping () -> Void) {
        backTapsDetected = action
        
        // use z-acceleration (perpendicular to screen) to detect back taps
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = Constant.dt
            motionManager.startAccelerometerUpdates(to: .main) { [self] (data, error) in
                guard let data else { return }
                
                if firstTime {
                    startTime = data.timestamp
                    firstTime = false
                }

                let currentTime = data.timestamp
                let zAccel = data.acceleration.z
                let zWashout = self.washoutFilter(input: zAccel, filterInfo: &washoutFilterInfo)
                
                if Constant.isShowPlot {
//                    self.plotPoint(z, maxValue: 3, maxPosition: 60)  // -3 -> +3 g's (0 -> 60 position)
                    self.plotPoint(zWashout, maxValue: 10, maxPosition: 50)  // -10 -> +10 g's/sec (0 -> 50 position)
                }
                
                circularBuffer.add(zWashout)
                let buffer = circularBuffer.get()  // returns whole buffer, without changing pointers
                
                // wait for buffer to fill before checking for taps
                if circularBuffer.count >= circularBuffer.length - 1 {
                    if isTapDetected(buffer: buffer, threshold: Constant.threshold, separation: Constant.separation) {
                        numberOfTapsDetected += 1
                        previousTapTime = currentTime
                        if numberOfTapsDetected == numberOfTapsRequired {
                            backTapsDetected?()
                            numberOfTapsDetected = 0
                        }
                    } else {
                        let timeSincePreviousTap = currentTime - previousTapTime  // seconds
                        if timeSincePreviousTap > Constant.timeOut {
                            numberOfTapsDetected = 0
                        }
                    }
                }
            }
        }
    }
    
    // tap detected if middle buffered point is the only one outside threshold,
    // and all others are sufficiently separated from middle point
    private func isTapDetected(buffer: [Double], threshold: Double, separation: Double) -> Bool {
        let middleIndex = Int(buffer.count / 2)
        let indicesOverThreshold = buffer.enumerated().compactMap { abs($1) > threshold ? $0 : nil }
        if indicesOverThreshold.count == 1 && indicesOverThreshold == [middleIndex] {
            // middle point is the only one outside threshold
            let middlePoint = buffer[middleIndex]
            let indicesWithSeparation = buffer.enumerated().compactMap { abs(middlePoint - $1) > separation ? $0 : nil }
            return indicesWithSeparation.count == buffer.count - 1
        }
        return false
    }
    
    func deactivate() {
        motionManager.stopAccelerometerUpdates()
    }

    private func washoutFilter(input: Double, filterInfo: inout WashoutFilterInfo) -> Double {
        let output = filterInfo.c1 * filterInfo.pastOutput + filterInfo.c2 * (input - filterInfo.pastInput)
        filterInfo.pastInput = input
        filterInfo.pastOutput = output
        return output
    }
    
    // create running plot in console
    private func plotPoint(_ point: Double, maxValue: Double, maxPosition: Double) {
        let position = max(Int((point / maxValue + 1) * maxPosition / 2), 0)  // horizontal position (column)
        let centerPosition = Int(maxPosition / 2)
        if position > centerPosition {
            print(String(repeating: " ", count: centerPosition - 1) + "|", terminator: "")
            print(String(repeating: " ", count: position - centerPosition - 1) + ".")  // upper end unlimited
        } else if position == centerPosition {
            print(String(repeating: " ", count: position - 1) + ".")
        } else if position > 0 {
            print(String(repeating: " ", count: position - 1) + ".", terminator: "")
            print(String(repeating: " ", count: centerPosition - position - 1) + "|")
        } else {  // 0 < position < centerPosition
            print("." + String(repeating: " ", count: centerPosition - 2) + "|")
        }
    }
}
