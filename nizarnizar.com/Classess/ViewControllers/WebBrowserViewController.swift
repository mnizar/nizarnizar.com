//
//  WebBrowserViewController.swift
//  nizarnizar.com
//
//  Created by Muhammad Nizar on 7/30/16.
//  Copyright © 2016 Surocode Inc. All rights reserved.
//

import UIKit

class WebBrowserViewController: BaseViewController {
    
    var request : NSURLRequest!
    @IBOutlet weak var webView : UIWebView!
    @IBOutlet weak var loadingIndicatorView : UIActivityIndicatorView!
    @IBOutlet weak var errorView : UIView?
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.hidden = true
        errorView?.hidden = true
        
        webView.loadRequest(request)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: - UIWebViewDelegate

extension WebBrowserViewController: UIWebViewDelegate {
    
    func webViewDidStartLoad(webView: UIWebView) {
        webView.hidden = false
        self.loadingIndicatorView.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.loadingIndicatorView.stopAnimating()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        if (error?.code == NSURLErrorCancelled ||
            error?.code == NSURLErrorFileDoesNotExist) {
            return
        }
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        return true
    }
}
