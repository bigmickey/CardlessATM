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
    let LoginURL = "http://172.16.16.149/MVCREST/24HSG/customers"
    
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
                let url = LoginURL + "/" + loginName + "/" + password

                get(url)
            }
        }
    }
    
    func get(url : String) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "GET"
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue()) { (response:NSURLResponse?, data: NSData?, error:NSError?) -> Void in
            print("\(data?.length)")
            
            let json: NSDictionary?
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
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
                        self.loginStatus = true
                        print("Result: \(success)")
                        self.performSegueWithIdentifier("loginSuccessSegue", sender: self)
                    } else {
                        self.errorMessageLabel.text = "Failed to login"
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

