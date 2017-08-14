//
//  MixCollectionTableViewController.swift
//  padpad
//
//  Created by 栗圆 on 3/17/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//
import UIKit
import CoreData

class MixCollectionTableViewController: FetchedResultsTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    var mixdown: MixDown? {
        didSet {
            tableView.reloadData()
        }
    }
    var fetchedResultsController: NSFetchedResultsController<MixDown>?
    
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
        { didSet { updateUI() } }
    private func updateUI() {
        if let context = container?.viewContext {
            let request: NSFetchRequest<MixDown> = MixDown.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            fetchedResultsController = NSFetchedResultsController<MixDown>(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: "date",
                cacheName: nil
            )
            try? fetchedResultsController?.performFetch()
            tableView.reloadData()
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

    // MARK: - Table View DataSource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Mix Collection", for: indexPath) as! MixCollectionTableViewCell
        let mixx = fetchedResultsController?.object(at: indexPath)
        cell.nameLabel.text = mixx?.name
        cell.dateLabel.text = DateString(String(describing: mixx!.date!))
        return cell
    }
    
    // MARK: View Controller Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Arial", size: 25.0)!, NSForegroundColorAttributeName: UIColor.darkGray]
        updateUI()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let playCell = sender as? MixCollectionTableViewCell {
            if let mpVC = segue.destination as? MixPlayTableViewController {
                if let indexPath = tableView.indexPath(for: playCell) {
                    if let mixed = fetchedResultsController?.object(at: indexPath){
                        mpVC.mix = mixed
                    }
                }
            }
        }
    }
    
}



