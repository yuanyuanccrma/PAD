//
//  MixPlayTableViewController.swift
//  padpad
//
//  Created by 栗圆 on 3/17/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//
//  learn format date string: http://stackoverflow.com/questions/33277970/how-to-convert-string-to-date-to-string-in-swift-ios

import UIKit
import CoreData

class MixPlayTableViewController: UITableViewController {
    
    var mix: MixDown? {
        didSet {
            tableView.reloadData()
        }
    }
    // MARK: - View Controller Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Arial", size: 25.0)!, NSForegroundColorAttributeName: UIColor.darkGray]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Music Diary"

        default:
            return "Image"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if mix != nil {
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Keyword Cell", for: indexPath)
                switch indexPath.row {
                case 0:
                    cell.textLabel?.text = mix!.name! + " - " + DateString(String(describing: mix!.date!))
                default:
                    if mix!.diary == nil {
                        cell.textLabel?.text = "Dear Diary ..."
                    }
                    else {
                        cell.textLabel?.text = "Dear Diary, " + mix!.diary!
                    }
                }
                return cell
                
            default:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "Image Cell", for: indexPath) as? ImageTableViewCell {
                    cell.imageData = mix!.coverImage
                    return cell
                }
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "Keyword Cell", for: indexPath)
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if mix != nil {
            if (indexPath.section == 1 && mix!.name == nil) {
                let width = tableView.bounds.width
                if let image = UIImage(data: mix!.coverImage! as Data)
                {
                    let imageHeight = image.size.height
                    let imageWidth = image.size.width
                    return width / imageWidth * imageHeight
                }
            }
            return UITableViewAutomaticDimension
        }
        return CGFloat(0)
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if mix == nil {
            return 0
        }
        var sectionNumber = 0
        if mix?.name != nil {
            sectionNumber += 1
        }
        if mix?.coverImage != nil {
            sectionNumber += 1
        }
        return sectionNumber
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return 1
        }
    }
    func DateString(_ originalDateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZZ"
        let date = dateFormatter.date(from: originalDateString)!
        dateFormatter.dateFormat = "E MMM d, yyyy"
        let formattedDateString = dateFormatter.string(from: date)
        return formattedDateString
    }

}
