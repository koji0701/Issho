//
//  ViewController.swift
//  Issho
//
//  Created by Koji Wong on 6/5/22.
//

import UIKit
import CoreData

class ToDoViewController: UIViewController{

    var entries = [ToDoEntry]()
    
    
    var uniqueDates: [DateComponents] = [] //MARK: THIS IS WRONG. STARTOFDAY IS PROBABLY WRONG ALSO ADD THE TODAY THING DIRECTLY HERE
    
    private func updateUniqueDates() {
        
        uniqueDates = {
            let calendar = Calendar.current
            var dateComponents = entries.map { calendar.dateComponents([.day, .month, .year], from: $0.date!) }
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
    

    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext //context globally for this
    
    
    @IBOutlet weak var ToDoTableView: UITableView!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        ToDoTableView.dataSource = self
        
        
        ToDoTableView.register(UINib(nibName: Constants.ToDo.nibName, bundle: nil), forCellReuseIdentifier: Constants.ToDo.reuseIdentifier)

        ToDoTableView.separatorStyle = .none

        
        
        loadItems()
        
        updateUniqueDates()
        
            
    }
}


extension ToDoViewController: UITableViewDataSource, ToDoEntryDelegate {
    
    
    
    //sections stuff
    func numberOfSections(in tableView: UITableView) -> Int {
        
        //MARK: create sections by date
        
        //return uniqueDates.count'
        print("number of sections returns ",uniqueDates.count)
        return uniqueDates.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        
        let calendar = Calendar.current
        let sectionInfo = uniqueDates[section]
        let date = calendar.date(from: sectionInfo)!
        let dayOfWeek = calendar.dateComponents([.weekday], from: date).weekday
        
        if (calendar.isDate(Date(), equalTo: date, toGranularity: .day)) {
            
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
        

        // Retrieve the entries for the specified section
        let sectionDateComponents = uniqueDates[section]
        
        let sectionEntries = entries.filter {
            let calendar = Calendar.current
            let entryDateComponents = calendar.dateComponents([.day, .month, .year], from: $0.date!)
            
            return entryDateComponents == sectionDateComponents
        }
        if (sectionEntries.count == 0) {//only case for this is if the date is today i think
            let index = returnPositionForThisIndexPath(indexPath: IndexPath(row: 0, section: section), insideThisTable: ToDoTableView)
            let newToDoEntry = ToDoEntry(context: self.context)
            initializeToDoEntry(newEntry: newToDoEntry, order: 0)
            print("index: ",index)
            entries.insert(newToDoEntry, at: index)
            resetOrder()
            saveItems()
            return 1
        }
        
        print("in section \(uniqueDates[section]), there are \(sectionEntries.count)")
        // Return the number of entries in the section
        return sectionEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ToDo.reuseIdentifier, for: indexPath) as! ToDoEntryCell
        let totalIndexRow = returnPositionForThisIndexPath(indexPath: indexPath, insideThisTable: ToDoTableView)
        
        
        cell.toDoEntry = entries[totalIndexRow]
        cell.toDoEntryDelegate = self
        cell.isPlaceholder = false
        if (ToDoTableView.numberOfRows(inSection: indexPath.section) - 1 == 0) {//if its the only cell in the section
            if (cell.textView.text == "") {//if the text is blank, meaning it must be today
                cell.isPlaceholder = true
            }
            
        }
        // set the closure
        weak var tv = tableView
        cell.textViewCallBack = { [weak self] str in
            guard let self = self, let tv = tv else { return }
            
            // update our data with the edited string
            let totalIndexRow = self.returnPositionForThisIndexPath(indexPath: indexPath, insideThisTable: tv)
            self.entries[totalIndexRow].text = str//
            // we don't need to do anything else here
            // this will force the table to recalculate row heights
            
            tv.beginUpdates()
            tv.endUpdates()//MARK: NEW METHOD FOR HEIGHT RECALC. i can probably use tableview height method
            
        }
        cell.toolbar.dateSelectedCallBack = { [weak self] newDate in
            guard let self = self, let tv = tv else { return }
            
            
            self.entries[Int(cell.toDoEntry!.order)].date = newDate
            let calendar = Calendar.current
            let newDateAsComponents = calendar.dateComponents([.day, .month, .year], from: newDate)
            
            if let destinationSection = self.uniqueDates.firstIndex(of: newDateAsComponents) {//if the newdate is already in the uniquedates array, take note of this destination section
                print("new date is already in the uniquedates, no need to make a new section")
                
                let destinationIndex = self.returnPositionForThisIndexPath(indexPath: IndexPath(row: tv.numberOfRows(inSection: destinationSection), section: destinationSection), insideThisTable: tv)//total destination index
                
                let oldPlaceForEntry = self.entries.remove(at: Int(cell.toDoEntry!.order))//remove in entries array at old index
                print("desetination index", destinationIndex)
                print("entries count (without subtracting)", self.entries.count)
                if (destinationIndex == self.entries.count+1) {//if it'll go out of bounds after removing the old place for entry;+1 is a shortcut
                    self.entries.append(oldPlaceForEntry)
                }
                else {
                    self.entries.insert(oldPlaceForEntry, at: destinationIndex)//put removed one into the new spot
                }

                self.resetOrder()//resets the order of the entries to correspond with the new location for the entries array
                self.updateUniqueDates()
                self.saveItems()//save items to context and reload the tableview
            }
            else {//if the newdate is creating a new section in the uniquedates array
                print("new date needs to make a new section")
                
                self.updateUniqueDates()//create the unique date in the array
                let destinationSection = self.uniqueDates.firstIndex(of: newDateAsComponents)
                let destinationIndex = self.returnPositionForThisIndexPath(indexPath: IndexPath(row: 0, section: destinationSection!), insideThisTable: tv)//total destination index
                let oldPlaceForEntry = self.entries.remove(at: Int(cell.toDoEntry!.order))//remove in entries array at old index

                if (destinationIndex == self.entries.count+1) {//if it'll go out of bounds after removing the old place for entry;+1 is a shortcut
                    self.entries.append(oldPlaceForEntry)
                }
                else {
                    self.entries.insert(oldPlaceForEntry, at: destinationIndex)//put removed one into the new spot
                }
                self.resetOrder()//resets the order of the entries to correspond with the new location for the entries array
                self.saveItems()//save items to context and reload the tableview
                
            }
            
        }
        
        
        return cell
        
    }
    
    
    
    private func resetOrder() {
        for (index, entry) in entries.enumerated() {
            entry.order = Int16(index)
        }
    }
    

    
    
    func createNewToDoEntryCell(in cell: ToDoEntryCell, makeFirstResponder: Bool){
        
        
        
        guard let indexPath = ToDoTableView.indexPath(for: cell) else {
            print("error in the createNewToDoEntryCell func in the ToDoViewController")
            return
        }
        
        guard let order = cell.toDoEntry?.order else {
            print("couldn't find order in the createNewToDoEntryCell func in the ToDoViewController")
            return
        }
        
        let nextIndexPath = IndexPath(row: indexPath.row+1, section: indexPath.section)
        
        
        
        let newToDoEntry = ToDoEntry(context: self.context)
        let dateComponents = uniqueDates[nextIndexPath.section]
        
        
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        initializeToDoEntry(newEntry: newToDoEntry, date: date, order: order + 1)
        entries.insert(newToDoEntry, at: Int(order+1))
        //context.insert(newToDoEntry)
        /**
        if (entries.count-1 >= order + 2) {
            for i in (Int(order)+2)...(entries.count-1) {
                entries[i].order = entries[i].order + 1
            }
        }**/
        resetOrder()
        
        
        self.saveItems()
        
        
        
        guard let nextCell = ToDoTableView.cellForRow(at: nextIndexPath) as? ToDoEntryCell else {
            print("error in the creating a new todoentry creating the next cell cellforrow")
            return
        }
        if (makeFirstResponder) {
            nextCell.textView.becomeFirstResponder()
        }
        else {
            nextCell.textView.resignFirstResponder()
        }
         
        
       
        
    }
    
    
    //deletion of todo cell
    func checkBoxPressed(in cell: ToDoEntryCell) {
        guard let indexPath = ToDoTableView.indexPath(for: cell) else {
                return
            }
        
        
        
        
        let totalIndexRow = returnPositionForThisIndexPath(indexPath: indexPath, insideThisTable: ToDoTableView)
        context.delete(entries[totalIndexRow])
        entries.remove(at: totalIndexRow)
        
        /**if (entries.count - 1 >= order ) {
            
            for i in (Int(order))...(entries.count - 1) {
                entries[i].order = entries[i].order - 1
            }
        }**/
        resetOrder()
            
        
        self.saveItems()

        
    }
    
    //for total indexpath
    private func returnPositionForThisIndexPath(indexPath:IndexPath, insideThisTable theTable:UITableView)->Int{

        var i = 0
        var rowCount = 0

        while i < indexPath.section {
            rowCount += theTable.numberOfRows(inSection: i)
            i+=1
        }

        rowCount += indexPath.row

        return rowCount
    }
    
    //rearranging
    //MARK: UNUSED
    func moveItem(start: Int, end: Int) {
        
        
        if (start > end) {
            entries[start].order = entries[end].order - 1
            for i in end...(entries.count-1) {
                entries[i].order = entries[i].order + 1
            }
        }
        if (start < end) {
            entries[start].order = entries[end].order + 1
            for i in 0...end-1 {
                entries[i].order = entries[i].order - 1
            }
        }
        
    }
    
    
    
    
    //functions to easily initialize to do entry
    
    
    func initializeToDoEntry(newEntry: ToDoEntry, text: String = "", isChecked: Bool = false, isCurrentTask: Bool = false, date: Date = Date(), time: Double = 0.0, order: Int16) {//to initialize default new one
        newEntry.text = text
        newEntry.isChecked = isChecked
        newEntry.isCurrentTask = isCurrentTask
        newEntry.date = date
        newEntry.time = time
        newEntry.order = order
    }
    
    //MARK: Model manipulation methods for coredata
    
    func saveItems() {
        
        do {
            
            entries = entries.sorted { $0.order < $1.order }//sort the entries by order
            try context.save()
        }
        catch {
            print("error saving context \(error)")
        }
        updateUniqueDates()
        ToDoTableView.reloadData()
    }
    

    func loadItems() {
        let request: NSFetchRequest<ToDoEntry> = ToDoEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        do {
            entries = try context.fetch(request)
        } catch {
            print("error fetching data from context: \(error)")
        }
    }
    
    

}




