//
//  ArticleViewController.swift
//  RSSReader
//
//  Created by Leopold Aschenbrenner on 17/03/15.
//  Copyright (c) 2015 Leopold Aschenbrenner. All rights reserved.
//

import UIKit

class ArticleViewController: UIViewController {

    var dataHelper = CoreDataHelper()
    // MARK: - Outlets
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var authorLabel: UILabel!
    
    @IBOutlet var contentLabel: UILabel!
    
    
    // MARK: - Setup View

    override func viewDidLoad() {
        super.viewDidLoad()
        var webButton = UIBarButtonItem(image: UIImage(named: "globe"), style: UIBarButtonItemStyle.Plain, target: self, action: "openWeb")
        self.navigationItem.rightBarButtonItem = webButton

        
        // Do any additional setup after loading the view.
    }
    
    
    func openWeb() {
        if let article = currentArticle {
            if article.link != nil {
            let webBrowser = KINWebBrowserViewController()
            println(article.link)
            let url = NSURL(string: article.link)
            webBrowser.showsPageTitleInNavigationBar = true
            webBrowser.showsURLInNavigationBar = true
            webBrowser.loadURL(url)
            self.navigationController!.pushViewController(webBrowser, animated: true)
            }
        }

    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let article = currentArticle {
            self.title = article.sourceTitle
            self.titleLabel.text = article.title
            self.dateLabel.text = NSDateFormatter.localizedStringFromDate(article.date, dateStyle: .MediumStyle, timeStyle: .ShortStyle)
            self.authorLabel.text = article.sourceTitle + "/"  + article.author
            self.contentLabel.text = article.content.stringByConvertingHTMLToPlainText()
        }
        
    }
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.+
        currentArticle == nil
    }
    

}
