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
    
    var progress: Float = 0.0
    
    private func updateProgress() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let fetchRequest: NSFetchRequest<ToDoEntry> = ToDoEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date <= %@", tomorrow as NSDate)

        do {
            let checkedEntries = try context.fetch(fetchRequest)
                                            .filter { $0.isChecked == true }
            let totalEntries = try context.fetch(fetchRequest)
            self.progress = Float(checkedEntries.count) / Float(totalEntries.count)
        } catch {
            progress = 0.0
            print("error in updateProgress")
        }
        percentageLabel.text = String(format: "%.1f%%", progress * 100)
        progressBar.progress = progress
        
        
    }
    
    var uniqueDates: [DateComponents] = []
    
    private func updateUniqueDates() {
        
        uniqueDates = {
            let calendar = Calendar.current
            
            let filteredEntries: [ToDoEntry] = {
                if (Constants.ToDo.showCheckedEntries) {
                    return entries
                }
                else {
                    return entries.filter { $0.isChecked == false }
                }
            }()
            
            var dateComponents = filteredEntries.map { calendar.dateComponents([.day, .month, .year], from: $0.date!) }
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
    
    //header outlets
    @IBAction func settingsButtonClicked(_ sender: Any) {
        
    }
    
    @IBOutlet weak var streakLabel: UILabel!
    
    
    @IBOutlet weak var likesLabel: UILabel!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var percentageLabel: UILabel!
    
    
    
    @objc func newDayUpdates() {
        let fetchRequest: NSFetchRequest<ToDoEntry> = ToDoEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isChecked == true AND date < %@", NSDate())
        
        do {
            let toDelete = try context.fetch(fetchRequest)
            for entry in toDelete {
                context.delete(entry)
            }
            try context.save()
        }
        catch {
            print("error in newDayUpdate todoviewcontroller")
        }
        loadItems()
        updateUniqueDates()
        orderEntries()
        resetOrder()
        saveItems()
        ToDoTableView.reloadData()
        
    }
    
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //new day stuff
        let calendar = Calendar.current
        let midnight = calendar.startOfDay(for: Date())

        let timer = Timer(fireAt: midnight, interval: 86400, target: self, selector: #selector(newDayUpdates), userInfo: nil, repeats: true)

        RunLoop.current.add(timer, forMode: .common)
        
        ToDoTableView.dataSource = self
        
        navigationController?.navigationBar.isHidden = true
        ToDoTableView.register(UINib(nibName: Constants.ToDo.nibName, bundle: nil), forCellReuseIdentifier: Constants.ToDo.reuseIdentifier)

        ToDoTableView.separatorStyle = .none
        
        
        loadItems()
        
        updateUniqueDates()
        updateProgress()
        
        //header
        streakLabel.text = "0🔥"
        likesLabel.text = "0👏"
        
        
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
            if (cell.textView.text == "") {//if the text is blank
                let calendar = Calendar.current
                if (calendar.isDateInToday(cell.toDoEntry!.date!)) {//if its today
                    cell.isPlaceholder = true
                }
                
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
            guard let self = self else { return }
            
            self.entries[Int(cell.toDoEntry!.order)].date = newDate//set new date
            self.entries[Int(cell.toDoEntry!.order)].order = Int16(self.entries.count) //set order to max so that it'll go to the back of each section 
            self.orderEntries()
            self.resetOrder()
            self.updateUniqueDates()
            self.saveItems()
            
        }
        
        
        return cell
        
    }
    
    private func orderEntries() {
        let calendar = Calendar.current
        self.entries.sort {
            if (calendar.isDate($0.date!, equalTo: $1.date!, toGranularity: .day)) {//if same day
                
                if ($0.isChecked == $1.isChecked) {
                    return $0.order < $1.order
                }
                else {
                    return $1.isChecked
                }
                
            }
            else {//if different days
                
                return $0.date! < $1.date!
            }
        }
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
    func checkBoxPressed(in cell: ToDoEntryCell, deletion: Bool) {
        guard let indexPath = ToDoTableView.indexPath(for: cell) else {
                return
            }
        
        
        let totalIndexRow = returnPositionForThisIndexPath(indexPath: indexPath, insideThisTable: ToDoTableView)
        
        if (deletion) {
            if totalIndexRow < entries.count {
                
                context.delete(entries[totalIndexRow])
                entries.remove(at: totalIndexRow)
                
            }
            else {
                print("error in checkbox pressed, most likely due to the double deletion case where the blank cell and the checkbox of a different cell are both pressed")
                
            }
        }
        else {
            if (Constants.ToDo.showCheckedEntries) {
                entries[totalIndexRow].isChecked.toggle()
            }
            else {
                //in the context, change attribute isChecked to false for this object
                entries[totalIndexRow].isChecked = false
                context.refresh(entries[totalIndexRow], mergeChanges: true)
                entries.remove(at: totalIndexRow)
            }
            
            
        }
        orderEntries()
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
            
            try context.save()
        }
        catch {
            print("error saving context \(error)")
        }
        updateUniqueDates()
        updateProgress()
        ToDoTableView.reloadData()
    }
    

    func loadItems() {
        let request: NSFetchRequest<ToDoEntry> = ToDoEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        if (Constants.ToDo.showCheckedEntries == false) {
            request.predicate = NSPredicate(format: "isChecked == false", NSDate())
        }
        do {
            entries = try context.fetch(request)
        } catch {
            print("error fetching data from context: \(error)")
        }
    }
    
}

