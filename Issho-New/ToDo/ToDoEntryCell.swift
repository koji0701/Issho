//
//  ToDoEntryCell.swift
//  Issho
//
//  Created by Koji Wong on 6/6/22.
//

import UIKit
import IQKeyboardManagerSwift

protocol ToDoEntryDelegate {
    func checkBoxPressed(in cell: ToDoEntryCell)
    func createNewToDoEntryCell(in cell: ToDoEntryCell) -> ToDoEntryCell
}



class ToDoEntryCell: UITableViewCell,UITextViewDelegate  {

    @IBOutlet weak var checkboxButton: UIButton!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var temporaryOrder: UILabel!
    
    
    var toDoEntryDelegate: ToDoEntryDelegate!
    
    var toDoEntry: ToDoEntry? {
        didSet {
            
            textView.text = toDoEntry?.text
            let temp = toDoEntry?.order
            
            temporaryOrder.text = String(temp!)
        }
    }
    
    let toolbar = ToDoEntryToolbar()
    
    var textViewCallBack: ((String) -> ())?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.textContainer.maximumNumberOfLines = 0
        textView.isEditable = true
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainer.widthTracksTextView = true
        textView.textContainer.size = textView.frame.size
        
        
        //MARK: temporary
        addButton.isHidden = true
        checkboxButton.isHidden = false
        checkboxButton.isEnabled = true
        addButton.isEnabled = false
        
        //toolbar
        
        toolbar.sizeToFit()
        textView.inputAccessoryView = toolbar
        
        
        
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {//code for selected/deselected
        super.setSelected(selected, animated: animated)
        

        // Update the selectedView's isHidden property based on the selected state of the cell
        //selectedView.isHidden = !selected
    }

    
    
    
    @IBAction func checkboxPressed(_ sender: Any) {
        self.toDoEntryDelegate?.checkBoxPressed(in: self)
    }
    
    @IBAction func addPressed(_ sender: Any) {
        let nextCell = self.toDoEntryDelegate?.createNewToDoEntryCell(in: self)
        
        if let nextTV = nextCell!.textView {
            nextTV.becomeFirstResponder()
        }
        
    }
    
    
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
        
    }//MARK: IQKEYBOARDMANAGER CAN BE USED INSTEAD I THINK COME BACK TO THIS
    
    
    func textViewDidChange(_ textView: UITextView) {
        
        let str = textView.text ?? ""
        textViewCallBack?(str)
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text == "\n" {
                // call the desired function here
                let nextCell = self.toDoEntryDelegate?.createNewToDoEntryCell(in: self)
                textView.resignFirstResponder()
                if let nextTV = nextCell!.textView {
                    nextTV.becomeFirstResponder()
                }
                return false
            }
            return true
        }
    
}



