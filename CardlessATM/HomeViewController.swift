//
//  HomeViewController.swift
//  CardlessATM
//
//  Created by Michael on 20/11/2015.
//  Copyright © 2015 Michael. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    // global variable
    let GetBalanceURL = "MVCREST/24HSG/bankaccount"
    let CurrentBalancePrefix = "Current Balance: "
    let AvailableBalancePrefix = "Available Funds: "
    
    @IBOutlet weak var currentBalanceLabel: UILabel!
    @IBOutlet weak var availableBalanceLabel: UILabel!
    
    @IBAction func findATM(sender: AnyObject) {
        self.tabBarController?.selectedIndex = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        getBalance()
        
        // force refresh
        forceRefreshTabBarItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // this is an item to be fixed
    func forceRefreshTabBarItem() {
        self.tabBarController?.selectedIndex = 1
        self.tabBarController?.selectedIndex = 2
        self.tabBarController?.selectedIndex = 0
    }
    
    func getBalance() {
        // retrieve the login username
        if let loginUser = SessionObject.sharedInstance.loginUser {
            let baseURL = SessionObject.sharedInstance.baseURL
            let url = baseURL + "/" + GetBalanceURL + "/" + loginUser
            
            self.get(url)
        }
    }
    
    func get(url : String) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "GET"
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue()) { (response:NSURLResponse?, data: NSData?, error:NSError?) -> Void in
            print("\(data?.length)")
            
            let json: NSDictionary?
            do {
                if let safeData = data {
                    json = try NSJSONSerialization.JSONObjectWithData(safeData, options: .MutableLeaves) as? NSDictionary
                } else {
                    // todo: handle this as an error because data is nil
                    json = nil
                }
            } catch let dataError {
                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                print(dataError)
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: '\(jsonStr)'")
                // return or throw?
                return
            }
            
            // The JSONObjectWithData constructor didn't return an error. But, we should still
            // check and make sure that json has a value using optional binding.
            if let parseJSON = json {
                // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                if let currentBalance = parseJSON["Current_balance"] as? Float {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.currentBalanceLabel.text = self.CurrentBalancePrefix + "$\(currentBalance)"
                    })
                }
                
                if let availableBalance = parseJSON["Available_balance"] as? Float {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.availableBalanceLabel.text = self.AvailableBalancePrefix + "$\(availableBalance)"
                    })
                }
            }
            else {
                // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: \(jsonStr)")
            }
            
        }
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
