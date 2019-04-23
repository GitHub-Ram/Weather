//
//  SearchViewController.swift
//  Weather
//
//  Created by Ram Kumar on 21/04/19.
//  Copyright © 2019 Ram Kumar. All rights reserved.
//

import Foundation
import  UIKit
import CoreLocation

class  SearchViewController: UIViewController, UITableViewDataSource,UITableViewDelegate ,UISearchBarDelegate{
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var customView: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    private var placeMark = [String]()
    var delegate:SearchViewControllerDelegate?
    private var placeMarker = [CLPlacemark]()
    @IBOutlet weak var tableView: UITableView!
    var searchActive : Bool = false
    
    override func viewDidLoad() {
        searchbar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        customView.clipsToBounds = true
        self.activityIndicator.stopAnimating()
        tableView.allowsSelection = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeMark.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "SimpleTableId";
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle,
                                   reuseIdentifier: cellId)
        }
        let text = placeMark[indexPath.row]
        cell?.textLabel?.text = text
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            self.delegate?.searchDismissed( location:self.placeMarker[indexPath.row])
            self.delegate = nil
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchActive = false;
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("textchange")
        print(searchText)
        if (searchText.count >= 3){
            self.activityIndicator.startAnimating()
            DispatchQueue.global(qos: .default).async {
                if Global.sharedInstance.isConnected{
                    self.extractedFunc(partText :searchText)
                }else{
                    DispatchQueue.main.async {
                        self.dismiss(animated: true) {
                            self.delegate = nil
                        }
                    }
                    
                }
                
            }
        }else{
            self.activityIndicator.stopAnimating()
            if self.placeMark.count != 0{
                self.placeMark = [String]()
                self.placeMarker = [CLPlacemark]()
                self.tableView.reloadData()
            }
        }
    }
    
    public func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        print("should chaneg")
        print(text)
        return true
    }
    
    fileprivate func extractedFunc(partText : String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(partText) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let addString = String(placemark.name != nil ? placemark.name! : "") + ", " + String(placemark.administrativeArea != nil ? placemark.administrativeArea! : "") + ", " + String(placemark.country != nil ? placemark.country! : "")
                    if self.placeMark.contains(addString){
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                        }
                        return
                    }
                    self.placeMark.append(addString)
                    self.placeMarker.append(placemark)
                    if self.placeMark.count > 5{
                        self.placeMark.remove(at:0)
                        self.placeMarker.remove(at: 0)
                    }
                    if self.placeMark.count > 0{
                        DispatchQueue.main.async {
                            self.placeMarker.reverse()
                            self.placeMark.reverse()
                            self.tableView.reloadData()
                            self.activityIndicator.stopAnimating()
                        }
                    }
                    
                    return 
                }
            }
        }
    }
}
protocol SearchViewControllerDelegate {
    func searchDismissed(location:CLPlacemark)
}
