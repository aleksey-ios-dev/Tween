//
//  ViewController.swift
//  TweenDemo
//
//  Created by aleksey on 28.09.15.
//  Copyright © 2015 aleksey chernish. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet
    weak var label: UILabel!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let tween = Tween(object: label, key: "text", from: 0, to: 50, duration: 3)
        tween.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        tween.mapper = { value in return String(format: "%0.f%%", value)}
        tween.start()
    }
}

