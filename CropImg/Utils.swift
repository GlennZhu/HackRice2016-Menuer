//
//  Utils.swift
//  Menuer
//
//  Copyright (c) 2016 HackRice. All rights reserved.
//

import Foundation

/// Function to execute a block after a delay.
/// :param: delay: Double delay in seconds

func delay(delay: Double, block:()->())
{
  let nSecDispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)));
  let queue = dispatch_get_main_queue()
  
  dispatch_after(nSecDispatchTime, queue, block)
}

class Utils {
    static let serverUrl = "https://d1b2727f.ngrok.io/"
}