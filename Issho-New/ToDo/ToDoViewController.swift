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


class ToDoViewController: UIViewController {

    var entries = [ToDoEntry]()
    var progress: Float = 0.0
    
    
    
    var uniqueDates: [DateComponents] = []
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext //context globally for this
    
    
    @IBOutlet weak var ToDoTableView: UITableView!
    
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var streakLabel: UILabel!
    
    //header outlets
    @IBAction func settingsButtonClicked(_ sender: Any) {
        print("settings button clicked")
    }
    
    
    @IBOutlet weak var likesLabel: UILabel!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var percentageLabel: UILabel!
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        tabBarController?.tabBar.isHidden = false
        
        
    }
    
    @objc private func userUpdate(_ notification: Notification) {
        print("user updated notification recieved", notification.object)
        //print(notification.object as? [String: Any] ?? [:])
        let info = notification.object as? [String: Any]
        let likesCount = info?["likesCount"] as? Int ?? 0
        let streak = info?["streak"] as? Int ?? 0
        likesLabel.text = String(likesCount) + "👏"
        streakLabel.text = String(streak) + "🔥"
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(userUpdate(_:)),name: NSNotification.Name ("userInfoUpdated"), object: nil)
        
        
        ToDoTableView.dataSource = self
        ToDoTableView.delegate = self
        
        navigationController?.navigationBar.isHidden = true
        ToDoTableView.register(UINib(nibName: Constants.ToDo.nibName, bundle: nil), forCellReuseIdentifier: Constants.ToDo.reuseIdentifier)

        ToDoTableView.separatorStyle = .none
        
        
        loadItems()
        
        updateUniqueDates()
        initProgressNoFirestore()
        
        
        //header
        streakLabel.font = Constants.Fonts.toDoEntrySectionHeaderFont
        likesLabel.font = Constants.Fonts.toDoEntrySectionHeaderFont
        streakLabel.text = "0🔥"
        likesLabel.text = "0👏"
        
    
        //init userIsWorking flag
        /*userIsWorking = {
            for entry in entries {
                if entry.isCurrentTask == true {
                    print("found an entry that isWorking = true")
                    return true
                }
            }
            return false
        }()*/
        //new day stuff
        Task {
            for await _ in NotificationCenter.default.notifications(named: .NSCalendarDayChanged) {
                print("day did change")
                newDayUpdates()
            }
        }
    }
    
    
}


extension ToDoViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        
        
        var sectionTitle = ""
        
        sectionTitle = {
            let year2022 = calendar.date(from: DateComponents(year: 2022))!
            let numberOfDaysSince2022 = calendar.dateComponents([.day], from: year2022, to: date).day!
            let adjustedNum = numberOfDaysSince2022 % Constants.ToDo.emojis.count
            
            
            return Constants.ToDo.emojis[adjustedNum] + " "
            //days since particular date with the modulo
            //then put emojis
        }()
        if (calendar.isDate(Date(), equalTo: date, toGranularity: .day)) {
            
            sectionTitle += "TODAY"
            return sectionTitle
        }
        if (calendar.isDate(calendar.date(byAdding: .day, value: 1, to: Date())!, equalTo: date, toGranularity: .day)) {
            
            sectionTitle += "TOMORROW"
            return sectionTitle
        }
        
        if (calendar.isDate(calendar.date(byAdding: .day, value: -1, to: Date())!, equalTo: date, toGranularity: .day)) {
            
            sectionTitle += "YESTERDAY"
            return sectionTitle
        }
        
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        
        let myLabel = UILabel()
        let text = self.tableView(tableView, titleForHeaderInSection: section)!
        myLabel.frame = CGRect(x: 20, y: 8, width: 320, height: 20)
        
        if let rangeOfSecondSpace = text.range(of: " ", options: .literal, range: text.index(text.startIndex, offsetBy: 3)..<text.endIndex, locale: nil)?.upperBound {
            let attributedString = NSMutableAttributedString(string: text)

            let startIndex = text.distance(from: text.startIndex, to: rangeOfSecondSpace)

            //attributedString.addAttribute(NSAttributedString.Key.font, value: Constants.Fonts.toDoEntrySectionHeaderFont, range: NSRange(location: 0, length: startIndex))
            
            //attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 18), range: NSRange(location: startIndex, length: text.count - startIndex + 1))
            
            attributedString.addAttribute(NSAttributedString.Key.font, value: Constants.Fonts.toDoEntrySectionHeaderFont, range: NSRange(location: 0, length: text.count+1))
            
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.gray, range: NSRange(location: startIndex, length: text.count - startIndex + 1))

            
            myLabel.attributedText = attributedString
        }
        else {
            myLabel.font = Constants.Fonts.toDoEntrySectionHeaderFont
            myLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        }
        let headerView = UIView()
        headerView.addSubview(myLabel)
        return headerView
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
        cell.textView.font = Constants.Fonts.toDoEntryCellFont

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
        
    }
    

    func loadItems() {
        let request: NSFetchRequest<ToDoEntry> = ToDoEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        if (Constants.Settings.showCompletedEntries == false) {
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
        if (cell.toDoEntry?.isCurrentTask == true) {//if deleting a current task, then make sure to set it to false and update the is working
            entries[totalIndexRow].isCurrentTask = false
            updateIsWorking()
        }
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
            if (Constants.Settings.showCompletedEntries == true) {
                entries[totalIndexRow].isChecked.toggle()
            }
            else {
                //in the context, change attribute isChecked to true for this object
                entries[totalIndexRow].isChecked = true
                entries.remove(at: totalIndexRow)
            }
            
            
        }
        
        orderEntries()
        
        updateProgress()
        
        
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
            if (Constants.Settings.showCompletedEntries == true) {
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
        
        updateProgress()
        
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
            
        self.updateProgress()
            
            
    }
    
    func updateIsCurrentTask(in cell: ToDoEntryCell, isCurrentTask: Bool) {
        print("updateIsCurrentTask working")
        
        self.entries[Int(cell.toDoEntry!.order)].isCurrentTask = isCurrentTask//set current Task
        
        updateIsWorking()
        
        
    }
}

extension ToDoViewController {//all helper funcs for organization
    
    private func updateIsWorking() {
        let currentTasks = entries.filter { $0.isCurrentTask == true }
        //currenttasks count > 0 means currently working
        //isWorking == true means is working
        //logic: if both are true, or both are false, then this code block will not run because I need to make sure that the updateUserInfo only happens when its needed
        if (currentTasks.count > 0) != (User.shared().userInfo["isWorking"] as? Bool == true) {
            print("updateIsCurrentTask: will update current task in the User")
            User.shared().updateUserInfo(newInfo: ["isWorking": !(User.shared().userInfo["isWorking"] as? Bool ?? false)])
        }
    }
    
    private func initProgressNoFirestore() {
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
        percentageLabel.text = String(format: "%.f", progress * 100) + "%"
        progressBar.progress = progress
    }

    private func updateProgress() {
        
        
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
        percentageLabel.text = String(format: "%.f%%", progress * 100)
        progressBar.progress = progress
        
        User.shared().updateUserInfo(newInfo: ["progress": progress])
        
        /*
        
        // invalidate the timer if it's already running
        updateProgressTimer?.invalidate()
        
        // start a new timer
        updateProgressTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { [weak self] _ in
            // this block of code will be executed 1 minute after `updateProgress` was last called
            guard let self = self else {return}
            guard let uid = Auth.auth().currentUser?.uid else {
                print("could not find uid for currentuser in the todoviewcontroller")
                return
            }
            print("updateProgressTimer function is running")
            //while im doing a write operation, i might as well update the isCurrent bc no cost
            self.updateIsWorkingTimer?.invalidate()//if im doing updates in here, then i might as well invalidate that one bc i can write it in here anyways. this will help reduce writes in cases wehre isCurrent is changed after the progress
            print("in the updateProgressTimer function, updateIsWorkingTimer function is invalidated")
            let entryIsWorking: Bool = {
                for entry in self.entries {
                    if entry.isCurrentTask == true {
                        print("found an entry that isWorking = true")
                        return true
                    }
                }
                return false
            }()
            self.userIsWorking = entryIsWorking//update flag
           
            if (self.updateProgressShouldBeLastUpdatedFlag == true) {
                Firestore.updateUserInfo(uid: uid, fields: ["likes": [String](), "lastUpdated": FieldValue.serverTimestamp(), "progress": self.progress, "isWorking": entryIsWorking])//batch updates
                self.updateProgressShouldBeLastUpdatedFlag = false
            }
            else {
                Firestore.updateUserInfo(uid: uid, fields: ["progress": self.progress, "isWorking": entryIsWorking])
            }
        }*/
    }
    
    private func updateUniqueDates() {
        
        uniqueDates = {
            let calendar = Calendar.current
            
            let filteredEntries: [ToDoEntry] = {
                if (Constants.Settings.showCompletedEntries == true) {
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
                    return Constants.Settings.showCompletedEntries //if show checked entries is true, then returning true -> placeholder goes to top
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
            if (Constants.Settings.showCompletedEntries == true) {
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
        
        updateProgress()
        
        //for streak
        let calendar = Calendar.current
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: Date())!
        
        if (entries[0].date! <= twoDaysAgo) {//if the first entry's date is less than or equal to two days ago from the start of the new day
            
            User.shared().updateUserInfo(newInfo: ["likes": [String](), "likesCount": 0, "streak": 0, "progress": progress])
            
        }
        else {
            User.shared().updateUserInfo(newInfo: ["likes": [String](), "likesCount": 0, "streak": FieldValue.increment(1.0), "progress": progress])
            
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
    
   
}//helper funcs

extension ToDoViewController: SettingsToDoViewControllerDelegate {
    
    func refreshTableView() {//MARK: THIS ISN'T WORKING CORRECTLY. RETHINK THE LOADITEMS?
        loadItems()
        saveItems()
    }
}


