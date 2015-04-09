//
//  ArticleViewController.swift
//  RSSReader
//
//  Created by The Hexagon on 17/03/15.
//  Copyright (c) 2015 The Hexagon All rights reserved.
//

import UIKit

class ArticleViewController: UIViewController, UIWebViewDelegate {
    
    // MARK: - init
    var dataHelper = CoreDataHelper()
    var parser = HTMLParser()
    @IBOutlet var webView: UIWebView!
    
    var actionButton : UIBarButtonItem = UIBarButtonItem()
    var starButton : UIBarButtonItem = UIBarButtonItem()
    // MARK: - Setup View

    override func viewDidLoad() {
        super.viewDidLoad()
        var webButton = UIBarButtonItem(image: UIImage(named: "globe"), style: UIBarButtonItemStyle.Plain, target: self, action: "openWeb")
        self.navigationItem.rightBarButtonItem = webButton
        initToolBarButtonItems()
                webView.delegate = self
        
        
        // Do any additional setup after loading the view.
    }
    
    func initToolBarButtonItems() {
       if let article = currentArticle {
        actionButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "actionMethod")
        var flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        if article.starred == true {
            self.starButton = UIBarButtonItem(image: UIImage(named: "filledStar"), style: UIBarButtonItemStyle.Plain, target: self, action: "starItem")
            
        } else {
            self.starButton = UIBarButtonItem(image: UIImage(named: "unfilledStar"), style: UIBarButtonItemStyle.Plain, target: self, action: "starItem")
        }
    
        self.toolbarItems = [flexibleSpace, starButton, flexibleSpace, actionButton, flexibleSpace]
        }

    }

    func openWeb() {
        if let article = currentArticle {
            if article.link != nil {
            let webBrowser = KINWebBrowserViewController()
     
            let url = NSURL(string: article.link)
            webBrowser.showsPageTitleInNavigationBar = true
            webBrowser.showsURLInNavigationBar = true
            webBrowser.loadURL(url)
            self.navigationController!.pushViewController(webBrowser, animated: true)
            }
        }

    }
    
    func starItem() {
        if let article = currentArticle {
            if article.starred == true {
                article.starred = false
            } else {
                article.starred = true
            }
            initToolBarButtonItems()
        }
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let article = currentArticle {
            self.title = article.sourceTitle
            parser.articleContent = article.content
            parser.articleTitle = article.title
            parser.articleAuthor = article.sourceTitle + "/"  + article.author
            parser.articleDatePublished = article.date
         
            println(parser.article)
            self.webView.loadHTMLString(parser.article, baseURL: NSURL(string: article.link))
        }
      
        
    }
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
             if let article = currentArticle {
                if request.URL ==  NSURL(string: article.link) {
                    return true
                } else {
                    let webBrowser = KINWebBrowserViewController()
                    let url = request.URL
                    webBrowser.showsPageTitleInNavigationBar = true
                    webBrowser.showsURLInNavigationBar = true
                    webBrowser.loadURL(url)
                    self.navigationController!.pushViewController(webBrowser, animated: true)
                    return false
                }
             } else {
                return true
        }
    }
    
    func actionMethod() {
   
        if let article = currentArticle {
            let textToShare = article.title
            if let link = NSURL(string: article.link) {
                let objectsToShare = [textToShare, link]
                let safariActivity = SVWebViewControllerActivitySafari()
                let chromeActivity = SVWebViewControllerActivityChrome()
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: [safariActivity, chromeActivity])
                if activityVC.respondsToSelector("popoverPresentationController") {
                    // iOS 8+
                    let presentationController = activityVC.popoverPresentationController
                    presentationController?.sourceView = view
                    presentationController?.barButtonItem = actionButton
                }
                self.presentViewController(activityVC, animated: true, completion: nil)
            
            
        
            }
        }
    }
    
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.+
        currentArticle == nil
    }
    

}
