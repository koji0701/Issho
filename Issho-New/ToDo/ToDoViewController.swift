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
    var entries = [ToDoEntry]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext //context globally for this

    //coredata stuff for the tableview sections by date
    //MARK: question: should this be included in the loaditems() function?
    private lazy var fetchedResultsController: NSFetchedResultsController<ToDoEntry> = {
            let fetchRequest: NSFetchRequest<ToDoEntry> = ToDoEntry.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

            let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                      managedObjectContext: self.context,
                                                                      sectionNameKeyPath: "date",
                                                                      cacheName: nil)
            fetchedResultsController.delegate = self
            return fetchedResultsController
        }()
    @IBOutlet weak var ToDoTableView: UITableView!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        ToDoTableView.dataSource = self
        ToDoTableView.register(UINib(nibName: Constants.ToDo.nibName, bundle: nil), forCellReuseIdentifier: Constants.ToDo.reuseIdentifier)
        
        loadItems()
        

    }
}


extension ToDoViewController: UITableViewDataSource, ToDoEntryDelegate, NSFetchedResultsControllerDelegate {
    
    
    
    //sections stuff
    func numberOfSections(in tableView: UITableView) -> Int {
        
        //MARK: create sections by date
        
        if ((fetchedResultsController.sections?.count) != nil) {
            print("using sections")
            return fetchedResultsController.sections!.count
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sections = fetchedResultsController.sections else {
            print("nil sections")
            return nil
        }
        print("got a section")
        let sectionInfo = sections[section]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm/dd"
        let date = dateFormatter.date(from: sectionInfo.name)
        //MARK: change here for title for header
        
        return dateFormatter.string(from: date ?? Date())
        
    }
    
    
    //table view methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if (entries.count == 0) {//intial entry always
             let newToDoEntry = ToDoEntry(context: self.context)
             initializeToDoEntry(newEntry: newToDoEntry)
             
             entries.append(newToDoEntry)
             self.saveItems()
        }
        return entries.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ToDo.reuseIdentifier, for: indexPath) as! ToDoEntryCell
        cell.toDoEntry = entries[indexPath.row]
        cell.toDoEntryDelegate = self
        
        return cell
        
    }
    
    //MARK: did select row at functions
    /** temporarily removing the part about is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //entries[indexPath.row].isSelected = true
        //MARK: call selected functions in the entries instead
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        //entries[indexPath.row].isSelected = false
    }**/
    
    //create new todoentry cell
    
    func createNewToDoEntryCell(in cell: UITableViewCell) -> ToDoEntryCell {
        
        guard let indexPath = ToDoTableView.indexPath(for: cell) else {
            print("error in the returnKeyPressed func in the ToDoViewController")
            return cell as! ToDoEntryCell
        }
        
        let nextIndexPath = IndexPath(row: indexPath.row+1, section: indexPath.section)
        
        //preparing the previous cell
        //entries[indexPath.row].isLastCell = false
        
        //MARK: call function to signify that previous cell is now no longer the last cell
        
        let currentCell = cell as! ToDoEntryCell
        entries[indexPath.row].text = currentCell.textView.text!
        currentCell.toDoEntry = entries[indexPath.row]
        //MARK: idk if this is needed anymore because of the savecontext protocol
        
        //creating the new cell

        //let toDoEntryDictionary: [String: Any] = ["text": "", "date": "test1", "time": 10, "isCurrentTask": false, "isLastCell": nextIndexPath.row == entries.count]//MARK: OLD INFO FOR THE TODOENTRY
        
        
        
        let newToDoEntry = ToDoEntry(context: self.context)
        
        initializeToDoEntry(newEntry: newToDoEntry)
        
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
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm/dd"
          // the string to be converted
        print("entry \(indexPath.row) has the text \(currentCell.dateTextField.text!)")
        print("date variable is \(dateFormatter.date(from: currentCell.dateTextField.text!))")
        if let date = dateFormatter.date(from: currentCell.dateTextField.text!) {
            entries[indexPath.row].date = date
            
        }
        else {
            entries[indexPath.row].date = Date()//MARK: this is temporary as case for no text in date textfield. change this to match the current section
        }
        
        print("entry \(indexPath.row) has the date \(entries[indexPath.row].date)")
        
        
        self.saveItems()
       
    }
    
    
    
    //functions to easily initialize to do entry
    func initializeToDoEntry(newEntry: ToDoEntry) {
        newEntry.text = ""
        newEntry.isChecked = false
        newEntry.isCurrentTask = false
        newEntry.date = Date()//TEMPORARY FIX THIS
        newEntry.time = 0.0
    }
    
    func initializeToDoEntry(newEntry: ToDoEntry, text: String = "", isChecked: Bool = false, isCurrentTask: Bool = false, date: Date = Date(), time: Double?) {//to initialize default new one
        newEntry.text = text
        newEntry.isChecked = isChecked
        newEntry.isCurrentTask = isCurrentTask
        newEntry.date = date //TEMPORARY FIX THIS
        newEntry.time = time ?? 0.0
    }
    
    //MARK: Model manipulation methods for coredata
    
    func saveItems() {
        do {
            try context.save()
        }
        catch {
            print("error saving context \(error)")
        }
        
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




