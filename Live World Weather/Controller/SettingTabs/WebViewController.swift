//
//  WebViewController.swift
//  Coder Weather
//
//  Created by Coder ACJHP on 15.08.2018.
//  Copyright © 2018 Coder ACJHP. All rights reserved.
//

import UIKit
import WebKit
import MBProgressHUD

class WebViewController: UIViewController {

    var viewTitle: String!
    var requestedUrl: URLRequest!
    var spinnerActivity = MBProgressHUD()
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.navigationDelegate = self
        
        // Initialize spinner (MBHUD)
        self.spinnerActivity = MBProgressHUD.showAdded(to: self.view, animated: true);
        // Change some properties of spinner
        self.spinnerActivity.label.text = "Loading..."
        self.spinnerActivity.isUserInteractionEnabled = true
        
        // Assign value of title
        self.title = viewTitle
        
        // load pages
        self.loadHtmlPage()
    }
    
    fileprivate func loadHtmlPage() {
        // Assign html page url
        self.webView.load(requestedUrl)
        
    }

}

extension WebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.spinnerActivity.show(animated: true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.spinnerActivity.hide(animated: true)
    }
}
