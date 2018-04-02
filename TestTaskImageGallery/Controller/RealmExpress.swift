//
//  RealmExpress.swift
//  TestTaskImageGallery
//
//  Created by Oleksandr Bambulyak on 02.04.2018.
//  Copyright © 2018 Oleksandr Bambulyak. All rights reserved.
//

import UIKit
import RealmSwift

class RealmExpress: UIView {

    class func writeImageObjectWith(title: String, description: String, image: UIImage, date: String)  -> Bool {
        
        enum Status {
            case success
            case fail
        }
        
        var status = Status.fail
        
        let realm = try! Realm()
     
        let object = ImageObject()
        
        object.imageTitle = title
        object.imageDescription = description
        
        let uniqueImageName = generateUniqueImageName()
        object.number = generateUniqueImageName()
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let imageURL = documentsURL?.appendingPathComponent("\(uniqueImageName).png")
        
            do {
                if let tempImageUrl = imageURL {
                    try UIImageJPEGRepresentation(image, 0.4)?.write(to: tempImageUrl)
                    object.imagePath = (imageURL?.absoluteString)!
                }
            } catch {
                status = .fail
            }
        
            object.imageDate = date
        
        try! realm.write {
            realm.add(object)
            status = .success
        }
 
        switch status {
        case .success:
            return true
        case .fail:
            return false
        }
        
        return false
    }
    }

func generateUniqueImageName() -> Int {
    let realm = try! Realm()
    let allImages = realm.objects(ImageObject.self)
    var imageNumber: Int = 0
    if (allImages.count == 0) {
        imageNumber = 1
    } else {
        imageNumber = (allImages.last?.number)! + 1
    }
    return imageNumber
}


