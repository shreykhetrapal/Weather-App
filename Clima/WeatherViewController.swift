//
//  ViewController.swift
//  WeatherApp
//
//  Created by Shrey Khetrapal on 21/08/2018.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON




class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "24d4365a4e6e9c721fda4f83a066e2ad"
    

    //TODO: Declare instance variables here
    
    let locationManager = CLLocationManager()
    
    let weatherDataModel = WeatherDataModel()
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
    
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        locationManager.requestWhenInUseAuthorization() //the permission pop-up wont come by only this line of code, we need to make some changes in plist of our project
        
        locationManager.startUpdatingLocation() //these are asynchronous functions , happen in background and let the user use the app without crashing
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    

    func getWeatherData(url : String, parameters : [String : String]){
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess{
                print("Success , got the weather data")
                
                let weatherJSON : JSON = JSON(response.result.value!)
                
                //print(weatherJSON) . Uncomment this to check what the JSON data looks like in the debugger
                
                self.updateWeatherData(json: weatherJSON)
                
                
            }
            else {
                print(response.result.error!)
                self.cityLabel.text = "Connection Issues"
            }
            
        }
        
    }
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    
    func updateWeatherData(json : JSON){
        
        if let tempResult = json["main"]["temp"].double
        {
            
            weatherDataModel.temperature = Int(tempResult - 273.15)
            
            
            weatherDataModel.city = json["name"].stringValue
            
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIWithWeatherData()
            
        }
            
        else {
            
            cityLabel.text = "Weather Unavailable"
        }
        
        
    }
    
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    
    func updateUIWithWeatherData(){
        
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[locations.count - 1] //The didUpdateLocations locations is an array , which starts storing the recieved values with increased accuracy , so the last location received is the most accurate one .
        if location.horizontalAccuracy > 0{
            locationManager.stopUpdatingLocation()
            
            print ("longitude = \(location.coordinate.longitude) , Latitiude = \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let params : [String : String] = ["lat" : latitude, "lon" : longitude,"appid" : APP_ID]
            
            getWeatherData(url : WEATHER_URL, parameters : params)
            
        }
    }
    
    
    //Write the didFailWithError method here:
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    
    func userEnteredANewCityName(city: String) {
        
        let params : [String : String] = ["q" : city , "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
        
        
    }
    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
            
        }
    }
    
    
    
}


