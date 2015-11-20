//
//  GetCashViewController.swift
//  CardlessATM
//
//  Created by Michael on 20/11/2015.
//  Copyright © 2015 Michael. All rights reserved.
//

import UIKit

class GetCashViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

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
        
        amountPicker.selectRow(4, inComponent: 0, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func GetCurrencySymbol() {
        currencySymbol = "$"
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
    
    // MARK: - Timer
    func startCountDownTimer() {
        // reset the countdown value
        self.countDown = self.countDownInitialValue
        
        // start the timer
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
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
                
                // shown as expired
                countDownLabel.text = "Cash Code Expired"
                
                // re-enable the Amount Picker
                enableAmountPicker()
            }
        }
    }
    
    func generatePINCodes() {
        // get the chosen amount
        let chosenAmount = getAmountFromPicker()
        
        // disable the pickerView
        disableAmountPicker()
        
        // start updating the count down timer
        startCountDownTimer()
        
        print(chosenAmount)
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
