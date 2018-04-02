//
//  RealmModelFile.swift
//  TestTaskImageGallery
//
//  Created by Oleksandr Bambulyak on 30.03.2018.
//  Copyright © 2018 Oleksandr Bambulyak. All rights reserved.
//

import RealmSwift
import Foundation

class ImageObject: Object {
   @objc dynamic var imageTitle = ""
   @objc dynamic var imageDescription = ""
   @objc dynamic var imageDate = ""
   @objc dynamic var imagePath = ""
   @objc dynamic var number = 0
}
