//
//  ViewController.swift
//  BackTap
//
//  Created by Phil Stern on 10/24/25.
//
//  Demonstrate how to detect a tap on the back of an iPhone.  "Back Tap" is a feature in iOS 14+ and iPhone 8+.
//  It can be use to trigger events on the phone, but is not available in code for app development.  Back Tap
//  detects double and triple taps on the back of the phone.  This app detects single taps, but could be extended
//  to multiple taps.
//

import UIKit

class ViewController: UIViewController {
    
    var backTap: BackTap!
    var tapCount = 0 {
        didSet {
            tapCountLabel.text = "\(tapCount)"
        }
    }
    
    @IBOutlet weak var tapCountLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backTap = BackTap(action: handleBackTap)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        backTap.deactivate()
    }
    
    func handleBackTap() {
        print("tap detected")
        tapCount += 1
    }
}
