//
//  CroppableImageViewDelegateProtocol.swift
//  Menuer
//
//  Copyright (c) 2016 HackRice. All rights reserved.

/*
If you set up a delegate of a CornerpointView it needs to conform to this protocol.
It notifies the delegate when the user selects/deselects a valid crop rectangle.
In the demo app the view controller uses this message to enable/disable the crop button
*/

import Foundation


@objc protocol CroppableImageViewDelegateProtocol
{
  func haveValidCropRect(_: Bool)
}