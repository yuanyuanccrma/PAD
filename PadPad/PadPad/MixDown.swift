//
//  MixDown.swift
//  PadPad
//
//  Created by 栗圆 on 3/19/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit
import CoreData

class MixDown: NSManagedObject {
    class func createNewMixFile(date: NSDate, url: String?, name: String?, diary: String?, coverImage: NSData?, in context: NSManagedObjectContext) -> MixDown {
        let mix = MixDown(context: context)
        mix.name = name
        mix.date = date
        mix.diary = diary
        mix.url = url
        mix.coverImage = coverImage
        return mix
    }

}
