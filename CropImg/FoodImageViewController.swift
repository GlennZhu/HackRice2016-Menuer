//
//  FoodImageViewController.swift
//  CropImg
//
//  Created by Ziliang Zhu on 1/16/16.
//  Copyright © 2016 Duncan Champney. All rights reserved.
//

import UIKit

class FoodImageViewController: UIViewController {
    
    @IBAction func goBackBtn(sender: UIBarButtonItem) {
        print("go back button")
        self.performSegueWithIdentifier("UnwindSegue", sender: self)
    }

    @IBOutlet weak var foodImage: UIImageView!
    
    var foodImageText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchImage(foodImageText)
    }
    
    
    
    private func fetchImage(urlInput : String) {
        let qos = QOS_CLASS_USER_INITIATED
        
        dispatch_async(dispatch_get_global_queue(qos, 0), { () -> Void in
            if let url = NSURL(string: urlInput), data = NSData(contentsOfURL: url) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.foodImage.image = UIImage(data: data)
                })
            }
        })
        
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
