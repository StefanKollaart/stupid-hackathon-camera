//
//  QuickLookViewController.swift
//  Camera
//
//  Created by doug harper on 11/3/16.
//  Copyright © 2016 Doug Harper. All rights reserved.
//

import UIKit

class QuickLookViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        imageView.loadGif(name: "pizza-gif.gif")
        
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
                            sleep(4)
                            self.imageView.image = UIImage(data: data!)
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
