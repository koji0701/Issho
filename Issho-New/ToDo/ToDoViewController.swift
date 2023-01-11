//
//  ViewController.swift
//  Issho
//
//  Created by Koji Wong on 6/5/22.
//

import UIKit
import CoreData
import FirebaseFirestore
import FirebaseAuth


class ToDoViewController: UIViewController{

    var entries = [ToDoEntry]()
    
    var progress: Float = 0.0
    
    private var updateTimer: Timer?
    
    var uniqueDates: [DateComponents] = []
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext //context globally for this
    
    
    @IBOutlet weak var ToDoTableView: UITableView!
    
    //header outlets
    @IBAction func settingsButtonClicked(_ sender: Any) {
        
    }
    
    @IBOutlet weak var streakLabel: UILabel!
    
    
    @IBOutlet weak var likesLabel: UILabel!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var percentageLabel: UILabel!
    

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
       
        
        ToDoTableView.dataSource = self
        
        navigationController?.navigationBar.isHidden = true
        ToDoTableView.register(UINib(nibName: Constants.ToDo.nibName, bundle: nil), forCellReuseIdentifier: Constants.ToDo.reuseIdentifier)

        ToDoTableView.separatorStyle = .none
        
        
        loadItems()
        
        updateUniqueDates()
        updateProgress(shouldBeLastUpdated: false)
        
        //header
        streakLabel.text = "0🔥"
        likesLabel.text = "0👏"
        
        //new day stuff
        Task {
            for await _ in NotificationCenter.default.notifications(named: .NSCalendarDayChanged) {
                print("day did change")
                newDayUpdates()
            }
        }
    }
    
    
}


extension ToDoViewController: UITableViewDataSource {
    
    //sections stuff
    func numberOfSections(in tableView: UITableView) -> Int {
        
        //MARK: create sections by date
        
        //return uniqueDates.count'
        return uniqueDates.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        
        let calendar = Calendar.current
        let sectionInfo = uniqueDates[section]
        
        guard let date = calendar.date(from: sectionInfo) else {
            print("date could not be found in titleforheaderinsection")
            return ""
        }
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
        
        
        
        return sectionTitle
    }
    

    //table view methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        // Retrieve the entries for the specified section
        let sectionDateComponents = uniqueDates[section]
        let calendar = Calendar.current
        let sectionEntries = entries.filter {
            
            let entryDateComponents = calendar.dateComponents([.day, .month, .year], from: $0.date!)
            
            return entryDateComponents == sectionDateComponents
        }
        
        if (sectionDateComponents != calendar.dateComponents([.day, .month, .year], from: Date())) {
            // Return the number of entries in the section
            return sectionEntries.count
        }
        
        if (sectionEntries.count == 0) {
            let index = returnPositionForThisIndexPath(indexPath: IndexPath(row: sectionEntries.count, section: section), insideThisTable: ToDoTableView)
            let newToDoEntry = ToDoEntry(context: self.context)
            initializeToDoEntry(newEntry: newToDoEntry, order: 0, isPlaceholder: true)
            entries.insert(newToDoEntry, at: index)
            resetOrder()
            saveItems()
            return sectionEntries.count
        }
        
        return sectionEntries.count//safety
    }
        
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ToDo.reuseIdentifier, for: indexPath) as! ToDoEntryCell
        let totalIndexRow = returnPositionForThisIndexPath(indexPath: indexPath, insideThisTable: ToDoTableView)
        
        
        cell.toDoEntry = entries[totalIndexRow]
        cell.toDoEntryDelegate = self
        cell.toolbar = ToDoEntryToolbar(setDate: entries[totalIndexRow].date!, isCurrentTask: entries[totalIndexRow].isCurrentTask)
        cell.styleTextView(isCurrent: entries[totalIndexRow].isCurrentTask)
        
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
            tv.endUpdates()//height recalculation
            
        }
        return cell

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
        //updateProgress()
        ToDoTableView.reloadData()
        print(entries)
    }
    

    func loadItems() {
        let request: NSFetchRequest<ToDoEntry> = ToDoEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        if (Constants.ToDo.showCheckedEntries == false) {
            request.predicate = NSPredicate(format: "isChecked == false")
        }
        do {
            entries = try context.fetch(request)
            
        } catch {
            print("error fetching data from context: \(error)")
        }
    }
    
}


//MARK: TODOENTRY DELEGATE
extension ToDoViewController: ToDoEntryDelegate {
    //command order entries
    func commandOrderEntries() {
        orderEntries()
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
            entries[totalIndexRow].isPlaceholder = false//assure that the placeholder is false
            if (Constants.ToDo.showCheckedEntries == true) {
                entries[totalIndexRow].isChecked.toggle()
            }
            else {
                //in the context, change attribute isChecked to true for this object
                entries[totalIndexRow].isChecked = true
                entries.remove(at: totalIndexRow)
            }
            
            
        }
        
        orderEntries()
        
        updateProgress(shouldBeLastUpdated: !deletion)//if deletion true, then don't be last updated since its just deleting one
        
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
        
        guard let isPlaceholder = cell.toDoEntry?.isPlaceholder else {
            print("couldn't find isplaceholder in createnewtodoentrycell func in todoviewcontroller")
            return
        }
        
        let nextIndexPath = IndexPath(row: indexPath.row+1, section: indexPath.section)
        
        
        
        let newToDoEntry = ToDoEntry(context: self.context)
        let dateComponents = uniqueDates[nextIndexPath.section]
        
        
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        
        
        
        if (isPlaceholder == true) {
            let totalIndexPath = returnPositionForThisIndexPath(indexPath: indexPath, insideThisTable: ToDoTableView)
            entries[totalIndexPath].isPlaceholder = false
            if (Constants.ToDo.showCheckedEntries == true) {
                initializeToDoEntry(newEntry: newToDoEntry, date: date, order: order - 1, isPlaceholder: true)
                entries.insert(newToDoEntry, at: Int(order))//insert it above the current if showcheckedentries is true
            }
            
            else {
                initializeToDoEntry(newEntry: newToDoEntry, date: date, order: order + 1, isPlaceholder: false)
                entries.insert(newToDoEntry, at: Int(order+1))//insert below if not showing the checked entries
            }
        }
        else {
            initializeToDoEntry(newEntry: newToDoEntry, date: date, order: order + 1, isPlaceholder: false)
            entries.insert(newToDoEntry, at: Int(order+1))//insert below if not showing the checked entries//insert below if placeholder isn't true
        }
        
        
        resetOrder()
        
        updateProgress(shouldBeLastUpdated: false)//no celebrating creating new ones
        
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
    
    
    
    func updateDate(in cell: ToDoEntryCell, newDate: Date) {
        
        print("updateDate delegate working")
        self.entries[Int(cell.toDoEntry!.order)].date = newDate//set new date
        if (cell.toDoEntry?.isPlaceholder == true) {
            self.entries[Int(cell.toDoEntry!.order)].isPlaceholder = false
        }
        self.entries[Int(cell.toDoEntry!.order)].order = Int16(self.entries.count) //set order to max so that it'll go to the back of each section
        self.orderEntries()
            
        self.updateProgress(shouldBeLastUpdated: false)
            
            
    }
    
    func updateToolbarAttributesExceptDate(in cell: ToDoEntryCell, isCurrentTask: Bool) {
        print("updateToolbarAttributesExceptDate working")
        
        self.entries[Int(cell.toDoEntry!.order)].isCurrentTask = isCurrentTask//set current Task
        
    }
}

extension ToDoViewController {//all helper funcs for organization
    
    

    private func updateProgress(shouldBeLastUpdated: Bool) {
        
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let fetchRequest: NSFetchRequest<ToDoEntry> = ToDoEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date <= %@", tomorrow as NSDate)

        do {
            let checkedEntries = try context.fetch(fetchRequest)
                                            .filter { $0.isChecked == true }
            let totalEntries = try context.fetch(fetchRequest).filter {$0.isPlaceholder == false}
            //account for the isPlaceholder cell
            
            self.progress = Float(checkedEntries.count) / Float(totalEntries.count)
            if (self.progress.isNaN == true) {
                self.progress = 1.0//if not a number set to 1.0
            }

        } catch {
            progress = 0.0
            print("error in updateProgress")
        }
        percentageLabel.text = String(format: "%.1f%%", progress * 100)
        progressBar.progress = progress
        
        // invalidate the timer if it's already running
        updateTimer?.invalidate()
        
        // start a new timer
        updateTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { [weak self] _ in
            // this block of code will be executed 1 minute after `updateProgress` was last called
            guard let uid = Auth.auth().currentUser?.uid else {
                print("could not find uid for currentuser in the todoviewcontroller")
                return
            }
            
            if (shouldBeLastUpdated == true) {
                Firestore.updateUserInfo(uid: uid, fields: ["likes": [String](), "lastUpdated": FieldValue.serverTimestamp(), "progress": self?.progress ?? 0.0])//batch updates
            }
            else {
                Firestore.updateUserInfo(uid: uid, field: "progress", value: self?.progress ?? 0.0)
            }
            
            
        }
    }
    
    private func updateUniqueDates() {
        
        uniqueDates = {
            let calendar = Calendar.current
            
            let filteredEntries: [ToDoEntry] = {
                if (Constants.ToDo.showCheckedEntries == true) {
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
    
    private func orderEntries() {
        let calendar = Calendar.current
        self.entries.removeAll(where: {($0.text == "" || $0.text == "⚡️") && $0.isPlaceholder == false})//removes all unnecessary ones
        
        self.entries.sort {
            if (calendar.isDate($0.date!, equalTo: $1.date!, toGranularity: .day)) {//if same day
                if ($0.isPlaceholder == true) {//if its the placeholder
                    return Constants.ToDo.showCheckedEntries //if show checked entries is true, then returning true -> placeholder goes to top
                }
                if ($0.isCurrentTask != $1.isCurrentTask) {//if only one is a current task
                    return $0.isCurrentTask
                }
                else if ($0.isChecked == $1.isChecked) {//if both are current task, both must be checked so always this. if both aren't current task, this checks checking status
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
        let placeholder = self.entries.filter({$0.isPlaceholder == true})
        if (placeholder.count == 0)  {//if there's no placeholders
            let newToDoEntry = ToDoEntry(context: self.context)
            initializeToDoEntry(newEntry: newToDoEntry, order: 0, isPlaceholder: true)
            if (Constants.ToDo.showCheckedEntries == true) {
                //insert at top of today's section
                if let index = entries.firstIndex(where: {calendar.isDate($0.date!, equalTo: Date(), toGranularity: .day)}) {//case where there is 0 index in today is already handled by the tableview sections stuff
                    entries.insert(newToDoEntry, at: index)
                }
                
            }
            else {
                //insert at bottom of today's section
                if let index = entries.lastIndex(where: {calendar.isDate($0.date!, equalTo: Date(), toGranularity: .day)}) {
                    entries.insert(newToDoEntry, at: index + 1)
                }
            }
        }
        resetOrder()//i always run this
        saveItems()//i always run this
        
    }
    
    
    private func resetOrder() {
        for (index, entry) in entries.enumerated() {
            entry.order = Int16(index)
        }
    }
    
    //functions to easily initialize to do entry
    
    
    private func initializeToDoEntry(newEntry: ToDoEntry, text: String = "", isChecked: Bool = false, isCurrentTask: Bool = false, date: Date = Date(), time: Double = 0.0, order: Int16, isPlaceholder: Bool = false) {//to initialize default new one
        newEntry.text = text
        newEntry.isChecked = isChecked
        newEntry.isCurrentTask = isCurrentTask
        newEntry.date = date
        newEntry.time = time
        newEntry.order = order
        newEntry.isPlaceholder = isPlaceholder
    }
    
    private func newDayUpdates() {
        let fetchRequest: NSFetchRequest<ToDoEntry> = ToDoEntry.fetchRequest()
        let predicate1 = NSPredicate(format: "isChecked == true AND date < %@", NSDate())
        let predicate2 = NSPredicate(format: "isPlaceholder == true")//get rid of the old placeholder
        let compoundPredicate = NSCompoundPredicate(type: .or, subpredicates: [predicate1, predicate2])
        fetchRequest.predicate = compoundPredicate
        print("new day update")
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
        
        orderEntries()//new placeholder will be added back in here
        
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("could not find uid for currentuser in the todoviewcontroller")
            return
        }
        
        updateProgress(shouldBeLastUpdated: false)
        
        //for streak
        let calendar = Calendar.current
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: Date())!
        
        if (entries[0].date! <= twoDaysAgo) {//if the first entry's date is less than or equal to two days ago from the start of the new day
            Firestore.updateUserInfo(uid: uid, fields: ["likes": [String](), "likesCount": 0, "streak": 0])
            
        }
        else {
            Firestore.updateUserInfo(uid: uid, fields: ["likes": [String](), "likesCount": 0, "streak": FieldValue.increment(1.0)])
            
        }
        
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
}
