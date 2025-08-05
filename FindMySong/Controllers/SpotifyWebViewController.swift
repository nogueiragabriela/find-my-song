//
//  SpotifyWebViewController.swift
//  FindMySong
//
//  Created by henrique.cisi on 05/06/25.
//
import UIKit
@preconcurrency import WebKit

protocol SpotifyWebViewControllerDelegate: AnyObject {
    func spotifyWebViewController(_ controller: SpotifyWebViewController, didReceiveCode code: String)
}

class SpotifyWebViewController: UIViewController, WKNavigationDelegate {
    
    private var webView: WKWebView!
    private let viewModel = SpotifyWebViewModel()
    weak var delegate: SpotifyWebViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login with Spotify"
        view.backgroundColor = .systemBackground
        
        webView = WKWebView(frame: .zero)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        if let url = viewModel.authURL {
            webView.load(URLRequest(url: url))
        }
    }
    
    // MARK: - Interceptor method
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let code = viewModel.handleNavigationAction(navigationAction) {
            delegate?.spotifyWebViewController(self, didReceiveCode: code)
            dismiss(animated: true)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
