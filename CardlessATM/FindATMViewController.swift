//
//  FindATMViewController.swift
//  CardlessATM
//
//  Created by Michael on 20/11/2015.
//  Copyright © 2015 Michael. All rights reserved.
//

import UIKit
import MapKit

class FindATMViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{

    @IBOutlet weak var mapView: MKMapView!
    var coreLocationManager = CLLocationManager()
    var locationManager:LocationManager!
    var userLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        mapView.delegate = self
        
        coreLocationManager.delegate = self
        locationManager = LocationManager.sharedInstance
        
        let authorizationCode = CLLocationManager.authorizationStatus()
        
        if authorizationCode == CLAuthorizationStatus.NotDetermined && coreLocationManager.respondsToSelector("requestAlwaysAuthorization") || coreLocationManager.respondsToSelector("requestWhenInUseAuthorization"){
            
            if NSBundle.mainBundle().objectForInfoDictionaryKey("NSLocationAlwaysUsageDescription") != nil
            {
                coreLocationManager.requestAlwaysAuthorization()
            }
            else
            {
                print("No Description Provided")
            }
        }
        //else
        //{
            getLocation()
        //}
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation
        {
            return nil;
        }
        
        let reuseidentifier = "pin"
        var v = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseidentifier)
        if v == nil
        {
            v = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseidentifier)
            v!.canShowCallout = true
        }
        else
        {
            v!.annotation = annotation
        }
        
        let customPointAnnotation = annotation as! CustomPointAnnotation
        v!.image = UIImage(named:customPointAnnotation.pinCustomImageName)
        
        //v!.sizeThatFits(CGSize(width: 200, height: 100))
        
        configureDetailView(v as MKAnnotationView!, customPointAnnotation: customPointAnnotation)
        
        return v
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print(view.annotation?.title)
        print(view.annotation?.coordinate)
        
        //let userCoord = CLLocationCoordinate2D
        //var pinCoord : CLLocationCoordinate2D = CLLocationCoordinate2DMake(view.annotation?.coordinate.latitude.value, view.coordinate.longitude)
    
        //let userCoord : CLLocation = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let pinCoord : CLLocation = CLLocation(latitude: view.annotation?.coordinate.latitude as CLLocationDegrees!, longitude: view.annotation?.coordinate.longitude as CLLocationDegrees!)
        
        let mapManager : MapManager = MapManager()
        let dest : CLLocationCoordinate2D = CLLocationCoordinate2DMake(pinCoord.coordinate.latitude, pinCoord.coordinate.longitude)
        mapManager.directionsFromCurrentLocation(to: dest) { (route, directionInformation, boundingRegion, error) -> () in
            if let web = self.mapView{
                
                dispatch_async(dispatch_get_main_queue()) {
                    print(route)
                    print(boundingRegion)
                    web.addOverlay(route!)
                    web.setVisibleMapRect(boundingRegion!, animated: true)
                    
                }
                
            }
        }

    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blueColor()
        return renderer
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    /***********************************************************************/
    
    func getLocation()
    {
        locationManager.startUpdatingLocationWithCompletionHandler { (latitude, longitude, status, verboseMessage, error) -> () in
            self.displayLocation(CLLocation(latitude: latitude, longitude: longitude)
            )
        }
    }
    
    func displayLocation(location:CLLocation)
    {
        userLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude), span: MKCoordinateSpanMake(0.019, 0.019)), animated: true)
        self.mapView.showsScale = true
        self.mapView.showsCompass = true
        self.mapView.showsTraffic = true
        self.mapView.zoomEnabled = true
        self.mapView.showsUserLocation = true
        
        displayATMs()
        
        /*locationManager.reverseGeocodeLocationWithCoordinates(location, onReverseGeocodingCompletionHandler:  { (reverseGecodeInfo, placemark, error) -> Void in
            print(reverseGecodeInfo)
            
            let address = reverseGecodeInfo?.objectForKey("country") as! String
            //self.locationInfo.text = address
            print(address)
        })*/
        
    }
    
    func displayATMs()
    {
        
        let path = NSBundle.mainBundle().pathForResource("DummyJSON", ofType: "json") as String!
        let jsonData = NSData(contentsOfFile: path) as NSData!
        
        var annotationView:MKPinAnnotationView!
        var pointAnnotation:CustomPointAnnotation!
        
        do
        {
            let jsonArray = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! NSArray
            
            for (var iCountry = 0; iCountry < jsonArray.count; iCountry++)
            {
                let jsonDictionary = jsonArray[0] as! NSDictionary
                //let Country = jsonDictionary["Country"]
                let ATMs = jsonDictionary["ATMs"] as! NSArray
                
                for (var iATM = 0; iATM < ATMs.count; iATM++)
                {
                    let atmDictionary = ATMs[iATM] as! NSDictionary
                    let locationPinCoord = CLLocationCoordinate2D(latitude: atmDictionary["latitude"] as! Double, longitude: atmDictionary["longitude"]  as! Double)
                    
                    pointAnnotation = CustomPointAnnotation()
                    pointAnnotation.coordinate = locationPinCoord
                    
                    pointAnnotation.pinCustomImageName = getStatusImage((atmDictionary["status"] as! Int))
                    pointAnnotation.title = atmDictionary["location"] as? String
                    pointAnnotation.has10notes = atmDictionary["has10"] as? Bool
                    pointAnnotation.has20notes = atmDictionary["has20"] as? Bool
                    pointAnnotation.has50notes = atmDictionary["has50"] as? Bool
                    pointAnnotation.has100notes = atmDictionary["has100"] as? Bool
                    annotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "pin")
                    annotationView.animatesDrop = true
                    
                    self.mapView.addAnnotation(annotationView.annotation!)
                    
                }
                
            }
        }
        catch
        {
            
        }
        
    }
    
    func getStatusImage(status: Int) -> String
    {
        switch status
        {
        case 1: return "green"
        case 2: return "amber"
        case 3: return "red"
        default: return ""
        }
    }
    
    func configureDetailView(annotationView: MKAnnotationView, customPointAnnotation: CustomPointAnnotation)
    {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        container.backgroundColor = UIColor.blackColor()
        
        let note10View = UIImageView (frame: CGRect(x: 0, y: -15, width: 25, height: 15))
        if customPointAnnotation.has10notes != nil && customPointAnnotation.has10notes == true
        {
            note10View.image = UIImage(named: "10green")
        }
        else
        {
            note10View.image = UIImage(named: "10gray")
        }
        container.addSubview(note10View)
        
        let note20View = UIImageView (frame: CGRect(x: 26, y: -15, width: 25, height: 15))
        if customPointAnnotation.has20notes != nil  && customPointAnnotation.has20notes == true
        {
            note20View.image = UIImage(named: "20green")
        }
        else
        {
            note20View.image = UIImage(named: "20gray")
        }
        container.addSubview(note20View)
        
        let note50View = UIImageView (frame: CGRect(x: 51, y: -15, width: 25, height: 15))
        if customPointAnnotation.has50notes != nil  && customPointAnnotation.has50notes == true
        {
            note50View.image = UIImage(named: "50green")
        }
        else
        {
            note50View.image = UIImage(named: "50gray")
        }
        container.addSubview(note50View)
        
        let note100View = UIImageView (frame: CGRect(x: 76, y: -15, width: 25, height: 15))
        if customPointAnnotation.has100notes != nil  && customPointAnnotation.has100notes == true
        {
            note100View.image = UIImage(named: "100green")
        }
        else
        {
            note100View.image = UIImage(named: "100gray")
        }
        container.addSubview(note100View)

        annotationView.detailCalloutAccessoryView = container
        annotationView.sizeToFit()
    }
    
    
    func getJSONDictionary(data : NSData?) -> NSDictionary?
    {
        
        var jsonResult : NSDictionary?
        
        //            var error:NSError?
        do
        {
            if data == nil
            {
                print("data empty")
                return nil
            }
            
            jsonResult = try NSJSONSerialization.JSONObjectWithData(data as NSData!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
            
            if jsonResult != nil
            {
                print("dictionary found")
            }
            else
            {
                print("empty")
            }
            
        }
        catch
        {
            print("error")
        }
        
        return jsonResult
    }
    
    func getJSONArray(data : NSData?) -> NSArray?
    {
        
        var jsonResult : NSArray?
        
        //            var error:NSError?
        do
        {
            if data != nil
            {
                print("data empty")
                return nil
            }
            
            jsonResult = try NSJSONSerialization.JSONObjectWithData(data as NSData!, options: NSJSONReadingOptions.MutableContainers) as? NSArray
            
            if jsonResult != nil
            {
                print("array found")
            }
            else
            {
                print("empty")
            }
            
        }
        catch
        {
            print("error")
        }
        
        return jsonResult
    }
    
    //let url: String = "http://10.0.89.86/MVCREST/24HSG/customers/{'userid':'Todd','password':'000711'}"
    //let url: String = "http://172.16.16.149/MVCREST/24HSG/customers/Todd1/00011"
    //let url : String = "http://213.157.170.77/NL/commonapi/locations"
    
    func getJSONViaAPI(url : String) -> NSDictionary?
    {

        let request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        request.HTTPMethod = "GET"
        
        var jsonResult : NSDictionary?
        
        print(request)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler: {  (response:NSURLResponse?,data: NSData?, error: NSError?) -> Void in
            print(response)
            if error != nil
            {
                print(error)
            }
            print(data)
            if data != nil
            {
                 jsonResult = self.getJSONDictionary(data)
                
                if jsonResult != nil
                {
                    print(jsonResult)
                }
                else
                {
                    print(url + " : empty data from JSON")
                }
            }
            else
            {
                print("data empty")
                
            }
        })
        return jsonResult
    }
    

}
