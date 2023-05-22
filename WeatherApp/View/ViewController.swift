//
//  ViewController.swift
//  WeatherApp
//
//  Created by Kalyani Puvvada on 5/21/23.
//

import UIKit
import CoreLocation
import Security

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var imageCache = NSCache<NSString, UIImage>()
    var searchText: String?
    var locationManager:CLLocationManager!
    
    // Search bar
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.returnKeyType = .search
        return searchBar
    }()
    
    // City text label
    let location: UILabel = {
        let label = UILabel()
        label.text = "Parsippany"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32)
        label.textColor = .white
        return label
    }()
    
    // Temperature text label
    let temperature: UILabel = {
        let label = UILabel()
        label.text = "17.0"
        label.font = UIFont.systemFont(ofSize: 44, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    // Weather update title label
    let titleText: UILabel = {
        let label = UILabel()
        label.text = "clouds"
        label.font = UIFont.systemFont(ofSize: 24)
        label.textColor = .white
        return label
    }()
    
    // Weather update description label
    let descriptionText: UILabel = {
        let label = UILabel()
        label.text = "over clouds"
        label.font = UIFont.systemFont(ofSize: 24)
        label.textColor = .white
        return label
    }()
    
    // Stackview for labels
    lazy var stackView: UIStackView = {
       let stackview = UIStackView(arrangedSubviews: [temperature, location, titleText ,descriptionText])
        stackview.axis = .vertical
        stackview.spacing = 5
        stackview.alignment = .center
        stackview.distribution = .fillEqually
        return stackview
    }()
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBlue
        self.navigationItem.title = "Weather App"
        self.navigationController!.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        // Do any additional setup after loading the view.
        setupView()
        reloadData()
    }
    
    // Setup searchbar and stackview
    private func setupView() {
        self.view.addSubview(searchBar)
        self.view.addSubview(stackView)
        searchBar.anchor(top: self.view.topAnchor, leading: self.view.leadingAnchor, bottom: self.stackView.topAnchor, trailing: self.view.trailingAnchor, paddingLeft: 20, paddingRight: -20, paddingTop: 150, paddingBottom: -100, width: 0, height: 50)
        searchBar.delegate = self
        stackView.anchor(top: self.searchBar.bottomAnchor, leading: self.view.leadingAnchor, bottom: nil, trailing: self.view.trailingAnchor, paddingLeft: 20, paddingRight: -20, paddingTop: 100, paddingBottom: 0, width: 0, height: 170)
    }
    
    private func reloadData() {
        // Fetching if already searched for any location else getting current location
        if let fetchText = KeychainHelper.shared.fetchText(searchText: "MySearch"), !fetchText.isEmpty {
            self.searchText = fetchText
            viewModel.fetchWeatherDetails(city: fetchText)
        } else {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            if CLLocationManager.locationServicesEnabled(){
                locationManager.startUpdatingLocation()
            }
        }
        
        // Reload closure to update UI after fetching weather info
        viewModel.reloadClosure = {
            // Fetching image icon data if already cached else fetching data from url
            if let image = self.imageCache.object(forKey: self.viewModel.getImageURLString() as NSString) {
                DispatchQueue.main.async {
                    let attachment = NSTextAttachment()
                    attachment.image = image
                    attachment.bounds = CGRect(x: 0, y: -20, width: 70, height: 70)
                    let attachmentString = NSAttributedString(attachment: attachment)
                    let temperature = NSMutableAttributedString(string: self.viewModel.getTemperature())
                    temperature.append(attachmentString)
                    self.temperature.attributedText = temperature
                }
            } else {
                // Fetching image icon data from url
                APIService.shared.fetchImageData(urlString: self.viewModel.getImageURLString()) { data, error in
                    if let data = data {
                        let attachment = NSTextAttachment()
                        let image = UIImage(data: data)
                        attachment.image = image
                        self.imageCache.setObject(image!, forKey: self.viewModel.getImageURLString() as NSString)
                        attachment.bounds = CGRect(x: 0, y: -20, width: 70, height: 70)
                        let attachmentString = NSAttributedString(attachment: attachment)
                        let temperature = NSMutableAttributedString(string: self.viewModel.getTemperature())
                        temperature.append(attachmentString)
                        DispatchQueue.main.async {
                            self.temperature.attributedText = temperature
                        }
                    } else {
                        // If no data available display only temperature text
                        DispatchQueue.main.async {
                            self.temperature.text = self.viewModel.getTemperature()
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                // Updating UI after fetching data from API
                self.searchBar.text = self.searchText
                self.location.text = self.viewModel.getLocation()
                self.titleText.text = self.viewModel.getTitle()
                self.descriptionText.text = self.viewModel.getDescription()
                if !self.viewModel.getMessage().isEmpty {
                    self.location.text = self.viewModel.getMessage()
                } else if let searchText = self.searchText {
                    // Deleting old search text and Saving new city name in Keychain
                    KeychainHelper.shared.deleteText(searchKey: "MySearch")
                    KeychainHelper.shared.saveText(searchText: searchText, searchKey: "MySearch")
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation

        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
            if (error != nil){
                print("error in reverseGeocode")
            }
            let placemark = placemarks! as [CLPlacemark]
            if placemark.count>0{
                let placemark = placemarks![0]
                print(placemark.locality!)
                print(placemark.administrativeArea!)
                print(placemark.country!)
                // Make an API call to fetch wether details for the current location
                self.viewModel.fetchWeatherDetails(city: placemark.locality!)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
}

// Fetching weather details for the searched city
extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let searchText = searchBar.text {
            self.searchText = searchText
            viewModel.fetchWeatherDetails(city: searchText)
        }
    }
}
