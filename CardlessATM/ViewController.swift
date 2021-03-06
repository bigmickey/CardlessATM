//
//  ViewController.swift
//  CardlessATM
//
//  Created by Michael on 20/11/2015.
//  Copyright © 2015 Michael. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // global variable
    let LoginURL = "MVCREST/24HSG/customers"
    
    // variable to keep track of login status
    var loginStatus:Bool = false
    
    @IBOutlet weak var loginNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    @IBAction func loginAction(sender: AnyObject) {
        // Dismiss the keyboard
        self.passwordTextField.resignFirstResponder()
        
        if (self.validateLogin()) {
            self.login()
        } else {
            // no need to handle this since validateLogin has updated the error message
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func storeInSharedInstance(username:String) {
        SessionObject.sharedInstance.loginUser = username
    }
    
    func validateLogin() -> Bool {
        if (loginNameTextField.text != "") {
            if (passwordTextField.text != "") {
                return true
            } else {
                errorMessageLabel.text = "Please enter password"
                return false
            }
            
        } else {
            errorMessageLabel.text = "Please enter login name"
            return false
        }
    }

    func login() {
        
        if let loginName = self.loginNameTextField.text {
            if let password = self.passwordTextField.text {
                // disable the login button

                // This mutu is a "by-pass" user where the app never authenticate with server
                if loginName == "Mutu" {
                    loginSuccessful(loginName)
                }
                
                // construct the URL to get the data
                let baseURL = SessionObject.sharedInstance.baseURL
                let url = baseURL + "/" + LoginURL + "/" + loginName + "/" + password

                get(url)
            }
        }
    }
    
    func loginSuccessful(username: String) {
        // store the username in shared instance
        self.storeInSharedInstance(username)
        
        // store the login status
        self.loginStatus = true
        self.performSegueWithIdentifier("loginSuccessSegue", sender: self)
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
                if let success = parseJSON["result"] as? String {
                    if success == "SUCCESS" {
                        if let username = self.loginNameTextField.text {
                            // login successful
                            self.loginSuccessful(username)

                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.errorMessageLabel.text = "Failed to login"
                        })
                    }
                }
            }
            else {
                // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: \(jsonStr)")
            }
            
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "loginSuccessSegue" {
            return self.loginStatus
        } else {
            return false
        }
    }
    
}

