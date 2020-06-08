//
//  GameViewController.swift
//  collectionviewcontroller
//
//  Created by denys pashkov on 05/12/2019.
//  Copyright © 2019 denys pashkov. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

//  MARK: -ViewController

class GameViewController: UIViewController {

//  variable for cells managment
    @IBOutlet weak var resturantsCollection: UICollectionView!
    @IBOutlet weak var ViewToHide2: UICollectionView!
    
//  variable for location managment
    var locationManager = CLLocationManager()
    var currentPosition : CLLocation?
    var matchingItems: [MKMapItem] = []
    var setImages : [UIImage] = []
    var setIcons : [UIImage] = []
    
//  variable for second collection managment
    @IBOutlet weak var viewToHide: UIView!
    let maxDistance: CGFloat = 141
    var startDragPosition: CGFloat = 0
    var distanceMoved: CGFloat = 0
    var lastPosition: CGFloat = 0
    let iconNames : [String] = ["Pizza","Japanese","Hamburger","Sandwitch","Chicken","Desserts","Italian","Ice Cream"]
    
    override func viewDidLoad() {
        
        overrideUserInterfaceStyle = .light
        
        ViewToHide2.delegate = self
        ViewToHide2.dataSource = self
        ViewToHide2.reloadData()
        
        super.viewDidLoad()
        cellSetting()
        locationSetting()

    }
    
//    cell sizes
    func cellSetting(){
        
        let layer = resturantsCollection.collectionViewLayout as! UICollectionViewFlowLayout
        let width = ( resturantsCollection.frame.width  )
        viewToHide.frame.size.height = CGFloat(maxDistance)
        layer.itemSize = CGSize(width: width , height: width)
        
    }
        
//    request for my location
    func locationSetting(){
            
            self.locationManager.requestWhenInUseAuthorization()
            if CLLocationManager.locationServicesEnabled() {
                        
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.requestLocation()
                        
            }
            
        }
    
//    Search for resturants
    func findResturant() {
        let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = "Ristoranti"
        request.region = MKCoordinateRegion(center: currentPosition!.coordinate, latitudinalMeters: 0, longitudinalMeters: 0)
            let search = MKLocalSearch(request: request)
            search.start { response, _ in guard let response = response else {
                
                    return
                    
                }
                
                self.matchingItems = response.mapItems
                self.resturantsCollection.delegate = self
                self.resturantsCollection.dataSource = self
                
            }
            
        }
    
}

//  MARK: -Collection View Delegate & DataSource

extension GameViewController : UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        create the number of cells based on found resturant
        if collectionView == resturantsCollection{
            return matchingItems.count
        } else {
            return iconNames.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == resturantsCollection{
            
            let cell = resturantsCollection.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ResturantCellManager
                    cell.resturantPreview.frame.size.height = (cell.frame.width / 8) * 6

            //        Set the resturant Name
                    cell.resturantName.text = matchingItems[indexPath.row].name

            //      Setting Photo and icon
                    
                    if setImages.count != matchingItems.count {
                        cell.resturantPreview.image = UIImage(named: "Foto\(Int.random(in: 1...37))")
                        setImages.append(cell.resturantPreview.image!)
                        cell.resturantIcon.image = UIImage(named: "Icon\(Int.random(in: 1...33))")
                        setIcons.append(cell.resturantIcon.image!)
                        
                    } else {
                        
                        cell.resturantPreview.image = setImages[indexPath.row]
                        cell.resturantIcon.image = setIcons[indexPath.row]
                        
                    }
                    
            //        Set The Resturant Category
                    cell.type.text = matchingItems[indexPath.row].pointOfInterestCategory?.rawValue.replacingOccurrences(of: "MKPOICategory", with: "")
                    
                    return cell
            
        } else {
            let cell = ViewToHide2.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ResturantTypeCellManager
            
            cell.typeImage.image = UIImage(named: "Type\(indexPath.row).jpg")
            cell.typeName.text = iconNames[indexPath.row]

            return cell
            
        }
        
    }
}

//  MARK: - ScrollView Delegate

extension GameViewController : UIScrollViewDelegate{
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

        startDragPosition = scrollView.contentOffset.y
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        if viewToHide.frame.height > 70{
            
            self.viewToHide.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: maxDistance)
            
        } else if viewToHide.frame.height <= 40 {
            
            self.viewToHide.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 0)
            
        }
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if distanceMoved < maxDistance && distanceMoved > 40 {
            
            distanceMoved = maxDistance
            
        }
        lastPosition = distanceMoved
        self.viewToHide.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: distanceMoved)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let offSet = scrollView.contentOffset.y
        
        distanceMoved = lastPosition + startDragPosition - offSet
        if offSet < maxDistance {
            
            distanceMoved = maxDistance - (offSet == -88.0 ? 0 : offSet)
            
        } else if distanceMoved > maxDistance{
            
            distanceMoved = maxDistance
            
            
        } else if distanceMoved < 0 {
            
            distanceMoved = 0
            
        }

        lastPosition = distanceMoved
        var finalPosition : CGFloat = 0
        UIView.animate(withDuration: 0.2) {
            finalPosition =  self.distanceMoved / self.maxDistance
            self.viewToHide.frame.size.height = self.maxDistance * finalPosition

        }
        
        
        
    }
    
}

//  MARK: - Location Manager Delegate

extension GameViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {

            locationManager.requestLocation()
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentPosition = location
            

            
            findResturant()
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error happened: \(error)")
    }
    
}

