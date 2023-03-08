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
    
}
