//
//  ArticleViewController.swift
//  RSSReader
//
//  Created by The Hexagon on 17/03/15.
//  Copyright (c) 2015 The Hexagon All rights reserved.
//

import UIKit
import TUSafariActivity

var articleViewScrollPosition :CGPoint? = nil

class ArticleViewController: UIViewController, UIWebViewDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - init
    var dataHelper = CoreDataHelper()
    var parser = HTMLParser()
    @IBOutlet var webView: UIWebView!
    
    var actionButton : UIBarButtonItem = UIBarButtonItem()
    var starButton : UIBarButtonItem = UIBarButtonItem()
    var readButton : UIBarButtonItem = UIBarButtonItem()
    
    var backGestureRecognizer = UISwipeGestureRecognizer()
    var forwardGestureRecognizer = UISwipeGestureRecognizer()
    
    
        var viewDidLayoutSubviewScrollPosition = false
    // MARK: - Setup View

    override func viewDidLoad() {
        super.viewDidLoad()
         // gestureRecognizers
        backGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        backGestureRecognizer.delegate = self
        backGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(backGestureRecognizer)
        
        forwardGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        forwardGestureRecognizer.delegate = self
        forwardGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(forwardGestureRecognizer)
        
        self.webView.scrollView.panGestureRecognizer.requireGestureRecognizerToFail(forwardGestureRecognizer)
        self.webView.scrollView.panGestureRecognizer.requireGestureRecognizerToFail(backGestureRecognizer)
    
        
        var webButton = UIBarButtonItem(image: UIImage(named: "globe"), style: UIBarButtonItemStyle.Plain, target: self, action: "openWeb")
        self.navigationItem.rightBarButtonItem = webButton
        initToolBarButtonItems()
        webView.delegate = self
        webView.opaque = false

        
        // clear backButton text
        
        let backItem = UIBarButtonItem(title: "", style:.Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
    

        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.hidesBarsOnSwipe = true
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.setToolbarHidden(false, animated: true)
        viewDidLayoutSubviewScrollPosition = false

        if let article = currentArticle {
            self.title = article.sourceTitle
            parser.articleContent = article.content
            parser.articleTitle = article.title
            parser.articleAuthor = article.author
            parser.articleSource =  article.sourceTitle
            parser.articleDatePublished = article.date
            
            
            self.webView.loadHTMLString(parser.article, baseURL: NSURL(string: article.link))
            
        }
     
        
        
    }

    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
       articleViewScrollPosition = self.webView.scrollView.contentOffset
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !viewDidLayoutSubviewScrollPosition {
            if let scrollPosition = articleViewScrollPosition {
                self.webView.scrollView.setContentOffset(scrollPosition, animated: false)
            }
            viewDidLayoutSubviewScrollPosition = true
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == forwardGestureRecognizer || gestureRecognizer == backGestureRecognizer {
            return true
        }
        
        return false
    }
    
    // MARK: - Gesture Recognizer
    

    func handleSwipe(recognizer:UISwipeGestureRecognizer){
        println("handle swipe")

        if recognizer.direction == UISwipeGestureRecognizerDirection.Left{
          
            openWeb()
        } else {
            self.navigationController?.popViewControllerAnimated(true)
        }
        
    
        
        
        
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
    
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if let scrollPosition = articleViewScrollPosition {
            self.webView.scrollView.setContentOffset(scrollPosition, animated: false)
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
