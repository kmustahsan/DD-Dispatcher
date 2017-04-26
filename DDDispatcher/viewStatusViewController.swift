//
//  viewStatusViewController.swift
//  DDDispatcher
//
//  Created by Neel A on 4/18/17.
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import SideMenuController


class viewStatusViewController: UIViewController, GMSMapViewDelegate, LocationServiceDelegate {

    //driver location
    var driverPosition = [CLLocationCoordinate2D(latitude: 37.227280, longitude: -80.411194)]
    var mapViewG: GMSMapView!
    var path = [CLLocationCoordinate2D(latitude: 37.227262, longitude: -80.411736)]
    var gmPath = GMSMutablePath()
    var markerG : GMSMarker!
    var timer = Timer()
    var poly = GMSPolyline()
    var labelG : UILabel!
    var counter = 1
    var dest = false
    override func viewDidLoad() {
        super.viewDidLoad()
        LocationService.sharedInstance.startUpdatingLocation();
        //rideQueueView()
        //timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(setQueue), userInfo: nil, repeats: false);
        //getPolylineRoute(source: CLLocationCoordinate2D(latitude: 37.227230, longitude: -80.411692), destination: CLLocationCoordinate2D(latitude: 37.228414, longitude: -80.422927))
        let camera = GMSCameraPosition.camera(withLatitude: 37.228414, longitude: -80.422927, zoom: 16)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        view = mapView
        mapViewG = mapView
        
        rideQueueView()
        
        
        
    }
    
    func moveCar()
    {
    
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = poly.path!.coordinate(at: UInt(0))
        marker.title = "Driver"
        marker.snippet = "Current Location"
        let data = UIImagePNGRepresentation(UIImage(named: "carIcon")!)
        let icon = UIImage(data: data!, scale: 5)
        marker.icon = icon!
        marker.map = mapViewG
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        
        //marker.rotation = 0
        markerG = marker
        
        
        
    }
    
    func animateCar()
    {
        
        let path = poly.path!
        //for i in (counter)..<(Int(path.count()))
       // {
            let heading = GMSGeometryHeading(path.coordinate(at: UInt(counter - 1)), path.coordinate(at: UInt(counter)))
            markerG.rotation = heading + 90
            markerG.position = path.coordinate(at: UInt(counter))
        //}
        counter = counter + 1
        if(!dest)
        {
            let bounds = GMSCoordinateBounds(coordinate: path.coordinate(at: UInt(counter)), coordinate: LocationService.sharedInstance.currentLocation!.coordinate)
            let update = GMSCameraUpdate.fit(bounds, withPadding: 50)
            mapViewG.animate(with: update)
        }
        else{
            let bounds = GMSCoordinateBounds(coordinate: path.coordinate(at: UInt(counter)), coordinate: CLLocationCoordinate2D(latitude: 37.226120, longitude: -80.439167))
            let update = GMSCameraUpdate.fit(bounds, withPadding: 70)
            mapViewG.animate(with: update)
        }
        
        if(counter == Int(path.count())-1)
        {
            timer.invalidate()
            if !dest
            {
                animateDest()
            }
            else{
                // create the alert
                let alert = UIAlertController(title: "Ride Complete", message: "Your ride has concluded", preferredStyle: UIAlertControllerStyle.alert)
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: segueHub))

                // show the alert
                self.present(alert, animated: true, completion: nil)
            }
            
            
        }
        
    }
    func segueHub(alert: UIAlertAction!)
    {
        self.performSegue(withIdentifier: "unwindMenuSegue", sender: self)
    }
    
    func animateDest()
    {
        poly.map = nil
        dest = true
        markerG.map = nil
        counter = 1
        getPolylineRoute(source: CLLocationCoordinate2D(latitude: 37.228414, longitude: -80.422927), destination: CLLocationCoordinate2D(latitude: 37.226120, longitude: -80.439167))
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(timerDest), userInfo: nil, repeats: false);
        
        
    }
    
    func timerDest()
    {
        labelG.text = "You are on your way"
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(animateCar), userInfo: nil, repeats: true);
        mapViewG.isMyLocationEnabled = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        LocationService.sharedInstance.stopUpdatingLocation()
    }
    func rideQueueView()
    {
        
        
        let testFrame : CGRect = CGRect(x: 50, y: 100, width: 300, height: 75)
        //let rounded = UIBezierPath(roundedRect: testFrame, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 16, height: 16))
    
        let testView : UIView = UIView(frame: testFrame)
        let label = UILabel(frame: CGRect(x: 150, y: 100, width: 300, height: 21))
        label.textColor = UIColor.white
        label.center = CGPoint(x: 150, y: 35)
        label.textAlignment = .center
        label.text = "You are number 2 in the Queue"
        labelG = label
        testView.layer.cornerRadius = 10
        testView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        testView.alpha=0.5
        testView.addSubview(label)
        self.view.addSubview(testView)
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(setQueue), userInfo: nil, repeats: false);
    }
    
    func setQueue()
    {
        timer.invalidate()
        labelG.text = "Driver is on the way!"
        timer.invalidate()
        getPolylineRoute(source: CLLocationCoordinate2D(latitude: 37.227230, longitude: -80.411692), destination: CLLocationCoordinate2D(latitude: 37.228414, longitude: -80.422927))
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(animateCar), userInfo: nil, repeats: true);
        
    }
    
    func addPathToMap()
    {
        poly.map = nil
        gmPath = GMSMutablePath()
        for loc in path{
            gmPath.add(loc)
        }
        poly = GMSPolyline(path: gmPath)
        poly.strokeWidth = 7.0
        poly.strokeColor = UIColor(colorLiteralRed: 135/255.0, green: 206/255.0, blue: 250/255.0, alpha: 1.0)
        poly.map = mapViewG
        //imageRotatedByDegrees(oldImage: UIImage(named: "carTopDown")!, deg: 90)
        
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getPolylineRoute(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D){
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let url = URL(string: "http://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }else{
                do {
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{
                        
                        let routes = json["routes"] as? [Any]
                        let overview_polyline = routes?[0] as?[String:Any]
                        let leg = overview_polyline?["overview_polyline"] as? [String: Any]
                        let poly = leg?["points"] as? String
                        //let polyString = poly?["points"] as? String
                        //polyString = poly!
                        DispatchQueue.main.async {
                            self.showPath(polyStr:poly!)
                        }
                        
                        
                    }
                    
                }catch{
                    print("error in JSONSerialization")
                }
            }
        })
        task.resume()
        //Call this method to draw path on map
        
    }
    func showPath(polyStr :String){
        let path = GMSPath(fromEncodedPath: polyStr)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 7.0
        polyline.strokeColor = UIColor(colorLiteralRed: 135/255.0, green: 206/255.0, blue: 250/255.0, alpha: 1.0)
        polyline.map = mapViewG // Your map view
        
        poly = polyline
        moveCar()
    }
    
    func resestMapView(camera: GMSCameraPosition)
    {
        
        mapViewG!.animate(to: camera)
    }
    
    /*
    //MARK: - Location delegate
    */
    func tracingLocation(_ currentLocation: CLLocation) {
        
//        let camera = GMSCameraPosition.camera(withLatitude: (currentLocation.coordinate.latitude + driverPosition.latitude / 2), longitude: (currentLocation.coordinate.longitude + driverPosition.longitude / 2), zoom:12)
//        resestMapView(camera: camera)
        //self.mapView.animate(to: camera)
        
        //LocationService.sharedInstance.stopUpdatingLocation()
        
    }
    
    func tracingLocationDidFailWithError(_ error: NSError) {
        print("tracing Location Error : \(error.description)")
    }
    


    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
