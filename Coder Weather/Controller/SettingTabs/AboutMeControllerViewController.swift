//
//  AboutMeControllerViewController.swift
//  Coder Weather
//
//  Created by Coder ACJHP on 3.07.2018.
//  Copyright © 2018 Coder ACJHP. All rights reserved.
//

import UIKit

class AboutMeControllerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func emailMe(_ sender: Any) {
        UIApplication.shared.open(URL(string: "mailto:hexa.octabin@gmail.com")!, options: [:], completionHandler: nil)
    }
    @IBAction func followMePressed(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://github.com/Coder-ACJHP/")!, options: [:], completionHandler: nil)
    }
}
