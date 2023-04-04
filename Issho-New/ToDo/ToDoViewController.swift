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
import IQKeyboardManagerSwift


class ToDoViewController: UIViewController {
    
    let defaults = UserDefaults.standard

    var entries = [ToDoEntry]()
    var progress: Float = 0.0 {
        didSet {
            percentageLabel.text = String(format: "%.f%%", progress * 100)
            customProgressBar.progress = CGFloat(progress)
        }
    }
    //MARK: There are some issues with the pulsing and the flow animation with the current. its mostly with the current working thing. when date change, it doesn't update correctly. make sure that this updates correctly. also, switch current from a text base thing to a switching the ui of the checkbox.
    //error num 2: error for the placeholder where if the placeholder has text in it, it just resets. needs to make a new one. this also happens with the current
    
    
    
    var uniqueDates: [DateComponents] = []
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext //context globally for this
    
    @IBOutlet weak var greeting: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    @IBOutlet weak var headerView: RoundedShadowView!
    
    @IBOutlet weak var streakLabel: UILabel!
    
    @IBOutlet weak var customProgressBar: GradientHorizontalProgressBar!
    
    
    @IBOutlet weak var likesLabel: UILabel!
    
    
    @IBOutlet weak var percentageLabel: UILabel!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("navigation controller ", navigationController)
        navigationController?.setNavigationBarHidden(true, animated: true)
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.backItem?.title = ""
        navigationController?.navigationBar.barTintColor = .clear
        
        navigationController?.hidesBarsOnSwipe = true
        //updateIsWorking()
        
    }
    
    @objc private func userUpdate(_ notification: Notification) {
        print("user updated notification recieved", notification.object)
        //print(notification.object as? [String: Any] ?? [:])
        var info = notification.object as? UserInfo
        let likesCount = info?.likesCount as? Int ?? 0
        let streak = info?.streak as? Int ?? 0
        let fProgress = info?.progress as? Float ?? 0.0
        let streakIsLate = info?.streakIsLate as? Bool ?? false
        
        
        
        
        likesLabel.text = String(likesCount) + "🎉"
        streakLabel.text = String(streak) + "🔥"
        if (streakIsLate == true) {
            streakLabel.text! += "⏳"
        }
        
        /*
        if (progress > fProgress) { //if there was a firestore update pushing the progress to 0, then make sure too reupdate firestore + allow for a like
            taskCompleted()
        }*/
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(userUpdate(_:)),name: NSNotification.Name ("userInfoUpdated"), object: nil)
        
        //newDayUpdates()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: Constants.ToDo.nibName, bundle: nil), forCellReuseIdentifier: Constants.ToDo.reuseIdentifier)

        tableView.separatorStyle = .none
        
        loadItems(completion: {
            self.orderEntries()
            self.initProgressNoFirestore()

        })
                
        
        //header
        streakLabel.font = Constants.Fonts.navigationBarTitleFont
        likesLabel.font = Constants.Fonts.navigationBarTitleFont
        percentageLabel.font = Constants.Fonts.toDoEntrySectionHeaderFont
        greeting.font = Constants.Fonts.navigationBarTitleFont
        streakLabel.text = "0🔥"
        likesLabel.text = "0"
        likesLabel.isUserInteractionEnabled = true
        let likesTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSegueToProfileList(_:)))
        likesLabel.addGestureRecognizer(likesTapGesture)
        
        setGreetingMessage()
        initProgressBarFlowAnimation()
        
        
    }
    
    @objc private func handleSegueToProfileList(_ sender: UITapGestureRecognizer) {
        print("should handle segue")
        performSegue(withIdentifier: Constants.Segues.toDoToProfileList, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let profileListVC = segue.destination as? ProfileListVC {
            profileListVC.displayMode = 0
            print("todovc is the destination")
            
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
        /*
        sectionTitle = {
            let year2022 = calendar.date(from: DateComponents(year: 2022))!
            let numberOfDaysSince2022 = calendar.dateComponents([.day], from: year2022, to: date).day!
            let adjustedNum = numberOfDaysSince2022 % Constants.ToDo.emojis.count
            
            
            return Constants.ToDo.emojis[adjustedNum] + " "
            //days since particular date with the modulo
            //then put emojis
        }()*/
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

            
            
            //MARK: THIS IS THE EMOJI THING
            //attributedString.addAttribute(NSAttributedString.Key.font, value: Constants.Fonts.toDoEntrySectionHeaderFont, range: NSRange(location: 0, length: text.count+1))
            
            //attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.gray, range: NSRange(location: startIndex, length: text.count - startIndex + 1))
            
            attributedString.addAttribute(NSAttributedString.Key.font, value: Constants.Fonts.toDoEntrySectionHeaderFont, range: NSRange(location: 0, length: text.count))
            
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.gray, range: NSRange(location: startIndex, length: text.count - startIndex ))

            
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
        
        if (sectionEntries.count == 0 || !sectionEntries.contains(where: {$0.isPlaceholder == true})) {
            let index = returnPositionForThisIndexPath(indexPath: IndexPath(row: sectionEntries.count, section: section))
            let newToDoEntry = ToDoEntry(context: self.context)
            initializeToDoEntry(newEntry: newToDoEntry, order: 0, isPlaceholder: true)
            entries.insert(newToDoEntry, at: 0)

            /*if (Constants.Settings.showCompletedEntries == true) {
            }
            else {
                entries.insert(newToDoEntry, at: index)
            }*/
            resetOrder()
            saveItems()
            tableView.reloadData()

            return sectionEntries.count
        }
        
        return sectionEntries.count//safety
    }
        
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ToDo.reuseIdentifier, for: indexPath) as! ToDoEntryCell
        let totalIndexRow = returnPositionForThisIndexPath(indexPath: indexPath)
        
        
        cell.toDoEntry = entries[totalIndexRow]
        cell.toDoEntryDelegate = self
        //cell.toolbar = ToDoEntryToolbar(setDate: entries[totalIndexRow].date!, isCurrentTask: entries[totalIndexRow].isCurrentTask)
        //cell.styleTextView(isCurrent: entries[totalIndexRow].isCurrentTask)
        cell.textView.font = Constants.Fonts.toDoEntryCellFont

        // set the closure
        /*
        weak var tv = tableView
        
        cell.textViewCallBack = { [weak self] str in
            guard let self = self, let tv = tv, let iP = tableView.indexPath(for: cell) else { return }
            
            // update our data with the edited string
            let totalIndexRow = self.returnPositionForThisIndexPath(indexPath: iP)
            if  totalIndexRow < self.entries.count - 1 {//safety func
                self.entries[totalIndexRow].text = str//
                // we don't need to do anything else here
                print("saving the new text")
            }
            // this will force the table to recalculate row heights

            tv.beginUpdates()
            tv.endUpdates()//height recalculation
            
            
        }*/
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
        //tableView.reloadData()
        
    }
    

    func loadItems(completion: @escaping() -> Void) {
        let request: NSFetchRequest<ToDoEntry> = ToDoEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        if (Constants.Settings.showCompletedEntries == false) {
            request.predicate = NSPredicate(format: "isChecked == false")
        }
        do {
            entries = try context.fetch(request)
            completion()

        } catch {
            print("error fetching data from context: \(error)")
        }
        
    }
    
    func refreshTableViewMode() {
        loadItems(completion: {
            self.orderEntries()
            print("completed loading items")
        })
        
        
        
    }
    
    
}


//MARK: TODOENTRY DELEGATE
extension ToDoViewController: ToDoEntryDelegate {
    func updateText(in cell: ToDoEntryCell, newText: String) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        let totalIndexRow = returnPositionForThisIndexPath(indexPath: indexPath)
        
        entries[totalIndexRow].text = newText//
        print("text saved")
        // this will force the table to recalculate row heights
        tableView.beginUpdates()
        tableView.endUpdates()//height recalculation
    }
    
    //command order entries
    func commandOrderEntries() {
        orderEntries()
        //tableView.reloadData()
    }
    
    //deletion of todo cell
    func checkBoxPressed(in cell: ToDoEntryCell, deletionInContext: Bool, resignedOnBackspace: Bool = false) {
        guard let indexPath = tableView.indexPath(for: cell) else {
                return
            }
        // MARK: don't let the placeholder cell do it
        if (cell.toDoEntry?.isPlaceholder == true) {
            cell.textView.resignFirstResponder()
            return
        }
        
        let totalIndexRow = returnPositionForThisIndexPath(indexPath: indexPath)
        
        
        if (cell.toDoEntry?.isCurrentTask == true) {//if deleting a current task, then make sure to set it to false and update the is working
            entries[totalIndexRow].isCurrentTask = false
            updateIsWorking()
        }
        
        tableView.beginUpdates()
        
        if (deletionInContext) {
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            context.delete(entries[totalIndexRow])
            entries.remove(at: totalIndexRow)
            if (tableView.numberOfRows(inSection: indexPath.section) == 1) {
                tableView.deleteSections([indexPath.section], with: .fade)
            }
        }
        else {
            entries[totalIndexRow].isPlaceholder = false
            entries[totalIndexRow].isChecked.toggle()

            
            if (Constants.Settings.showCompletedEntries == true) {
                let calendar = Calendar.current
                
                if (entries[totalIndexRow].isChecked == true) { // after the toggle, is it checked?
                    if let lastIndex = entries.lastIndex(where: { calendar.isDate($0.date!, equalTo: entries[totalIndexRow].date!, toGranularity: .day) }) {
                        
                        /*
                        if (lastIndex == entries.count - 1) {
                            entries.append(entries[totalIndexRow])
                        }
                        else {
                            entries.insert(entries[totalIndexRow], at: lastIndex + 1)
                        }*/
                        smartInsertEntry(newEntry: entries[totalIndexRow], newPos: lastIndex + 1)
                        
                        

                        entries.remove(at: totalIndexRow)
                        
                        let newRow = tableView.numberOfRows(inSection: indexPath.section) - 1
                        tableView.insertRows(at: [IndexPath(row: newRow, section: indexPath.section)], with: .fade)

                        tableView.deleteRows(at: [indexPath], with: .fade)
                        
                    }
                }
                else {
                    
                    guard let lastIndex = entries.lastIndex(where: { calendar.isDate($0.date!, equalTo: entries[totalIndexRow].date!, toGranularity: .day) && $0.isChecked == false}) ?? entries.lastIndex(where: { calendar.isDate($0.date!, equalTo: entries[totalIndexRow].date!, toGranularity: .day)}) else {return}
                    
                    smartInsertEntry(newEntry: entries[totalIndexRow], newPos: lastIndex + 1)
                    /*
                    if (lastIndex == entries.count - 1) {
                        entries.append(entries[totalIndexRow])
                    }
                    else {
                        entries.insert(entries[totalIndexRow], at: lastIndex + 1)
                    }*/
                    entries.remove(at: totalIndexRow)
                    
                    let newRow = lastIndex - returnPositionForThisIndexPath(indexPath: IndexPath(row: 0, section: indexPath.section))
                    
                    //tableView.moveRow(at: [indexPath], to: [IndexPath(row: newRow, section: indexPath.section)])
                    tableView.insertRows(at: [IndexPath(row: newRow, section: indexPath.section)], with: .fade)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    resetOrder()
                    orderEntries()
                    tableView.reloadData()
                    
                }

                
            }
            else {
                // delete from the tableview
                // delete from the entries array
                // keep in the context
                
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                entries.remove(at: totalIndexRow)
                if (tableView.numberOfRows(inSection: indexPath.section) == 1) {
                    tableView.deleteSections([indexPath.section], with: .fade)
                }
            }
        }
        resetOrder()
        saveItems()
        
        //update the progress updateProgress() - check the method on how this is done
        updateProgress()
        if (deletionInContext == false) {
            taskCompleted()
        }
        else if (IQKeyboardManager.shared.canGoPrevious && resignedOnBackspace) {
            IQKeyboardManager.shared.goPrevious()
        }
        
        tableView.endUpdates()
        

    }
    
    
    func createNewToDoEntryCell(in cell: ToDoEntryCell){
        
        
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("error in the createNewToDoEntryCell func in the ToDoViewController")
            return
        }
        
        let totalIndexPath = returnPositionForThisIndexPath(indexPath: indexPath)
        let isPlaceholder = entries[totalIndexPath].isPlaceholder
                
        
        
        let newToDoEntry = ToDoEntry(context: self.context)
        
        let newIndexPath: IndexPath
        
        //let date = calendar.date(from: dateComponents)!
        tableView.beginUpdates()

        if (isPlaceholder == true) {
            initializeToDoEntry(newEntry: newToDoEntry, date: entries[totalIndexPath].date!, isPlaceholder: true)

            entries[totalIndexPath].isPlaceholder = false
            cell.toDoEntry?.isPlaceholder = false
            
            newIndexPath = IndexPath(row: indexPath.row, section: indexPath.section)
            tableView.insertRows(at: [newIndexPath], with: .fade)
            entries.insert(newToDoEntry, at: totalIndexPath )
            /*
            if (Constants.Settings.showCompletedEntries == true) { //placeholder is at the top, insert a row directly above it
                
                
                
            }
            
            else {//placeholder is at the bottom, insert directly below
                newIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
                tableView.insertRows(at: [newIndexPath], with: .fade)
                
                smartInsertEntry(newEntry: newToDoEntry, newPos: totalIndexPath + 1)

                //entries.insert(newToDoEntry, at: totalIndexPath + 1)
            }*/
            
        }
        else {//insert directly below
            initializeToDoEntry(newEntry: newToDoEntry, date: entries[totalIndexPath].date!, isPlaceholder: false)
            newIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)

            tableView.insertRows(at: [newIndexPath], with: .fade)
            smartInsertEntry(newEntry: newToDoEntry, newPos: totalIndexPath + 1)

        }
        
        resetOrder()
        saveItems()
        //tableView.reloadData()
        tableView.endUpdates()
        updateProgress()
        
        if (isPlaceholder == false) {
            IQKeyboardManager.shared.goNext()

        }
        else {
            IQKeyboardManager.shared.goPrevious()

        }
        //tableView.scrollToRow(at: newIndexPath, at: .top, animated: true)
        
        
        
        
    }
    
    /*
    
    func updateDate(in cell: ToDoEntryCell, newDate: Date) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        
        
        let currentEntry = entries[returnPositionForThisIndexPath(indexPath: indexPath)]
        
        currentEntry.date = newDate//set new date
        
        currentEntry.order = 999
        let calendar = Calendar.current
        let dayDate = calendar.dateComponents([.day, .month, .year], from: newDate)
        
        tableView.beginUpdates()

        if (!uniqueDates.contains(where: {$0 == dayDate})) {
            print("unique dates doesn't contain, insert a new section")
            updateUniqueDates()

            tableView.insertSections([uniqueDates.firstIndex(of: dayDate)!], with: .fade)
        }
        if (tableView.numberOfRows(inSection: indexPath.section) == 1) {
            tableView.deleteSections([indexPath.section], with: .fade)
            updateUniqueDates()
        }
        
        let newSection = uniqueDates.firstIndex(of: dayDate)!
        
        let newRow: Int
        
        
        if Constants.Settings.showCompletedEntries == true {
            newRow = entries.filter({
                calendar.dateComponents([.day, .month, .year], from: $0.date!) == dayDate
                && $0.isChecked == false
            }).count - 1
        }
        else {
            let filteredEntries = entries.filter({
                calendar.dateComponents([.day, .month, .year], from: $0.date!) == dayDate
                && $0.isChecked == false
            })
            
            newRow = filteredEntries.count - filteredEntries.filter({$0.isPlaceholder == true}).count - 1
            
        }
        /*
        let newTotalIndexRow = entries.lastIndex(where: {
            calendar.dateComponents([.day, .month, .year], from: $0.date!) == dayDate
            && $0 != currentEntry
            && $0.isChecked == false
            
        }) ?? entries.firstIndex(where: {currentEntry.date! < $0.date!}) ?? 0
        
        //let newIndexPath = IndexPath(row: returnIndexPathForTotalPos(pos: newTotalIndexRow).row, section: newSection)
        
        
        let totalIndexRow = returnPositionForThisIndexPath(indexPath: indexPath)
        let newIndexPath = IndexPath(row: newRow, section: newSection)
        print("totalIndexRow:", totalIndexRow)
        print("newTotalIndexRow:", newTotalIndexRow)

        print("indexPath:", indexPath)
        print("newIndexpath:", newIndexPath)
        
         */
        let newIndexPath = IndexPath(row: newRow, section: newSection)
        
        /*
        if (tableView.numberOfRows(inSection: indexPath.section) == 1) {
            tableView.deleteSections([indexPath.section], with: .fade)
            
            if (newIndexPath.section > indexPath.section) {
                tableView.insertRows(at: [IndexPath(row: newIndexPath.row, section: newIndexPath.section - 1)], with: .fade)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            else {
                tableView.insertRows(at: [IndexPath(row: newIndexPath.row, section: newIndexPath.section )], with: .fade)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
        else {
            tableView.insertRows(at: [IndexPath(row: newIndexPath.row, section: newIndexPath.section)], with: .fade)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }*/
        /*
        if (currentEntry.isPlaceholder == true) {
            currentEntry.isPlaceholder = false
            
            /*
            let newPlaceholder = ToDoEntry(context: self.context)
            initializeToDoEntry(newEntry: newPlaceholder, date: Date(), isPlaceholder: true)
            
            smartInsertEntry(newEntry: newPlaceholder, newPos: Int(cell.toDoEntry!.order))
            tableView.insertRows(at: [indexPath], with: .left)*/
            
            //MARK: EVERYTHING WORKS EXCEPT THE PLACEHOLDER STUFF. LOTS OF ERRORS WITH THE PLACEHOLDER IN RE ORDERING. MAYBE DO LIKE A IF PLACEHOLDER DON'T DELETE THE ROW? SEPERATE FLOW FOR PLACEHOLDER AND NONPLACEHOLDER?
            //MARK: ALSO CONSIDER SETTING THE toDoEntry of the cell to be the entries at that pos to avoid reloading, currently i am trying the reloadrows at thing and it seems to be working fine
        }
        */
        
        tableView.insertRows(at: [IndexPath(row: newIndexPath.row, section: newIndexPath.section)], with: .left)
        tableView.deleteRows(at: [indexPath], with: .right)
        
        tableView.reloadRows(at: [newIndexPath], with: .none)
        /*
        smartInsertEntry(newEntry: currentEntry, newPos: newTotalIndexRow)
        entries.remove(at: totalIndexRow)*/
                                   
        //resetOrder()
        //saveItems()
        tableView.endUpdates()
        resetOrder()
        orderEntries()
        updateProgress()
        saveItems()
        /*
        
        self.entries[Int(cell.toDoEntry!.order)].order = Int16(self.entries.count) //set order to max so that it'll go to the back of each section
        self.orderEntries()
            
        self.updateProgress()*/
            
            
    }*/
    
    
    func updateDate(in cell: ToDoEntryCell, newDate: Date) {
        
        print("updateDate delegate working")
        self.entries[Int(cell.toDoEntry!.order)].date = newDate//set new date
        if (cell.toDoEntry?.isPlaceholder == true) {
            self.entries[Int(cell.toDoEntry!.order)].isPlaceholder = false
        }
        self.entries[Int(cell.toDoEntry!.order)].order = Int16(self.entries.count) //set order to max so that it'll go to the back of each section
        self.orderEntries()
            
        //self.updateProgress()
        //saveItems()
        tableView.reloadData()
            
    }
    
    func updateIsCurrentTask(in cell: ToDoEntryCell, isCurrentTask: Bool) {
        print("updateIsCurrentTask working")
        
        self.entries[Int(cell.toDoEntry!.order)].isCurrentTask = isCurrentTask//set current Task
        
        updateIsWorking()
        
        
    }
}

extension ToDoViewController {//all helper funcs for organization
    private func initProgressBarFlowAnimation() {
        
        
        if (entries.filter({$0.isCurrentTask == true}).count > 0) {
            customProgressBar.createRepeatingAnimation()
        }
        else {
            customProgressBar.resetAnimation()
        }
        
    }
    
    private func returnIndexPathForTotalPos(pos: Int) -> IndexPath {
        var currentPos = pos
        
        var section = 0
        
        while (currentPos > 0) {
            currentPos -= tableView.numberOfRows(inSection: section)
            section+=1
        }
        
        let rV = IndexPath(row: tableView.numberOfRows(inSection: section) - (currentPos * -1), section: section)
        
        print("new section: ", section)
        print("new row: ", rV.row)
        return rV
    }
    private func smartInsertEntry(newEntry: ToDoEntry, newPos: Int) {
        if (entries.count <= newPos) {
            entries.append(newEntry)
        }
        else {
            entries.insert(newEntry, at: newPos)
        }
    }
    
    
    private func setGreetingMessage() {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        let messages = ["🌞 Good morning!", "🌅 Rise and shine!", "👋 Hello there!", "☀️ Good afternoon!", "👋 Hi there!", "🌃 Good evening!", "🌙 Sweet dreams!"]
        switch hour {
            case 4..<12:
            greeting.text = messages[Int.random(in: 0...2)]
            case 12..<18:
            greeting.text = messages[Int.random(in: 3...4)]
            case 18..<24:
            greeting.text = messages[Int.random(in: 5...6)]
            case 0..<4:
            greeting.text = messages[Int.random(in: 5...6)]
            
            default:
            greeting.text = "👋 Hello there!"
        }
        
    }
    
    private func updateIsWorking() {
        
        guard let FSisWorking = User.shared().userInfo["isWorking"] as? Bool else {
            return
        }
        let currentTasks = entries.filter { $0.isCurrentTask == true }
        //currenttasks count > 0 means currently working
        //isWorking == true means is working
        //logic: if both are true, or both are false, then this code block will not run because I need to make sure that the updateUserInfo only happens when its needed
        if (currentTasks.count > 0) != (FSisWorking == true) {
            print("updateIsCurrentTask: will update current task in the User")
            User.shared().updateUserInfo(newInfo: ["isWorking": !FSisWorking])
        }
        
        DispatchQueue.main.async {
            if (currentTasks.count > 0) {
                self.customProgressBar.createRepeatingAnimation()
            }
            else {
                self.customProgressBar.resetAnimation()
            }
        }
        
    }
    
    private func initProgressNoFirestore() {
        let fetchRequest: NSFetchRequest<ToDoEntry> = ToDoEntry.fetchRequest()

        /*
        if (Constants.Settings.toDoProgressUntilDate >= 0) {
            let progressUntilDate = Calendar.current.date(byAdding: .day, value: Constants.Settings.toDoProgressUntilDate, to: Date())!
            fetchRequest.predicate = NSPredicate(format: "date <= %@", progressUntilDate as NSDate)
        }*/
        
        //fetchRequest.predicate = NSPredicate(format: "date <= %@", NSDate())
        do {
            //let checkedEntries = try context.fetch(fetchRequest).filter { $0.isChecked == true }
            //let totalEntries = try context.fetch(fetchRequest).filter {$0.isPlaceholder == false}
            //account for the isPlaceholder cell
            let calendar = Calendar.current
            
            let totalEntries = try context.fetch(fetchRequest).filter {$0.isPlaceholder == false}
            let startOfTomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date())!)
            
            let todayAndPrevEntries = totalEntries.filter({$0.date! < startOfTomorrow})
            let checkedTodayAndPrev = todayAndPrevEntries.filter({$0.isChecked == true})
            
            let futureEntries = totalEntries.filter({$0.date! >= startOfTomorrow})
            let checkedFutureEntries = totalEntries.filter({$0.isChecked == true})
            
            if (todayAndPrevEntries.count == 0) {
                progress = 1 + (Float(checkedFutureEntries.count) / Float(futureEntries.count))
            }
            else {
                progress = (Float(checkedTodayAndPrev.count + checkedFutureEntries.count)) / Float(todayAndPrevEntries.count + checkedFutureEntries.count)
            }
            if (progress.isNaN) {
                progress = 1.0
            }
            

        } catch {
            progress = 0.0
            print("error in updateProgress")
        }
        
        //percentageLabel.text = String(format: "%.f", progress * 100) + "%"
        
        //customProgressBar.progress = progress
        //customProgressBar.createDoubleAnimation()
        //progressBar.progress = progress
    }

    private func updateProgress() {
        initProgressNoFirestore()
        
        
        User.shared().updateUserInfo(newInfo: ["progress": progress])
    }
    
    private func taskCompleted() {
        User.shared().updateUserInfo(newInfo: ["likes": []])
        
        customProgressBar.pulseAnimation()
        
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
        
        print("new unique dates", uniqueDates)
    }
    
    func orderEntries() {
        let calendar = Calendar.current
        self.entries.removeAll(where: {($0.text == "" || $0.text == "⚡️") && $0.isPlaceholder == false})//removes all unnecessary ones
        
        self.entries.sort {
            if (calendar.isDate($0.date!, equalTo: $1.date!, toGranularity: .day)) {//if same day
                if ($0.isPlaceholder == true) {//if its the placeholder
                    //return Constants.Settings.showCompletedEntries //if show checked entries is true, then returning true -> placeholder goes to top
                    return true
                }
                else if ($0.isCurrentTask != $1.isCurrentTask) {//if only one is a current task
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
        if (placeholder.count != 1)  {
            self.entries.removeAll(where: {$0.isPlaceholder == true})
            
            let newToDoEntry = ToDoEntry(context: self.context)
            initializeToDoEntry(newEntry: newToDoEntry, order: 0, isPlaceholder: true)
            //insert at top of today's section
            if let index = entries.firstIndex(where: {calendar.isDate($0.date!, equalTo: Date(), toGranularity: .day)}) {//case where there is 0 index in today is already handled by the tableview sections stuff
                entries.insert(newToDoEntry, at: index)
            }
            /*
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
            }*/
            
            
            
            
        }
        else if (!calendar.isDate(placeholder[0].date!, equalTo: Date(), toGranularity: .day)){
            self.entries.removeAll(where: {$0.isPlaceholder == true})
            
            let newToDoEntry = ToDoEntry(context: self.context)
            initializeToDoEntry(newEntry: newToDoEntry, order: 0, isPlaceholder: true)
            //insert at top of today's section
            if let index = entries.firstIndex(where: {calendar.isDate($0.date!, equalTo: Date(), toGranularity: .day)}) {//case where there is 0 index in today is already handled by the tableview sections stuff
                entries.insert(newToDoEntry, at: index)
            }
            
            
            /*
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
            }*/
            
            
        }
        else if (placeholder[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) != "") {
            placeholder[0].isPlaceholder = false
            let newToDoEntry = ToDoEntry(context: self.context)
            initializeToDoEntry(newEntry: newToDoEntry, order: 0, isPlaceholder: true)
            //insert at top of today's section
            if let index = entries.firstIndex(where: {calendar.isDate($0.date!, equalTo: Date(), toGranularity: .day)}) {//case where there is 0 index in today is already handled by the tableview sections stuff
                entries.insert(newToDoEntry, at: index)
            }
            
            /*
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
            }*/
            
            
        }
        else if (placeholder[0].text != "") {
            placeholder[0].text = ""
        }
        
        resetOrder()//i always run this
        updateIsWorking()
        updateUniqueDates()
        tableView.reloadData()
        saveItems()//i always run this
    }
    
    
    private func resetOrder() {
        for (index, entry) in entries.enumerated() {
            entry.order = Int16(index)
        }
    }
    
    //functions to easily initialize to do entry
    
    
    private func initializeToDoEntry(newEntry: ToDoEntry, text: String = "", isChecked: Bool = false, isCurrentTask: Bool = false, date: Date = Date(), time: Double = 0.0, order: Int16 = 0, isPlaceholder: Bool = false) {//to initialize default new one
        newEntry.text = text
        newEntry.isChecked = isChecked
        newEntry.isCurrentTask = isCurrentTask
        newEntry.date = date
        newEntry.time = time
        newEntry.order = order
        newEntry.isPlaceholder = isPlaceholder
    }
    
    /*private func newDayUpdates() {
        
        
        let calendar = Calendar.current
        let lastOpened = defaults.value(forKey: "appLastOpened") as? Date
        
        if let lO = lastOpened {
            if (calendar.isDate(Date(), inSameDayAs: lO)) {
                return // same day, its fine
            }
        }
        
        defaults.set(Date(), forKey: "appLastOpened")
        
        let fetchRequest: NSFetchRequest<ToDoEntry> = ToDoEntry.fetchRequest()
        let predicate1 = NSPredicate(format: "isChecked == true AND date < %@", NSDate())
        let predicate2 = NSPredicate(format: "isPlaceholder == true")//get rid of the old placeholder
        let compoundPredicate = NSCompoundPredicate(type: .or, subpredicates: [predicate1, predicate2])
        fetchRequest.predicate = compoundPredicate
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
        
        /*
        let calendar = Calendar.current
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: Date())!
        
        if (entries[0].date! <= twoDaysAgo) {//if the first entry's date is less than or equal to two days ago from the start of the new day
            
            User.shared().updateUserInfo(newInfo: ["likes": [String](), "todaysLikes": [String](), "streak": 0, "progress": progress])
            
        }
        else {
            User.shared().updateUserInfo(newInfo: ["likes": [String](), "todaysLikes": [String](), "streak": FieldValue.increment(1.0), "progress": progress])
            
        }*/
        
    }*/
    
    
    //for total indexpath
    private func returnPositionForThisIndexPath(indexPath:IndexPath)->Int{

        var i = 0
        var rowCount = 0

        while i < indexPath.section {
            rowCount += tableView.numberOfRows(inSection: i)
            i+=1
        }

        rowCount += indexPath.row

        return rowCount
    }
    
    
    
    
   
}//helper funcs



