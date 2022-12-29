//
//  ToDoEntryCell.swift
//  Issho
//
//  Created by Koji Wong on 6/6/22.
//

import UIKit
import IQKeyboardManagerSwift

protocol ToDoEntryDelegate {
    func checkBoxPressed(in cell: UITableViewCell)
    func createNewToDoEntryCell(in cell: UITableViewCell) -> ToDoEntryCell
    func saveInfoToContext(in cell: UITableViewCell)
}



class ToDoEntryCell: UITableViewCell,UITextViewDelegate  {

    @IBOutlet weak var checkboxButton: UIButton!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var addButton: UIButton!
    
    
    
    var toDoEntryDelegate: ToDoEntryDelegate!
    
    var toDoEntry: ToDoEntry? {
        didSet {
            
            textView.text = toDoEntry?.text
        }//not sure if i need this whole toDoEntry thing anymore because i edit it in here then ill send it back to be saved in the context. coredata can handle the permanent saving of the edits over here i dont need to load it back
    }
    
    
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
        
        
        let toolbar = ToDoEntryToolbar()
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {//MARK: toolbar
        
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
        
    }//MARK: IQKEYBOARDMANAGER CAN BE USED INSTEAD I THINK COME BACK TO THIS
    
    
    func textViewDidChange(_ textView: UITextView) {
        
        let str = textView.text ?? ""
        textViewCallBack?(str)
    }
    //toolbar manipulation for date
    @objc func dateButtonClicked() {
        print("date button clicked")
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



