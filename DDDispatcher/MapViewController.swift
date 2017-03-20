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
    var placesClient: GMSPlacesClient!
    var currentPlace: GMSPlace!
    var destinationPlace: GMSPlace!

    
    var locationManager = CLLocationManager()
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var startSearchController: UISearchController?
    var destinationSearchController: UISearchController?
    var resultView: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        findCurrentPlace()
        searchContainerView.isHidden = true
        mapView.settings.consumesGesturesInView = false
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        self.mapView.bringSubview(toFront: searchTrigger)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(segueTo))
        self.searchTrigger.addGestureRecognizer(gesture)
        
    }
    
    func findCurrentPlace() {
        placesClient = GMSPlacesClient.shared()
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                let likelihood = placeLikelihoodList.likelihoods[0]
                let place = likelihood.place
                print("Current Place name \(place.name) at likelihood \(likelihood.likelihood)")
                print("Current Place address \(place.formattedAddress)")
                print("Current Place attributions \(place.attributions)")
                print("Current PlaceID \(place.placeID)")
                self.currentPlace = place
                self.setMap()
            }
        })
        
    }
    func setMap() {
        let camera = GMSCameraPosition.camera(withLatitude: (currentPlace.coordinate.latitude), longitude:(currentPlace.coordinate.longitude), zoom:15)
        mapView.animate(to: camera)
    }

    func segueTo() {
        searchTrigger.isHidden = true
        searchContainerView.isHidden = false
        self.mapView.bringSubview(toFront: searchContainerView)
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        //filter
        
        let filter = GMSAutocompleteFilter()
        filter.type = GMSPlacesAutocompleteTypeFilter.address
        
        let northEast = CLLocationCoordinate2DMake(currentPlace.coordinate.latitude + 0.15, currentPlace.coordinate.longitude + 0.15)
        let southWest = CLLocationCoordinate2DMake(currentPlace.coordinate.latitude - 0.15, currentPlace.coordinate.longitude - 0.15)
        let userBound = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)

        
        resultsViewController?.autocompleteFilter = filter
        resultsViewController?.autocompleteBounds = userBound
        
        startSearchController = UISearchController(searchResultsController: resultsViewController)
        destinationSearchController = UISearchController(searchResultsController: resultsViewController)
        
        setupSearchUI(searchController: startSearchController)
        setupSearchUI(searchController: destinationSearchController)
        startSearchController?.searchBar.text = currentPlace.name
        
        startSearchView.addSubview((startSearchController?.searchBar)!)
        destinationSearchView.addSubview((destinationSearchController?.searchBar)!)
        destinationSearchController?.searchBar.becomeFirstResponder()

        definesPresentationContext = true
    }
    
    func setupSearchUI(searchController: UISearchController?) {
        searchController?.searchBar.setImage(UIImage(named: "cancelButton.png"), for: UISearchBarIcon.clear, state: .highlighted)
        searchController?.searchBar.setImage(UIImage(named: "cancelButton.png"), for: UISearchBarIcon.clear, state: .normal)
        
        searchController?.searchBar.setShowsCancelButton(false, animated: true)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.searchBar.tintColor = .white
        searchController?.searchBar.barTintColor = .white
        searchController?.searchBar.backgroundColor = .white
        searchController?.searchBar.setImage(UIImage(), for: .search, state: .normal)
        searchController?.searchBar.frame = CGRect(x: 0, y: 0, width: destinationSearchView.frame.width, height: destinationSearchView.frame.height)
        searchController?.searchBar.sizeToFit()

    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "confirmationSegue" {
            let rideConfimationViewController = segue.destination as! RideConfirmationViewController
            rideConfimationViewController.startingLocation = currentPlace
            rideConfimationViewController.destinationLocation = destinationPlace
        }
    }
}

extension MapViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        // Do something with the selected place.
        if destinationSearchController?.isActive == true {
            
            destinationPlace = place
            performSegue(withIdentifier: "confirmationSegue", sender: nil)
        }
        
        if startSearchController?.isActive == true {
            startSearchController?.searchBar.text = place.name
        }
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



