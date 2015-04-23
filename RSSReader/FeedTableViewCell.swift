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
        thumbnailImage.clipsToBounds = true
        summaryText.clipsToBounds = true
        titleText.clipsToBounds = true
        sourceAndDateText.clipsToBounds = true
        addImage()

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
            setNumberOfLines()
            self.contentView.layoutSubviews()
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
        setNumberOfLines()
        self.contentView.layoutSubviews()
        
    }
    


  
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setNumberOfLines() {
        
        if titleConstAdd {
            self.contentView.removeConstraints([titleHeightConst, summaryHeightConst])
        }
        if titleText.numberOfLines == 3 {
            titleText.numberOfLines = 2
        }
        if countLabelLines(titleText) > 2 {
            titleText.numberOfLines = 3
            summaryText.numberOfLines = 2
            println("adjusting label heigh to be taller")
             titleHeightConst = NSLayoutConstraint(item: titleText, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 51)
            summaryHeightConst = NSLayoutConstraint(item: summaryText, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 32)
            self.contentView.addConstraints([titleHeightConst, summaryHeightConst])
        } else {
            titleText.numberOfLines = 2
            summaryText.numberOfLines = 3
            
             titleHeightConst = NSLayoutConstraint(item: titleText, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 36)
                summaryHeightConst = NSLayoutConstraint(item: summaryText, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 47)
            self.contentView.addConstraints([titleHeightConst, summaryHeightConst])
        }
        
        titleConstAdd = true
        

    }
}


func countLabelLines(label:UILabel)->Int{
    
    if let text = label.text{
        // cast text to NSString so we can use sizeWithAttributes
        var myText = text as NSString
        
        //Set attributes
        var attributes = [NSFontAttributeName : UIFont.boldSystemFontOfSize(14)]

        //Calculate the size of your UILabel by using the systemfont and the paragraph we created before. Edit the font and replace it with yours if you use another
  
        var labelSize = myText.boundingRectWithSize(CGSizeMake(label.bounds.width, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes, context: nil)
        
        //Now we return the amount of lines using the ceil method
        var lines = ceil(CGFloat(labelSize.height) / label.font.lineHeight)
        println(labelSize.height)
        println("\(lines)")
        return Int(lines)
    }
    
    return 0
    
}
