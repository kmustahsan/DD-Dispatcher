//
//  MapViewController.swift
//  DDDispatcher
//
//  Created by kmustahsan on 3/17/17.
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation


class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var startSearchView: UIView!
    @IBOutlet weak var destinationSearchView: UIView!
    @IBOutlet weak var searchTrigger: UIView!

    
    var locationManager = CLLocationManager()
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var startSearchController: UISearchController?
    var destinationSearchController: UISearchController?
    var resultView: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchContainerView.isHidden = true
        mapView.settings.consumesGesturesInView = false
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        self.mapView.bringSubview(toFront: searchTrigger)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(segueTo))
        self.searchTrigger.addGestureRecognizer(gesture)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude:(location?.coordinate.longitude)!, zoom:15)
        mapView.animate(to: camera)
        
        self.locationManager.stopUpdatingLocation()
        
    }
    
    func segueTo() {
        searchTrigger.isHidden = true
        searchContainerView.isHidden = false
        self.mapView.bringSubview(toFront: searchContainerView)
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        
        startSearchController = UISearchController(searchResultsController: resultsViewController)
        destinationSearchController = UISearchController(searchResultsController: resultsViewController)
        
        setupSearchUI(searchController: startSearchController)
        setupSearchUI(searchController: destinationSearchController)
        startSearchView.addSubview((startSearchController?.searchBar)!)
        destinationSearchView.addSubview((destinationSearchController?.searchBar)!)
        
        definesPresentationContext = true
    }
    
    func setupSearchUI(searchController: UISearchController?) {
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.searchBar.showsCancelButton = false
        searchController?.searchBar.tintColor = .white
        searchController?.searchBar.barTintColor = .white
        searchController?.searchBar.backgroundColor = .white
        searchController?.searchBar.setSearchFieldBackgroundImage(UIImage(), for: .normal)
        searchController?.searchBar.setImage(UIImage(), for: .search, state: .normal)
        searchController?.searchBar.frame = CGRect(x: 0, y: 0, width: destinationSearchView.frame.width, height: destinationSearchView.frame.height)
        searchController?.searchBar.sizeToFit()

    }
}

extension MapViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        startSearchController?.isActive = false
        destinationSearchController?.isActive = false
        // Do something with the selected place.
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
  
}



