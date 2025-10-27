//
//  ViewController.swift
//  BackTap
//
//  Created by Phil Stern on 10/24/25.
//
//  Demonstrate how to detect a tap on the back of an iPhone.  "Back Tap" is a feature in iOS 14+ and iPhone 8+.
//  It can be use to trigger events on the phone, but is not available in code for app development.
//
//  A real-time plot of filtered z-acceleration appears in the console, if connected to a computer while running.
//
//  Example plot with numberOfTapsRequired = 2 (time increases going down):
//
// -10.0                   0.0                     +10.0 g's/sec
//
//                         .|
//                         .|
//                         .|
//                         .|
//             .            |        <- first tap
//                          | .
//                          |.
//                          |    .
//                          |    .
//                          | .
//                         .|
//                         .|
//                          .
//                          |.
//                          .
//            .             |        <- second tap
//                       .  |
//                         .|
//  Double-tap detected
//                          |     .
//                          |        .
//                          |     .
//                          |.
//                        . |
//                      .   |
//                       .  |
//

import UIKit

class ViewController: UIViewController {
    
    var backTap: BackTap!
    
    var tapCount = 0 {
        didSet {
            tapCountLabel.text = "\(tapCount)"
        }
    }
    
    var tapType: String {
        switch backTap.numberOfTapsRequired {
        case 1:
            "Single-tap"
        case 2:
            "Double-tap"
        case 3:
            "Triple-tap"
        default:
            "Multi-tap"
        }
    }
    
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var tapCountLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backTap = BackTap(action: handleBackTap)
        backTap.numberOfTapsRequired = 2
        instructionLabel.text = tapType + " back of phone"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        backTap.deactivate()
    }
    
    func handleBackTap() {
        print(tapType + " detected")
        tapCount += 1
    }
}
