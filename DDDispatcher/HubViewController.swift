//
//  HubViewController.swift
//  DDDispatcher
//
//  Created by kmustahsan on 2/18/17.
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//

import UIKit
import Firebase
import SideMenuController
import GoogleMaps
import GooglePlaces
import CoreLocation
@objc
// Define HomeViewControllerDelegate as a protocol with two optional methods
protocol HubViewControllerDelegate {
    
    @objc optional func toggleMenuView()
    @objc optional func collapseMenuView()
}

class HubViewController: UIViewController, UIScrollViewDelegate, SideMenuControllerDelegate,
                        GMSMapViewDelegate {
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var startSearchView: UIView!
    @IBOutlet weak var destinationSearchView: UIView!
    @IBOutlet weak var searchTrigger: UIView!
    @IBOutlet weak var infoView: UIView!
    var placesClient: GMSPlacesClient!
    var currentPlace: GMSPlace!
    var destinationPlace: GMSPlace!
    var locationManager = CLLocationManager()
    var resultsViewController: GMSAutocompleteResultsViewController?
    var startSearchController: UISearchController?
    var destinationSearchController: UISearchController?
    var resultView: UITextView?
    
    @IBOutlet weak var scrollMenu: UIScrollView!
    @IBOutlet weak var eventDescription: UIView!
    @IBOutlet weak var noEventsLabel: UILabel!
    @IBOutlet weak var eventOverViewTextView: UITextView!
    
    // Dictionary containing active group info.
    var dict_avtiveGroups = [String: AnyObject]()
    // Array storing active group names.t
    var activeGroupNames = [String]()
    var activeGroupLogosUrl = [String]()
    var activeGroupImages = [UIImage]()
    // Array storing event information.
    var eventInformation = [String: String]()
    // Scroll menu properties
    let kScrollMenuHeight: CGFloat = 90.0
    var selectedGroupName = ""
    var previousButton = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    let backgroundColorToUse = UIColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 1.0)
    var delegate: HubViewControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        checkLocationAuthorizationStatus()
        super.viewWillAppear(true)
        if (Cache.sharedInstance.keyAlreadyExists(key: "Events")) {
            noEventsLabel.isHidden = true
            let eventInfo = Cache.sharedInstance.getValueForKey(key: "Events") as! [String : [String: Any]]
            let groupInfo = Cache.sharedInstance.getValueForKey(key: "Groups") as! [String : [String: Any]]
            if eventInfo.count > 0 {
                for index in 0..<eventInfo.count {
                    if (eventInfo.count != activeGroupNames.count) {
                        let keys = Array(eventInfo.keys)
                        activeGroupNames.append(eventInfo[keys[index]]?["event"] as! String)
                        let gid = eventInfo[keys[index]]?["gid"] as! String
                        activeGroupLogosUrl.append(groupInfo[gid]?["avatar"] as! String)
                        activeGroupImages.append(UIImage(named: "eventHub.png")!)
                        let eventName = eventInfo[keys[index]]?["event"] as! String
                        let groupName = eventInfo[keys[index]]?["group"] as! String
                        let startDate = eventInfo[keys[index]]?["start"] as! String
                        let endDate = eventInfo[keys[index]]?["end"] as! String
                        let description = eventInfo[keys[index]]?["description"] as! String
                        let overview = createOverview(eventName: eventName , groupName: groupName, startDate: startDate,
                                       endDate: endDate, description: description)
                        eventInformation[eventName] = overview
                    }
                }
                setupScrollMenu()
                loadGroupImages()
            }
        } else {
            noEventsLabel.isHidden = false
        }
    }
    
    func loadGroupImages() {
        for index in 0..<activeGroupLogosUrl.count {
            let url = NSURL(string: activeGroupLogosUrl[index])
            let task = URLSession.shared.dataTask(with: url as! URL, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error ?? "Session error")
                    return
                }
                DispatchQueue.main.async {
                    self.activeGroupImages[index] = UIImage(data: data!)!
                    self.setupScrollMenu()
                }
            })
           task.resume()
        }
        
    }
    
    func createOverview(eventName: String, groupName: String, startDate: String, endDate: String, description: String) -> String {
        //var overviewResult = eventName + "\n" + groupName + "\n" + startDate + "\n" + endDate + "\n" + descreiption
        var overviewResult = " \(eventName) \n Hosted By: \(groupName)  \n Beginning: \(startDate) \n Ending: \(endDate) \n Description: \(description)"
        return overviewResult
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        findCurrentPlace()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(),
                                                                    for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        scrollMenu.layer.masksToBounds = false
        scrollMenu.layer.shadowColor = UIColor.black.cgColor
        scrollMenu.layer.shadowOffset = CGSize(width: 0, height: 5)
        scrollMenu.layer.shadowOpacity = 0.4
        scrollMenu.layer.shadowRadius = 2
        eventDescription.layer.masksToBounds = false
        eventDescription.layer.shadowColor = UIColor.black.cgColor
        eventDescription.layer.shadowOffset = CGSize(width: 0, height: 5)
        eventDescription.layer.shadowOpacity = 0.4
        eventDescription.layer.shadowRadius = 2
        
        
        
        searchContainerView.isHidden = true
        mapView.settings.consumesGesturesInView = false
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        self.mapView.bringSubview(toFront: infoView)
        eventDescription.isHidden = true
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
                DispatchQueue.main.async {
                    self.currentPlace = place
                    self.setMap()
                }
               
            }
        })
    }
    func setMap() {
        let camera = GMSCameraPosition.camera(withLatitude: (currentPlace.coordinate.latitude), longitude:(currentPlace.coordinate.longitude), zoom:15)
        mapView.animate(to: camera)
    }
    
    func segueTo() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(canceltapped))
        navigationItem.leftBarButtonItem?.tintColor = .white
        infoView.isHidden = true
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
        startSearchController?.searchBar.frame = CGRect(x: 0, y: 0, width: startSearchView.frame.width, height: startSearchView.frame.height)
        startSearchController?.searchBar.text = currentPlace.name
        startSearchView.addSubview((startSearchController?.searchBar)!)

        setupSearchUI(searchController: destinationSearchController)
        destinationSearchController?.searchBar.frame = CGRect(x: 0, y: 0, width: destinationSearchView.frame.width, height: destinationSearchView.frame.height)
        destinationSearchView.addSubview((destinationSearchController?.searchBar)!)
        destinationSearchController?.searchBar.becomeFirstResponder()
        definesPresentationContext = true
    }
    
    func setupSearchUI(searchController: UISearchController?) {
        searchController?.searchBar.setImage(UIImage(named: "cancelButton.png"), for: UISearchBarIcon.clear, state: .highlighted)
        searchController?.searchBar.setImage(UIImage(named: "cancelButton.png"), for: UISearchBarIcon.clear, state: .normal)
        searchController?.searchBar.setShowsCancelButton(false, animated: false)
        searchController?.searchBar.tintColor = .white
        searchController?.searchBar.barTintColor = .white
        searchController?.searchBar.backgroundColor = .white
        searchController?.searchBar.setImage(UIImage(), for: .search, state: .normal)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.searchBar.sizeToFit()
        searchController?.searchBar.clipsToBounds = true
        searchController?.extendedLayoutIncludesOpaqueBars = true
        searchController?.edgesForExtendedLayout = .bottom
        searchController?.hidesNavigationBarDuringPresentation = false
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "confirmationSegue" {
            let rideConfimationViewController = segue.destination as! RideConfirmationViewController
            rideConfimationViewController.startingLocation = currentPlace
            rideConfimationViewController.destinationLocation = destinationPlace
        }
    }
    
    func canceltapped() {
        navigationItem.leftBarButtonItem = nil
        destinationSearchController?.searchBar.resignFirstResponder()
        destinationSearchController?.searchBar.isHidden = true
        destinationSearchView.isHidden = true
        searchContainerView.isHidden = true
        infoView.isHidden = false
        self.mapView.bringSubview(toFront: infoView)
        infoView.becomeFirstResponder()
    }
    
    @IBAction func requestToEvent(_ sender: Any) {
    }
    
    @IBAction func requestFromEvent(_ sender: Any) {
        
    }
    
    
//SCROLL
    func setupScrollMenu() {
        //set background colors
        //self.view.backgroundColor = UIColor.white
        
        //Set background color for the scroll menu so check circular image
        //scrollMenu.backgroundColor = UIColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 1.0)
        
        /***********************************************************************
         * Instantiate and setup the buttons for the horizontally scrollable menu
         ***********************************************************************/
        
        // Instantiate a mutable array to hold the menu buttons to be created
        var listOfMenuButtons = [UIButton]()
        
        for i in 0 ..< activeGroupNames.count {
            
            // Instantiate a button to be placed within the horizontally scrollable menu
            let scrollMenuButton = UIButton(type: UIButtonType.custom)
            
            // Todo: Obtain the group's logo image.
            var groupLogo = (activeGroupImages[i])
            groupLogo = resizeImage(image: groupLogo, newHeight: 30)!
            
            // Set the button frame at origin at (x, y) = (0, 0) with
            // button width  = auto logo image width + 10 points padding for each side
            // button height = kScrollMenuHeight points
            scrollMenuButton.frame = CGRect(x: 0.0, y: 0.0, width: groupLogo.size.width + 20.0, height:kScrollMenuHeight)
            //scrollMenuButton.layer.cornerRadius = 0.5 * scrollMenuButton.bounds.width
            // Test:
            //crollMenuButton.backgroundColor = UIColor.white
            
            // Set the button image to be the group's logo
            scrollMenuButton.setImage(groupLogo, for: UIControlState())
            
            // Obtain the title (i.e., auto manufacturer name) to be displayed on the button
            let buttonTitle = activeGroupNames[i]
            
            // The button width and height in points will depend on its font style and size
            let buttonTitleFont = UIFont(name: "Helvetica", size: 12.0)
            
            // Set the font of the button title label text
            scrollMenuButton.titleLabel?.font = buttonTitleFont
            
            // Compute the size of the button title in points
            let buttonTitleSize: CGSize = (buttonTitle as NSString).size(attributes: [NSFontAttributeName:buttonTitleFont!])
            
            let titleTextWidth = buttonTitleSize.width
            let logoImageWidth = groupLogo.size.width
            
            var buttonWidth: CGFloat = 0.0
            
            // Set the button width to be the largest width + 20 pixels of padding
            if titleTextWidth > logoImageWidth {
                buttonWidth = titleTextWidth + 20.0
            } else {
                buttonWidth = logoImageWidth + 20.0
            }
            
            // Set the button frame with width=buttonWidth height=kScrollMenuHeight points with origin at (x, y) = (0, 0)
            scrollMenuButton.frame = CGRect(x: 0.0, y: 0.0, width: buttonWidth, height: kScrollMenuHeight)
            
            // Set the button title to the automobile manufacturer's name
            scrollMenuButton.setTitle(activeGroupNames[i], for: UIControlState())
            
            // Set the button title color to black when the button is not selected
            scrollMenuButton.setTitleColor(UIColor.black, for: UIControlState())
            
            // Set the button title color to red when the button is selected
            
            // Specify the Inset values for top, left, bottom, and right edges for the title
            scrollMenuButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, -groupLogo.size.width, -(groupLogo.size.height + 5), 0.0)
            
            // Specify the Inset values for top, left, bottom, and right edges for the auto logo image
            scrollMenuButton.imageEdgeInsets = UIEdgeInsetsMake(-(buttonTitleSize.height + 5), 0.0, 0.0, -buttonTitleSize.width)
            
            // Set the button to invoke the buttonPressed: method when the user taps it
            scrollMenuButton.addTarget(self, action: #selector(HubViewController.buttonPressed(_:)), for: .touchUpInside)
            
            // Add the constructed button to the list of buttons
            listOfMenuButtons.append(scrollMenuButton)
            sideMenuController?.delegate = self
            
        }
        /*********************************************************************************************
         * Compute the sumOfButtonWidths = sum of the widths of all buttons to be displayed in the menu
         *********************************************************************************************/
        
        var sumOfButtonWidths: CGFloat = 0.0
        
        for j in 0 ..< listOfMenuButtons.count {
            
            // Obtain the obj ref to the jth button in the listOfMenuButtons array
            let button: UIButton = listOfMenuButtons[j]
            
            // Set the button's frame to buttonRect
            var buttonRect: CGRect = button.frame
            
            // Set the buttonRect's x coordinate value to sumOfButtonWidths
            buttonRect.origin.x = sumOfButtonWidths
            
            // Set the button's frame to the newly specified buttonRect
            button.frame = buttonRect
            
            // Add the button to the horizontally scrollable menu
            scrollMenu.addSubview(button)
            
            // Add the width of the button to the total width
            sumOfButtonWidths += button.frame.size.width
        }
        
        // Horizontally scrollable menu's content width size = the sum of the widths of all of the buttons
        // Horizontally scrollable menu's content height size = kScrollMenuHeight points
        scrollMenu.contentSize = CGSize(width: sumOfButtonWidths, height: kScrollMenuHeight)
        
        /******************************************************************************
         * Event Information
         *******************************************************************************/
        
        eventDescription.isHidden = true
    }
    
    
    //resize group logo image
    func resizeImage(image: UIImage, newHeight: CGFloat) -> UIImage? {
        
        let scale = newHeight / image.size.height
        let newWidth = image.size.width * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    /*
     -----------------------------------
     MARK: - Method to Handle Button Tap
     -----------------------------------
     */
    // This method is invoked when the user taps a button in the horizontally scrollable menu
    func buttonPressed(_ sender: UIButton) {
        
        let selectedButton: UIButton = sender
        
        // Indicate that the button is selected
        selectedButton.isSelected = true
        
        if previousButton != selectedButton {
            // Selecting the selected button again should not change its title color
            previousButton.isSelected = false
        }
        
        
        previousButton = selectedButton
        
        selectedGroupName = selectedButton.title(for: UIControlState())!
        print(selectedGroupName)
        
        /******************************************************************
         * show event information
         *******************************************************************/
        
        
        eventDescription.isHidden = false
        if eventInformation.keys.contains(selectedGroupName) {
            eventOverViewTextView.text = eventInformation[selectedGroupName]
        }
    
        
    }
    
    /*
     ----------------------
     MARK: - Buttons Tapped
     ----------------------
     */
    @IBAction func menuButtonTapped(_ sender: UIBarButtonItem) {
        
        /*
         Tell the delegate (ContainerViewController) to execute its implementation of the
         HomeViewControllerDelegate protocol method toggleMenuView()
         */
        delegate?.toggleMenuView!()
    }
    
    /*
     -----------------------------------
     MARK: - Scroll View Delegate Method
     -----------------------------------
     */
    
    // Tells the delegate when the user scrolls the content view within the receiver
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //disable horizontal scrolling
        if scrollView.contentOffset.y != 0 {
            scrollView.contentOffset.y = 0
        }
    }
    
    func sideMenuControllerDidHide(_ sideMenuController: SideMenuController) {
        print(#function)
    }
    
    func sideMenuControllerDidReveal(_ sideMenuController: SideMenuController) {
        print(#function)
    }
    
    @IBAction func unwindToHub(segue: UIStoryboardSegue) {}
}

extension HubViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        // Do something with the selected place.
         navigationItem.leftBarButtonItem = nil
        if destinationSearchController?.isActive == true {
            navigationItem.leftBarButtonItem?.isEnabled = false
            navigationItem.leftBarButtonItem = nil
            destinationPlace = place
            //send place.formattedAddress
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
        navigationItem.leftBarButtonItem = nil
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        navigationItem.leftBarButtonItem = nil
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        navigationItem.leftBarButtonItem = nil
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}


//check if this actually works on the device. otherwise fix, Woo
extension HubViewController: CLLocationManagerDelegate {
    func checkLocationAuthorizationStatus() {
        // MARK: TODO: Need to test if they don't allow authorization
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.delegate = self
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            findCurrentPlace()
        } else {
            checkLocationAuthorizationStatus()
            
        }
        
    }
}



