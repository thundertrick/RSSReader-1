//
//  ArticleViewController.swift
//  RSSReader
//
//  Created by The Hexagon on 17/03/15.
//  Copyright (c) 2015 The Hexagon All rights reserved.
//

import UIKit
import TUSafariActivity



class ArticleViewController: UIViewController, UIWebViewDelegate {
    
    // MARK: - init
    var dataHelper = CoreDataHelper()
    var parser = HTMLParser()
    @IBOutlet var webView: UIWebView!
    
    var actionButton : UIBarButtonItem = UIBarButtonItem()
    var starButton : UIBarButtonItem = UIBarButtonItem()
    var readButton : UIBarButtonItem = UIBarButtonItem()
    // MARK: - Setup View

    override func viewDidLoad() {
        super.viewDidLoad()
       
        var webButton = UIBarButtonItem(image: UIImage(named: "globe"), style: UIBarButtonItemStyle.Plain, target: self, action: "openWeb")
        self.navigationItem.rightBarButtonItem = webButton
        initToolBarButtonItems()
        webView.delegate = self
        webView.opaque = false
        
        // clear backButton text
        
        let backItem = UIBarButtonItem(title: "", style:.Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem

        
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
        
        if article.read == false {
              self.readButton = UIBarButtonItem(image: UIImage(named: "filledCircle"), style: UIBarButtonItemStyle.Plain, target: self, action: "readItem")
            
        } else {
            self.readButton = UIBarButtonItem(image: UIImage(named: "unfilledCircle"), style: UIBarButtonItemStyle.Plain, target: self, action: "readItem")

        }
        
        self.toolbarItems = [readButton, flexibleSpace, starButton, flexibleSpace, actionButton]
        }

    }

    func openWeb() {
        if let article = currentArticle {
            if article.link != nil {
                let url = NSURL(string: article.link)
                var webView = WebViewController(url: url!)
                self.navigationController!.pushViewController(webView, animated: true)
                
            }
        }

    }
    
    
    func readItem() {
        if let article = currentArticle {
            if article.read == true {
                article.read = false
            } else {
                article.read = true
            }
        
    
            initToolBarButtonItems()
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
        self.navigationController!.hidesBarsOnSwipe = true
        self.navigationController!.hidesBarsOnTap = true
      
        if let article = currentArticle {
            self.title = article.sourceTitle
            parser.articleContent = article.content
            parser.articleTitle = article.title
            parser.articleAuthor = article.sourceTitle + "/"  + article.author
            parser.articleDatePublished = article.date

            self.webView.loadHTMLString(parser.article, baseURL: NSURL(string: article.link))
        
        }
      
        
    }
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    
    
        if navigationType == UIWebViewNavigationType.LinkClicked {
            
            let url = request.URL
            var webView = WebViewController(url: url!)
            self.navigationController!.pushViewController(webView, animated: true)
            return false

        } else {
            return true
        }
        
        }
    
    
    func actionMethod() {
   
        if let article = currentArticle {
            let textToShare = article.title
            if let link = NSURL(string: article.link) {
                let objectsToShare = [textToShare, link]
                let safariActivity = TUSafariActivity()

                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: [safariActivity])
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
    
 


 
    

}
