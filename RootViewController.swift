//
//  ViewController.swift
//  Project: weather天気
//
//  Created by Kueiapp.com on 2018/12/11.
//  Copyright © 2018 Kuei. All rights reserved,
//  Followed by GPLv3 license.
//

import UIKit
import SafariServices

// extension functions
extension UIImageView{
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

class ViewController: UIViewController, UIScrollViewDelegate {
    
    
    // MARK: -- members --
    @IBOutlet weak var tempView: UIView!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var humidLabel: UILabel!
    
    // MARK: -- methods --
    // MARK: -- App lifecycle --
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        
        // Style views
        self.styleViewCard(setView: tempView, withColor: UIColor(red: 117/255, green: 64/255, blue: 118/255, alpha: 1.0).cgColor)
        self.styleViewCard(setView: stepView, withColor: UIColor(red: 137/255, green: 154/255, blue: 120/255, alpha: 1.0).cgColor)
        self.styleViewCard(setView: distanceView, withColor: UIColor(red: 73/255, green: 64/255, blue: 50/255, alpha: 1.0).cgColor)
        self.styleViewCard(setView: heartRateView, withColor: UIColor(red: 107/255, green: 46/255, blue: 118/255, alpha: 1.0).cgColor)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        // ScrollView.contenSize is needed to be bigger than viewPort
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: 880)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

    func writeToAppGroup(name groupName:String, value v:Double){
        let fm = FileManager.default
        let baseURL = fm.containerURL(forSecurityApplicationGroupIdentifier: groupName)
        let url = URL(fileURLWithPath: "FILENAME", relativeTo: baseURL)
        do{
            let vString = String(v);
            try vString.write(to: url, atomically: true, encoding: .utf8)
        }
        catch{
            print("error writing app group")
        }
    }
    
    
    @IBAction func aboutBtnClicked(_ sender: Any) {
        let vc = SFSafariViewController(url: URL(string: "https://kueiapp.com")!)
        show(vc, sender: self)
    }
    
	
	// MARK: -- Get weather data --
	func getOpenWeather(){
		// from OpenWeatherMap.org
		let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?")
		let session = URLSession(configuration: URLSessionConfiguration.default)
		let dataTask = session.dataTask(with: url!) { (data,response,error) in
			if error == nil {
				var html: String? = nil
				if let data = data{
					html = String(data: data, encoding: .utf8)
				}
				print(html ?? "")
				
				// parse json
				
				do{
					let jsonObj = try JSONSerialization.jsonObject(
						with: data!,
						options: .allowFragments
						) as! Dictionary<String,AnyObject> // from Any to Dictionary
					
					self.updateOutdoorTemp(jsonObj)
				}
				catch{
					print(error.localizedDescription)
				}
				
				
				
			}
			else{
				print("err")
			}
		}
		
		dataTask.resume()
		
	}
	
	func updateOutdoorTemp(_ json:Dictionary<String,AnyObject>){
		//        print("The response is \(json)")
		let main = json["main"]! as! Dictionary<String,Double>
		let weather = json["weather"]! as! NSArray
		let weatherChild = weather[0] as! NSDictionary
		// Set values on UI
		DispatchQueue.main.async {
			let temp = main["temp"]! as! Double
			let humid = main["humidity"]! as! Double
			let desc = weatherChild["description"]! as! String
			let icon = weatherChild["icon"] as! String
			print(temp, humid)
			self.tempLabel.text = String(format: "氣溫 \(lround(temp - 275)) 度")
			self.humidLabel.text = String(format: "%溼度 \(lround(humid)) %%" )
			self.descLabel.text = desc
			
			// Async loading image
			let url = URL(string: "https://openweathermap.org/img/w/\(icon).png")!
			//            let urlData = try? Data(contentsOf: url) //make sure your image in this url does exist
			//            self.weatherIcon.image = UIImage.init(data:urlData!)
			self.weatherIcon.load(url: url)
		}
	}
	
	
}//class

