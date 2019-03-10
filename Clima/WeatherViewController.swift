

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON



class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "84313048024d2356bcef01ab0bc9695e"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    

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
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
   
    func getWeatherData(url: String, parameters:[String: String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success! Got the weather data")
                
                let weatherJSON: JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
                
            }
            else {
                print("Error \(response.result.error!)")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    
    func updateUIWeatherData() {
        cityLabel.text = weatherDataModel.city
        
        temperatureLabel.text = "\(weatherDataModel.temperature)°C"
        
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        
        
    }
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
        func updateWeatherData(json:JSON) {
            
            if let tempResult = json["main"]["temp"].double {
            weatherDataModel.temperature = Int(tempResult - 273.15)
            
            weatherDataModel.city = json["name"].stringValue
            
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIWeatherData()
            }
            
            else {
                cityLabel.text = "Weather Unavailable"
            }
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    // Write the didUpdateLocations method here:
    
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil

            print("longtitude = \(location.coordinate.longitude), latitude =  \(location.coordinate.latitude)")
            let longtitude = String(location.coordinate.longitude)
            let latitude = String(location.coordinate.latitude)

            let param : [String: String] = ["lat": latitude, "lon": longtitude, "appid" : APP_ID]

            getWeatherData(url: WEATHER_URL, parameters: param)
            }
    }
    
    //Write the didFailWithError method here:
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unvailable"
    }

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    
    func userEnteredANewCityName(city: String) {
        let params: [String: String] = ["q": city, "appid": APP_ID]
        
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
