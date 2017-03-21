//
//  SelectDriverTableViewController.swift
//  DDDispatcher
//
//  Created by Yoonju Lee on 3/20/17.
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//

import UIKit

class SelectDriverTableViewController: UITableViewController {

    var groupMembers = ["Pikachu Raichu", "Yoonju Lee", "Woo Jin Kye"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return groupMembers.count
    }

    //-------------------------------------
    // Prepare and Return a Table View Cell
    //-------------------------------------
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityTableView", for: indexPath) as UITableViewCell
        
        let sectionNumber = (indexPath as NSIndexPath).section
        let rowNumber = (indexPath as NSIndexPath).row
        
        // Obtain the name of the given country
        let givenCountryName = countryNames[sectionNumber]
        
        /*
         Note that city names must not be sorted. The order shows how favorite the city is.
         The higher the order the more favorite the city is. The user specifies the ordering
         in the Edit mode by moving a row from one location to another for the same country.
         */
        
        // Obtain the list of cities in the given country as AnyObject
        let cities: AnyObject? = applicationDelegate.dict_Country_Cities[givenCountryName] as AnyObject
        
        // Typecast the AnyObject to Swift array of String objects
        var citiesOfGivenCountry = cities! as! [String]
        
        // Set the cell title to be the city name
        cell.textLabel!.text = citiesOfGivenCountry[rowNumber]
        
        cell.imageView!.image = UIImage(named: "FavoriteIcon.png")
        
        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
