//
//  WebLoader.swift
//  CovidNums
//
//  Created by Dylan Elliott on 20/8/21.
//

import Foundation
import WebKit

class WebLoader {
    private var webViewDelegate: WebViewDelegate!
    let webview: WKWebView
    private var onLoad: ((String) -> Void)?
    
    init() {
        webview = WKWebView()
        webViewDelegate = WebViewDelegate(onFinish: onWebviewLoad)
        webview.navigationDelegate = webViewDelegate
    }
    
    func load(url: URL, onLoad: @escaping (String) -> Void) {
        self.onLoad = onLoad
        webview.load(URLRequest(url: url))
    }
    
    func onWebviewLoad(webview: WKWebView) {
        webview.evaluateJavaScript("document.documentElement.outerHTML.toString()", completionHandler: { (html: Any?, error: Error?) in
            let htmlString = html as! String
            self.onLoad?(htmlString)
        })
    }
}

class WebViewDelegate: NSObject, WKNavigationDelegate {
    let onFinish: (WKWebView) -> Void
    
    init(onFinish: @escaping (WKWebView) -> Void) {
        self.onFinish = onFinish
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        onFinish(webView)
    }
}
