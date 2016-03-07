//
//  WPCategory.swift
//  cnect
//
//  Created by Tobin Bell on 2/21/16.
//  Copyright © 2016 Tobin Bell. All rights reserved.
//

import Foundation
import UIKit

class WPCategory: WPObject {
    let ID: Int
    let title: String
    let subtitle: String
    let tagline: NSAttributedString
    let parentID: Int?
    let size: Int
    
    let featuredImageURL: NSURL
    private let featuredImageQueue = NSOperationQueue()
    private var featuredImageCache: UIImage?
    private var featuredImageFetched = false
    
    func featuredImage(completionHandler: (UIImage?) -> Void) {
        
        // Perform callbacks on the main thread to allow for UI updates.
        let complete = { image in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                completionHandler(image)
            }
        }
        
        featuredImageQueue.qualityOfService = .UserInitiated
        featuredImageQueue.addOperationWithBlock {
            // If we have already fetched this image, simply return the cache.
            if self.featuredImageFetched {
                complete(self.featuredImageCache)
            }
            
            // Otherwise, go fetch it.
            if let data = NSData(contentsOfURL: self.featuredImageURL) {
                self.featuredImageFetched = true
                if let image = UIImage(data: data) {
                    self.featuredImageCache = image
                    complete(self.featuredImageCache)
                }
            }
        }
    }
    
    required init?(dict: NSDictionary) {
        featuredImageQueue.maxConcurrentOperationCount = 1
        
        guard let dictID            = dict["ID"] as? Int,
            dictTitle               = dict["title"] as? String,
            dictSubtitle            = dict["subtitle"] as? String,
            dictTagline             = dict["tagline"] as? String,
            dictParent              = dict["parent"] as? Int,
            dictSize                = dict["size"] as? Int,
            dictFeaturedImageURL    = dict["featuredImageURL"] as? String else {
                ID = 0
                title = ""
                subtitle = ""
                tagline = NSAttributedString(string: "")
                parentID = 0
                size = 0
                featuredImageURL = NSURL()
                return nil
        }
        
        ID = dictID
        title = dictTitle
        subtitle = dictSubtitle
        tagline = dictTagline.attributedString ?? NSAttributedString(string: "")
        parentID = dictParent != 0 ? dictParent : nil
        size = dictSize
        
        if let asURL = NSURL(string: dictFeaturedImageURL) {
            featuredImageURL = asURL
        } else {
            featuredImageURL = NSURL()
            return nil
        }
        
        // Begin fetching the featuredImage.
        featuredImage { _ in }
    }
}
