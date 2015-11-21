//
//  GetCashViewController.swift
//  CardlessATM
//
//  Created by Michael on 20/11/2015.
//  Copyright © 2015 Michael. All rights reserved.
//

import UIKit

class GetCashViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    // url to get the PIN Codes
    let getPINCodesURL = "MVCREST/24HSG/cashcode"
    let userAndAmountDeliminator = ","
    
    // list of value for the amount picker
    let amountList = ["10", "20", "30", "40", "50", "60", "70", "80", "90",
    "100", "120", "140", "160", "180", "200",
    "250", "300", "350", "400", "450", "500"]
    
    // Amount Picker
    var currencySymbol:String!
    @IBOutlet weak var amountPicker: UIPickerView!
    
    // Generate PIN Codes
    @IBOutlet weak var generatePINCodesButton: UIButton!
    @IBAction func generatePINCodesAction(sender: AnyObject) {
        generatePINCodes()
    }
    
    // Cash Code
    @IBOutlet weak var cashCodeLabel: UILabel!
    
    // Label to display OTP Code has been sent via SMS
    @IBOutlet weak var sentSMSMessageLabel: UILabel!
    
    // The label for "Codes are valid for:"
    @IBOutlet weak var codesValidLabel: UILabel!
    
    // Count Down Timer
    @IBOutlet weak var countDownLabel: UILabel!
    // count down from 30 minutes, which is 30 * 60 seconds
    let countDownInitialValue:NSTimeInterval = 1800
    
    // timer
    var timer:NSTimer? = nil
    var countDown:NSTimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        amountPicker.dataSource = self
        amountPicker.delegate = self
        
        GetCurrencySymbol()
        
        // Default to $50
        amountPicker.selectRow(4, inComponent: 0, animated: true)
        
        // hide SMS message
        hideSentSMSMessage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func GetCurrencySymbol() {
        currencySymbol = "$"
    }
    
    // Mark: share detector
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        // Generate the Codes by Shaking the phone
        if motion == .MotionShake {
            generatePINCodes()
        }
    }
    
    // Mark: delegates
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return amountList.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencySymbol + amountList[row]
    }
    
    // MARK: - Amount Picker
    
    func getAmountFromPicker() -> String {
        // get the current Index
        let selectedIndex = self.amountPicker.selectedRowInComponent(0)
        return self.amountList[selectedIndex]
    }
    
    func disableAmountPicker() {
        self.amountPicker.userInteractionEnabled = false
        self.amountPicker.alpha = 0.6
        
        // disable the button
        self.generatePINCodesButton.enabled = false
    }
    
    func enableAmountPicker() {
        self.amountPicker.userInteractionEnabled = true
        self.amountPicker.alpha = 1.0
        
        // enable the button
        self.generatePINCodesButton.enabled = true
    }
    
    // MARK: - SMS

    func displaySentSMSMessage() {
        self.sentSMSMessageLabel.hidden = false
        self.codesValidLabel.hidden = false
        self.countDownLabel.hidden = false
    }
    
    func hideSentSMSMessage() {
        self.sentSMSMessageLabel.hidden = true
        self.codesValidLabel.hidden = true
        self.countDownLabel.hidden = true
    }
    
    // MARK: - Timer
    func startCountDownTimer() {
        // reset the countdown value
        self.countDown = self.countDownInitialValue
        
        // initial update
        self.update()
        
        // start the timer
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
    }
    
    // MARK: - Cash Code Expired
    func displayCashCodeExpired() {
        // shown as expired
        countDownLabel.text = "Cash Code Expired"
        
        self.sentSMSMessageLabel.hidden = true
        self.codesValidLabel.hidden = true

    }
    
    func update() {
        let dateComponentsFormatter = NSDateComponentsFormatter()
        if let timeString = dateComponentsFormatter.stringFromTimeInterval(self.countDown) {

            // update the counter
            if countDown > 0 {
                var remainingTimeText = ""
                if countDown > 60 {
                     remainingTimeText = "\(timeString) Minutes"
                } else {
                    remainingTimeText = "\(timeString) Seconds"
                }
                countDownLabel.text = remainingTimeText
                
                // update the countDown
                self.countDown--
            } else {
                // stop the timer
                self.timer?.invalidate()
                
                // re-enable the Amount Picker
                enableAmountPicker()
                
                // show that cash code expired
                dispatch_async(dispatch_get_main_queue(), {
                    self.displayCashCodeExpired()
                })
            }
        }
    }
    
    func generatePINCodes() {
        // get the chosen amount
        let chosenAmount = getAmountFromPicker()
        
        // disable the pickerView
        disableAmountPicker()
        
        // call server to get the PIN Codes
        getPINCodes()
    }

    func getPINCodes() {
        if let loginUser = SessionObject.sharedInstance.loginUser {
            let baseURL = SessionObject.sharedInstance.baseURL
            let url = baseURL + "/" + getPINCodesURL + "/" + loginUser + userAndAmountDeliminator + getAmountFromPicker()
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
                // Get status
                if let status = parseJSON["status"] as? String {
                    if status.containsString("PREVIOUS") {
                        self.cashCodeLabel.text = "Previous Code Exist"
                    }
                }
                
                // Get the 8 Digit Cash Code
                if let cashCode = parseJSON["Eight_digit_pin"] as? Int {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.cashCodeLabel.text = "\(cashCode)"
                        
                        // display SentSMSMessage
                        self.displaySentSMSMessage()
                        
                        // start updating the count down timer
                        self.startCountDownTimer()
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

}
