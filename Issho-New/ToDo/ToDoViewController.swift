//
//  ViewController.swift
//  Issho
//
//  Created by Koji Wong on 6/5/22.
//

import UIKit
import CoreData

class ToDoViewController: UIViewController{

    
    //var entries = ToDoEntry.toDoEntryList.sorted(byKeyPath: NSDate, ascending: true)
    //all wrong here
    var entries = [ToDoEntry]() {
        didSet {
            
            uniqueDates = {
                print("unique dates set")
                let calendar = Calendar.current
                var dateComponents = entries.map { calendar.dateComponents([.day, .month, .year], from: $0.date ?? Date()) }
                dateComponents.append(calendar.dateComponents([.day, .month, .year], from: Date()))
                let rV = Set(dateComponents).sorted {
                  if $0.year != $1.year {
                    return $0.year! < $1.year!
                  } else if $0.month != $1.month {
                    return $0.month! < $1.month!
                  } else {
                    return $0.day! < $1.day!
                  }
                }
                return rV

            }()
        }
    }
    
    var uniqueDates: [DateComponents] = [] //MARK: THIS IS WRONG. STARTOFDAY IS PROBABLY WRONG ALSO ADD THE TODAY THING DIRECTLY HERE
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext //context globally for this
    
    

    //coredata stuff for the tableview sections by date
    //MARK: question: should this be included in the loaditems() function?
    /**lazy var fetchedResultsController: NSFetchedResultsController<ToDoEntry> = {
            let fetchRequest: NSFetchRequest<ToDoEntry> = ToDoEntry.fetchRequest()
            
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true, comparator: { (d1, d2) -> ComparisonResult in
                let calendar = Calendar.current
                let date1 = d1 as! Date
                let date2 = d2 as! Date
                
                if (calendar.isDate(date1, equalTo: date2, toGranularity: .day)) {
                    return .orderedSame
                }
                else if (date1 > date2) {
                    return .orderedDescending
                }
                return .orderedAscending
                
            })]
    
        

            let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                      managedObjectContext: self.context,
                                                                      sectionNameKeyPath: "date",
                                                                      cacheName: nil)
            fetchedResultsController.delegate = self
            return fetchedResultsController
        }()**/
    
    
    @IBOutlet weak var ToDoTableView: UITableView!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        ToDoTableView.dataSource = self
        ToDoTableView.register(UINib(nibName: Constants.ToDo.nibName, bundle: nil), forCellReuseIdentifier: Constants.ToDo.reuseIdentifier)
        
        loadItems()
        
        
            
    }
}


extension ToDoViewController: UITableViewDataSource, ToDoEntryDelegate {
    
    //sections stuff
    func numberOfSections(in tableView: UITableView) -> Int {
        
        //MARK: create sections by date
        print("unique dates count ", uniqueDates.count)
        //return uniqueDates.count
        return uniqueDates.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        
        let calendar = Calendar.current
        let sectionInfo = uniqueDates[section]
        let date = calendar.date(from: sectionInfo)!
        let dayOfWeek = calendar.dateComponents([.weekday], from: date).weekday
        
        if (calendar.isDate(Date(), equalTo: date, toGranularity: .day)) {
            print("date is today")
            return "TODAY"
        }
        
        var sectionTitle = ""
        switch dayOfWeek {
        case 1:
            sectionTitle += "Sunday"
        case 2:
            sectionTitle += "Monday"
        case 3:
            sectionTitle += "Tuesday"
        case 4:
            sectionTitle += "Wednesday"
        case 5:
            sectionTitle += "Thursday"
        case 6:
            sectionTitle += "Friday"
        case 7:
            sectionTitle += "Saturday"
        default:
            fatalError("ERROR IN TO DO TABLEVIEW FOR SECTION HEADEER BECAUSE DAY OF THE WEEK ISN'T VALID")
        }
        sectionTitle += " \(sectionInfo.month!)/\(sectionInfo.day!)"
        
       
        //MARK: change here for title for header
        
        //return dateFormatter.string(from: sectionInfo )
        return sectionTitle
    }
    
    
    //table view methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (entries.count == 0) {
            let newToDoEntry = ToDoEntry(context: self.context)
            initializeToDoEntry(newEntry: newToDoEntry)

            entries.append(newToDoEntry)
            self.saveItems()
        }

        // Retrieve the entries for the specified section
        let sectionDateComponents = uniqueDates[section]
        
        let sectionEntries = entries.filter {
            let calendar = Calendar.current
            let entryDateComponents = calendar.dateComponents([.day, .month, .year], from: $0.date!)
            print("section entries", sectionEntries)
            return entryDateComponents == sectionDateComponents
        }

        // Return the number of entries in the section
        print("section entries count", sectionEntries.count)
        return sectionEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ToDo.reuseIdentifier, for: indexPath) as! ToDoEntryCell
        cell.toDoEntry = entries[indexPath.row]
        cell.toDoEntryDelegate = self
        
        // set the closure
        weak var tv = tableView
        cell.textViewCallBack = { [weak self] str in
            guard let self = self, let tv = tv else { return }
            
            // update our data with the edited string
            self.entries[indexPath.row].text = str
            // we don't need to do anything else here
            // this will force the table to recalculate row heights
            tv.performBatchUpdates(nil)//MARK: THIS IS REALLY EXPENSIVE. FIX THIS BY GOING TO THE TEXTVIEWDIDCHANGE IN THE TODOENTRYCELL AND HAVING THIS ONE ONLY BE CALLED EVERY CERTAIN AMT OF CHARACTERS OR FIND A DIFFERENT WAY TO ONLY RECALC HEIGHTS
            
        }
        
        
        return cell
        
    }
    
    
    
    //create new todoentry cell
    /**MARK PRIME: CONTINUE HERE. I THINK I NEED TO REDO THE CREATE NEW TO DO ENTRY CELL SO THAT IT DOESN'T CREATE THE CELL HERE BUT JUST PUTS THE INFO THEN DOES SELF.SAVEITEMS TO RELOAD THE TABLEVIEW. MODIFY THE TODOENTRYCELL SWIFT FILE TO ACCOUNT FOR THIS. ALSO, FIGURE OUT HOW TO DO THE RESIGN FIRST RESPONDER ONCE THIS METHOD IS PUT IN PLACE (IQKEYBOARD MANAGER CAN HELP?)
    
    
    ONCE THIS IS DONE, FIGURE OUT HOW TO MANAGE THE ENTRIES ARRAY BECAUSE OF THE NEW SECTIONS/DATES THING. MY BEST IDEA SO FAR IS TO HAVE EVERYTHING IN THE ENTRIES ARRAY ALREADY BE IN ORDER (I CAN SORT IT BY DATE IN THE DIDSET I ALREADY HAVE). KEEP IN MIND ADDING/DELETION/MAKING NEW SECTIONS **/
    
    
    
    func createNewToDoEntryCell(in cell: UITableViewCell) -> ToDoEntryCell {
        
        guard let indexPath = ToDoTableView.indexPath(for: cell) else {
            print("error in the returnKeyPressed func in the ToDoViewController")
            return cell as! ToDoEntryCell
        }
        
        let nextIndexPath = IndexPath(row: indexPath.row+1, section: indexPath.section)
        
        //preparing the previous cell
        //entries[indexPath.row].isLastCell = false
        
        //MARK: REMOVED: SOME CODE THAT SAID TO UPDATE THE TODOENTRY TEXT CURRENTCELL OR SMTH. REDUNDANT, SO REMOVED
    
        
        
        //creating the new cell

        //let toDoEntryDictionary: [String: Any] = ["text": "", "date": "test1", "time": 10, "isCurrentTask": false, "isLastCell": nextIndexPath.row == entries.count]//MARK: OLD INFO FOR THE TODOENTRY
        
        
        
        let newToDoEntry = ToDoEntry(context: self.context)
        let dateComponents = uniqueDates[nextIndexPath.section]
        
        
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        initializeToDoEntry(newEntry: newToDoEntry, date: date)
        
        entries.insert(newToDoEntry, at: nextIndexPath.row)
        self.saveItems()
        ToDoTableView.beginUpdates()
        ToDoTableView.insertRows(at: [nextIndexPath], with: .automatic)
        ToDoTableView.endUpdates()
        //ToDoTableView.reloadRows(at: [nextIndexPath], with: .automatic)
        
        guard let nextCell = ToDoTableView.cellForRow(at: nextIndexPath) as? ToDoEntryCell else {
            print("error in the creating a new todoentry creating the next cell cellforrow")
            return cell as! ToDoEntryCell
        }
        
        return nextCell
        
    }
    
    
    //deletion of todo cell
    func checkBoxPressed(in cell: UITableViewCell) {
        guard let indexPath = ToDoTableView.indexPath(for: cell) else {
                return
            }
        if (entries.count > 1) {
            context.delete(entries[indexPath.row])
            entries.remove(at: indexPath.row)
            
            saveItems()
            
            ToDoTableView.beginUpdates()
            ToDoTableView.deleteRows(at:[indexPath], with: .automatic)
            ToDoTableView.endUpdates()

        }
    }
    
    //updating context after done editing
    func saveInfoToContext(in cell: UITableViewCell) {
        guard let indexPath = ToDoTableView.indexPath(for: cell) else {
            print("error getting indexpath in the saveInfoToContext")
            return
        }
        let currentCell = cell as! ToDoEntryCell
        
        entries[indexPath.row].text = currentCell.textView.text!//update with more info later on such as date etc.
        
        
        
        //MARK: IDK IF I NEED THIS SECTION ANYMORE BC IM ALREADY UPDATING
        self.saveItems()
       
    }
    
    
    
    //functions to easily initialize to do entry
    
    
    func initializeToDoEntry(newEntry: ToDoEntry, text: String = "", isChecked: Bool = false, isCurrentTask: Bool = false, date: Date = Date(), time: Double = 0.0) {//to initialize default new one
        newEntry.text = text
        newEntry.isChecked = isChecked
        newEntry.isCurrentTask = isCurrentTask
        newEntry.date = date //TEMPORARY FIX THIS
        newEntry.time = time
    }
    
    //MARK: Model manipulation methods for coredata
    
    func saveItems() {
        do {
            try context.save()
        }
        catch {
            print("error saving context \(error)")
        }
        ToDoTableView.reloadData()
        
    }

    func loadItems() {
        let request: NSFetchRequest<ToDoEntry> = ToDoEntry.fetchRequest()
        do {
            entries = try context.fetch(request)
        } catch {
            print("error fetching data from context: \(error)")
        }
    }
    
    

}




