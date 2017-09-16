//
//  QuickLookViewController.swift
//  Camera
//
//  Created by doug harper on 11/3/16.
//  Copyright © 2016 Doug Harper. All rights reserved.
//

import UIKit
import AVFoundation

class QuickLookViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var sparklesView: UIImageView!
    @IBOutlet weak var transmittingLabel: UILabel!
    
    var player: AVAudioPlayer?
    var timer = Timer()
    var secondTimer = Timer()
    
    func playSound(_ soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func playVogelrok() {
        playSound("vogelrok_sparkle")
    }
    
    func removeSparkles() {
       sparklesView.removeFromSuperview()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.loadGif(name: "flash")
        
        playSound("flash")
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: false)
    }
    
    func update() {
        imageView.loadGif(name: "worldjpg")
        imageView.contentMode = .scaleAspectFit
        
        playSound("vogelrok_sparkle")
        
        transmittingLabel.alpha = 1
        
        let url = URL(string: "http://146.185.181.252/hackathon/hackathon_images")
        URLSession.shared.dataTask(with:url!, completionHandler: {(data, response, error) in
            guard let data = data, error == nil else { return }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                var image: Any?
                
                for parsedAttribute in json {
                    print(parsedAttribute)
                    if parsedAttribute.key == "image" {
                        image = parsedAttribute.value
                    }
                }
                
                if let viewImage = image {
                    let url = URL(string: viewImage as! String)
                    
                    DispatchQueue.global().async {
                        let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                        DispatchQueue.main.async {
                            sleep(6)
                            self.transmittingLabel.alpha = 0
                            self.sparklesView.loadGif(name: "sparkles")
                            self.imageView.contentMode = .scaleAspectFill
                            self.imageView.image = UIImage(data: data!)
                            self.timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.removeSparkles), userInfo: nil, repeats: false)
                        }
                    }
                }
                
            } catch let error as NSError {
                print(error)
            }
        }).resume()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backToCamera(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "camera")
        self.present(nextViewController, animated:true, completion:nil)
    }
    

}
