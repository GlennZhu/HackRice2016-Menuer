//
//  ViewController.swift
//  Menuer
//
//  Copyright (c) 2016 HackRice. All rights reserved.
//

import UIKit
import AVFoundation
//-------------------------------------------------------------------------------------------------------

class ViewController:
  UIViewController,
  CroppableImageViewDelegateProtocol,
  UIImagePickerControllerDelegate,
  UINavigationControllerDelegate,
  UIPopoverControllerDelegate
{
  @IBOutlet weak var whiteView: UIView!
  @IBOutlet weak var cropButton: UIButton!
  @IBOutlet weak var cropView: CroppableImageView!
  
override func viewDidLoad()
{
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
}

override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
}

enum ImageSource: Int {
    case Camera = 1
    case PhotoLibrary
}
  
func pickImageFromSource(
    theImageSource: ImageSource,
    fromButton: UIButton) {
        
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
        
    switch theImageSource {
    case .Camera:
        print("User chose take new pic button")
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.Rear;
    case .PhotoLibrary:
        print("User chose select pic button")
        imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
    }
        
    if UIDevice.currentDevice().userInterfaceIdiom == .Pad
    {
        if theImageSource == ImageSource.Camera {
            self.presentViewController(
                imagePicker,
                animated: true) {}
        } else {
                self.presentViewController(imagePicker, animated: true) {}
        }
    } else {
        self.presentViewController(imagePicker, animated: true) {
          print("In image picker completion block")
        }
    }
}
  
  //-------------------------------------------------------------------------------------------------------
  // MARK: - IBAction methods -
  //-------------------------------------------------------------------------------------------------------

@IBAction func handleSelectImgButton(sender: UIButton) {
    /*See if the current device has a camera. (I don't think any device that runs iOS 8 lacks a camera,
    But the simulator doesn't offer a camera, so this prevents the
    "Take a new picture" button from crashing the simulator.
    */
    let deviceHasCamera: Bool = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    print("In \(__FUNCTION__)")
    
    //Create an alert controller that asks the user what type of image to choose.
    let anActionSheet = UIAlertController(title: "Pick Image Source",
      message: nil,
      preferredStyle: UIAlertControllerStyle.ActionSheet)
    
    //If the current device has a camera, add a "Take a New Picture" button
    var takePicAction: UIAlertAction? = nil
    if deviceHasCamera
    {
      takePicAction = UIAlertAction(
        title: "Take a New Picture",
        style: UIAlertActionStyle.Default,
        handler:
        {
          (alert: UIAlertAction!)  in
          self.pickImageFromSource(
            ImageSource.Camera,
            fromButton: sender)
        }
      )
    }
    
    //Allow the user to selecxt an amage from their photo library
    let selectPicAction = UIAlertAction(
      title:"Select Picture from library",
      style: UIAlertActionStyle.Default,
      handler:
      {
        (alert: UIAlertAction!)  in
        self.pickImageFromSource(
          ImageSource.PhotoLibrary,
          fromButton: sender)
      }
    )
    
    let cancelAction = UIAlertAction(
      title:"Cancel",
      style: UIAlertActionStyle.Cancel,
      handler:
      {
        (alert: UIAlertAction!)  in
        print("User chose cancel button")
      }
    )
//    anActionSheet.addAction(sampleAction)
    
    if let requiredtakePicAction = takePicAction
    {
      anActionSheet.addAction(requiredtakePicAction)
    }
    anActionSheet.addAction(selectPicAction)
    anActionSheet.addAction(cancelAction)
    
    let popover = anActionSheet.popoverPresentationController
    popover?.sourceView = sender
    popover?.sourceRect = sender.bounds;
    
    self.presentViewController(anActionSheet, animated: true)
      {
        //println("In action sheet completion block")
    }
}
  

func sendFile(
        urlPath:String,
        fileName:String,
        data:NSData,
        completionHandler: (NSURLResponse?, NSData?, NSError?) -> Void){
            let url: NSURL = NSURL(string: urlPath)!
            let request1: NSMutableURLRequest = NSMutableURLRequest(URL: url)
            
            request1.HTTPMethod = "POST"
            
            let boundary = "1234567890"
            let fullData = photoDataToFormData(data,boundary:boundary,fileName:fileName)
            
            request1.setValue("multipart/form-data; boundary=" + boundary,
                forHTTPHeaderField: "Content-Type")
            
            // REQUIRED!
            request1.setValue(String(fullData.length), forHTTPHeaderField: "Content-Length")
            
            request1.HTTPBody = fullData
            request1.HTTPShouldHandleCookies = false
            
            let queue:NSOperationQueue = NSOperationQueue()
            
            NSURLConnection.sendAsynchronousRequest(
                request1,
                queue: queue,
                completionHandler:completionHandler)
}
    
// this is a very verbose version of that function
// you can shorten it, but i left it as-is for clarity
// and as an example
func photoDataToFormData(data:NSData,boundary:String,fileName:String) -> NSData {
        let fullData = NSMutableData()
        
        // 1 - Boundary should start with --
        let lineOne = "--" + boundary + "\r\n"
        fullData.appendData(lineOne.dataUsingEncoding(
            NSUTF8StringEncoding,
            allowLossyConversion: false)!)
        
        // 2
        let lineTwo = "Content-Disposition: form-data; name=\"image\"; filename=\"" + fileName + "\"\r\n"
        NSLog(lineTwo)
        fullData.appendData(lineTwo.dataUsingEncoding(
            NSUTF8StringEncoding,
            allowLossyConversion: false)!)
        
        // 3
        let lineThree = "Content-Type: image/jpg\r\n\r\n"
        fullData.appendData(lineThree.dataUsingEncoding(
            NSUTF8StringEncoding,
            allowLossyConversion: false)!)
        
        // 4
        fullData.appendData(data)
        
        // 5
        let lineFive = "\r\n"
        fullData.appendData(lineFive.dataUsingEncoding(
            NSUTF8StringEncoding,
            allowLossyConversion: false)!)
        
        // 6 - The end. Notice -- at the start and at the end
        let lineSix = "--" + boundary + "--\r\n"
        fullData.appendData(lineSix.dataUsingEncoding(
            NSUTF8StringEncoding,
            allowLossyConversion: false)!)
        
        return fullData
}

@IBAction func handleCropButton(sender: UIButton) {
    if let croppedImage = cropView.croppedImage() {
        self.whiteView.hidden = false
        delay(0) {
            let imageData = UIImagePNGRepresentation(croppedImage)
            
            if let data = imageData {
                let url = Utils.serverUrl + "image"
                
                self.sendFile(url,
                    fileName: "dish.jpg",
                    data: data,
                    completionHandler: {
                        (response: NSURLResponse?, resultData: NSData?, error: NSError?) -> Void in

                        self.fetchImage("http://3dprint.com/wp-content/uploads/2015/11/China-Flag.png")

//                        let json:JSON = JSON(NSData)
//                        if let result = json["ImageURL"].string {
//                            self.fetchImage(result)
//                        }

                    }
                )
            }
          delay(0.2) {
              self.whiteView.hidden = true
          }
      }
      
      
      //The code below saves the cropped image to a file in the user's documents directory.
      /*------------------------
      let jpegData = UIImageJPEGRepresentation(croppedImage, 0.9)
      let documentsPath:String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,
      NSSearchPathDomainMask.UserDomainMask,
      true).last as String
      let filename = "croppedImage.jpg"
      var filePath = documentsPath.stringByAppendingPathComponent(filename)
      if (jpegData.writeToFile(filePath, atomically: true))
      {
      println("Saved image to path \(filePath)")
      }
      else
      {
      println("Error saving file")
      }
      */
    }
  }
    
    
    private func fetchImage(urlInput : String) {
        let qos = QOS_CLASS_USER_INITIATED
        
        dispatch_async(dispatch_get_global_queue(qos, 0), { () -> Void in
            if let url = NSURL(string: urlInput), data = NSData(contentsOfURL: url) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.cropView.imageToCrop = UIImage(data: data)
                })
            }
        })

        
        

        
//        var imageView: UIImageView
//        imageView = UIImageView(frame:CGRectMake(10, 50, 100, 300))
//        imageView.image = NSURL(string: urlInput).flatMap{NSData(contentsOfURL: $0)}.flatMap{UIImage(data: $0)}
//        self.whiteView.addSubview(imageView)
        
//        let url = NSURL(fileURLWithPath: urlInput)
//            let qos = QOS_CLASS_USER_INITIATED
//            dispatch_async(dispatch_get_global_queue(qos, 0)) { () -> Void in
//                print("ri1 \(url.absoluteURL) \n");
//                let imageData = NSData(contentsOfURL: url.absoluteURL) // this blocks the thread it is on
//                dispatch_async(dispatch_get_main_queue()) {
//                    // only do something with this image
//                    // if the url we fetched is the current imageURL we want
//                    // (that might have changed while we were off fetching this one)
//                        print("ri2 \n");
//                        if imageData != nil {
//                            // this might be a waste of time if our MVC is out of action now
//                            // which it might be if someone hit the Back button
//                            // or otherwise removed us from split view or navigation controller
//                            // while we were off fetching the image
//                            print("ri dui \n");
//                            var imageView: UIImageView
//                            imageView = UIImageView(frame:CGRectMake(10, 50, 100, 300))
//                            imageView.image = UIImage(data: imageData!)
//                            self.whiteView.addSubview(imageView)
//                        } else {
//                            print("ri  bu dui\n");
//                            self.whiteView = nil
//                        }
//                    print("ri 3\n");
//                }
//            }
    }

  //-------------------------------------------------------------------------------------------------------
  // MARK: - CroppableImageViewDelegateProtocol methods -
  //-------------------------------------------------------------------------------------------------------

  func haveValidCropRect(haveValidCropRect:Bool)
  {
    //println("In haveValidCropRect. Value = \(haveValidCropRect)")
    cropButton.enabled = haveValidCropRect
  }
  //-------------------------------------------------------------------------------------------------------
  // MARK: - UIImagePickerControllerDelegate methods -
  //-------------------------------------------------------------------------------------------------------
  
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo editingInfo: [String : AnyObject]) {
        if let temp: UIImage = editingInfo[UIImagePickerControllerOriginalImage] as? UIImage {
            cropView.imageToCrop = temp
            picker.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
//        print("In \(__FUNCTION__)")
//        if let image = editingInfo![UIImagePickerControllerOriginalImage] as? UIImage
//        {
//            picker.dismissViewControllerAnimated(true, completion: nil)
//            cropView.imageToCrop = image
//        }
//        //cropView.setNeedsLayout()
//    }
    
//  func imagePickerController(
//    picker: UIImagePickerController,
//    didFinishPickingMediaWithInfo info: [NSObject : AnyObject])
//  {
//    print("In \(__FUNCTION__)")
//    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
//    {
//      picker.dismissViewControllerAnimated(true, completion: nil)
//      cropView.imageToCrop = image
//    }
//    //cropView.setNeedsLayout()
//  }
  
func imagePickerControllerDidCancel(picker: UIImagePickerController)
  {
    print("In \(__FUNCTION__)")
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
}

