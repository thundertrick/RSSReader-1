//
//  FeedTableViewCell.swift
//  RSSReader
//
//  Created by The Hexagon on 01/03/15.
//  Copyright (c) 2015 The Hexagon. All rights reserved.
//

import UIKit
import Alamofire

class FeedTableViewCell: UITableViewCell {

    var thumbnailImage = UIImageView()
    
    @IBOutlet var titleText: UILabel!
    var request: Alamofire.Request?
 
    @IBOutlet var summaryText: UILabel!
    
    @IBOutlet var sourceAndDateText: UILabel!
    
    var imgTitleConst = NSLayoutConstraint()
    var imgSummaryConst = NSLayoutConstraint()
    var imgDetailConst = NSLayoutConstraint()
    
    var titleConst = NSLayoutConstraint()
    var summaryConst = NSLayoutConstraint()
    var detailConst = NSLayoutConstraint()
    
    var titleHeightConst = NSLayoutConstraint()
    var summaryHeightConst = NSLayoutConstraint()
   

    var imageRemoved = false
    var titleConstAdd = false
    override func awakeFromNib() {
        super.awakeFromNib()
    
   
        titleText.font = UIFont.boldFontWithSize(13)
        summaryText.font = UIFont.fontWithSize(12)
        sourceAndDateText.font = UIFont.fontWithSize(11)
        sourceAndDateText.textColor = UIColor.darkGrayColor()
        addImage()
        thumbnailImage.clipsToBounds = true
        summaryText.clipsToBounds = true
        titleText.clipsToBounds = true
             sourceAndDateText.clipsToBounds = true
        
        self.accessoryType = .DisclosureIndicator

    }

    
    func removeImage() {
        if let viewToRemove = self.viewWithTag(123) {
            imageRemoved = true
            viewToRemove.removeFromSuperview()
            self.contentView.removeConstraints([imgTitleConst, imgSummaryConst, imgDetailConst])
            titleConst = NSLayoutConstraint(item: self.titleText, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 14)
            
            summaryConst = NSLayoutConstraint(item: summaryText, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 14)
            
            detailConst = NSLayoutConstraint(item: sourceAndDateText, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 14)
        
            self.contentView.addConstraints([titleConst, detailConst, summaryConst])

        }
      
        
    }
    
    
    
    func addImage() {
        thumbnailImage.tag = 123
        thumbnailImage.image = UIImage(named: "placeholder")
        thumbnailImage.frame = CGRectMake(14, 12, 100, 100)
        thumbnailImage.contentMode = UIViewContentMode.ScaleAspectFill
        thumbnailImage.clipsToBounds = true
        self.contentView.addSubview(thumbnailImage)
        
        if imageRemoved {
            self.contentView.removeConstraints([titleConst, summaryConst, detailConst])
        }
        
        
        var widthConst = NSLayoutConstraint(item: thumbnailImage, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 100)
        var heightConst = NSLayoutConstraint(item: thumbnailImage, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 100)
        var leftConst = NSLayoutConstraint(item: thumbnailImage, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 14)
        var topConst = NSLayoutConstraint(item: thumbnailImage, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 12)
        

        
          imgTitleConst = NSLayoutConstraint(item: self.titleText, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self.thumbnailImage, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 8)
        
         imgSummaryConst = NSLayoutConstraint(item: summaryText, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self.thumbnailImage, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 8)
        
         imgDetailConst = NSLayoutConstraint(item: sourceAndDateText, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self.thumbnailImage, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 8)
        

        self.contentView.addConstraints([widthConst, heightConst, leftConst, topConst, imgTitleConst, imgSummaryConst, imgDetailConst])
 
        self.contentView.layoutSubviews()
        
    }
    


  
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
   
}
