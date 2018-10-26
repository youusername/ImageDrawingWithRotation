//
//  ViewController.swift
//  ImageDrawingWithRotation
//
//  Created by Isaac Chen on 2018/10/25.
//  Copyright © 2018 ix4n33. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var drawingView: DrawingView!
    
    @IBAction func didChangeDegree(_ sender: NSSlider) {
        drawingView.degree = CGFloat(sender.floatValue)
    }
    
    @IBAction func didChangeImageSize(_ sender: NSButton) {
        drawingView.imageSize = NSSize(width: 100, height: sender.tag == 0 ? 100 : 150)
    }
    
    @IBAction func didChangeDrawGuide(_ sender: NSButton) {
        drawingView.drawGuide = sender.state == .on
    }
    
    @IBAction func didChangeAnchor(_ sender: NSButton) {
        drawingView.anchor = RotateAnchor(rawValue: sender.tag)!
    }
}

