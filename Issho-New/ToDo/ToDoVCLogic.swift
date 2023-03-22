//
//  ToDoVCLogic.swift
//  Issho-New
//
//  Created by Koji Wong on 3/7/23.
//

import Foundation
import UIKit

extension ToDoViewController {
    /*
    func checkBoxPressed(in cell: ToDoEntryCell, deletion: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else {
                return
            }
        
        
        let totalIndexRow = returnPositionForThisIndexPath(indexPath: indexPath, insideThisTable: tableView)
        
        /*
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
        */
        
    }*/ //checkbox pressed old function
    
    /*.func createNewToDoEntryCell(in cell: ToDoEntryCell, makeFirstResponder: Bool){
     
     
     
     guard let indexPath = tableView.indexPath(for: cell) else {
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
         let totalIndexPath = returnPositionForThisIndexPath(indexPath: indexPath)
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
     tableView.reloadData()
     guard let nextCell = tableView.cellForRow(at: nextIndexPath) as? ToDoEntryCell else {
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
 **/
}
