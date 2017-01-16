//
//  WebBrowserViewController.swift
//  nizarnizar.com
//
//  Created by Muhammad Nizar on 7/30/16.
//  Copyright © 2016 Surocode Inc. All rights reserved.
//

import UIKit

class WebBrowserViewController: BaseViewController {
    
    var request : URLRequest!
    @IBOutlet weak var webView : UIWebView!
    @IBOutlet weak var loadingIndicatorView : UIActivityIndicatorView!
    @IBOutlet weak var errorView : UIView?
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.isHidden = true
        errorView?.isHidden = true
        
        webView.loadRequest(request)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: - UIWebViewDelegate

extension WebBrowserViewController: UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        webView.isHidden = false
        self.loadingIndicatorView.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.loadingIndicatorView.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        if  (error as NSError).code == NSURLErrorCancelled ||
            (error as NSError).code == NSURLErrorFileDoesNotExist {
            // code
            return
        }
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        return true
    }
}
