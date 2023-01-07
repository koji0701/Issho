//
//  ToDoEntryCell.swift
//  Issho
//
//  Created by Koji Wong on 6/6/22.
//

import UIKit
import IQKeyboardManagerSwift

protocol ToDoEntryDelegate {
    func checkBoxPressed(in cell: ToDoEntryCell, deletion: Bool)
    func createNewToDoEntryCell(in cell: ToDoEntryCell, makeFirstResponder: Bool)
}



class ToDoEntryCell: UITableViewCell,UITextViewDelegate  {

    @IBOutlet weak var checkboxButton: UIButton!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var addButton: UIButton!
    
    
    
    var toDoEntryDelegate: ToDoEntryDelegate!
    
    var toDoEntry: ToDoEntry? {
        didSet {
            
            textView.text = toDoEntry?.text
            if (toDoEntry?.isChecked == true) {
                checkboxButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
                print("ischecked is true")
            }
            else {
                checkboxButton.setImage(UIImage(systemName: "circle"), for: .normal)
            }
        }
    }
    
    
    var isPlaceholder: Bool? {
        didSet {
            if (isPlaceholder == true) {
                
                addButton.isHidden = false
                checkboxButton.isHidden = true
                checkboxButton.isEnabled = false
                addButton.isEnabled = true
            }
            else {
                
                addButton.isHidden = true
                checkboxButton.isHidden = false
                checkboxButton.isEnabled = true
                addButton.isEnabled = false
                
                if (textView.isFirstResponder == false && textView.text == "") {
                    self.toDoEntryDelegate?.checkBoxPressed(in: self, deletion: true)//delete if its not first responder and not last cell and blank
                }
            }
        }
    }
    
    
    
    var textViewCallBack: ((String) -> ())?
    let toolbar = ToDoEntryToolbar()
    
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
        
        
        //toolbar
        toolbar.sizeToFit()
        textView.inputAccessoryView = toolbar
        IQKeyboardManager.shared.keyboardDistanceFromTextField = toolbar.frame.height
        
    }
    

    
    
    
    
    @IBAction func checkboxPressed(_ sender: Any) {
        self.toDoEntryDelegate?.checkBoxPressed(in: self, deletion: false)
    }
    
    @IBAction func addPressed(_ sender: Any) {
        textView.becomeFirstResponder()//text view typing
        //checkbox phase
        addButton.isHidden = true
        checkboxButton.isHidden = false
        checkboxButton.isEnabled = true
        addButton.isEnabled = false
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        //set to the checkbox phase if its the last cell
        textView.becomeFirstResponder()
        if (isPlaceholder!) {
            addButton.isHidden = true
            checkboxButton.isHidden = false
            checkboxButton.isEnabled = true
            addButton.isEnabled = false
        }
    }
    
    private var resignedOnEnter = false
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
        
        if (textView.text == "") {//if textview is still blank after done editing
            if (isPlaceholder!) {//if its the last cell, go back to the "add" phase
                addButton.isHidden = false
                checkboxButton.isHidden = true
                checkboxButton.isEnabled = false
                addButton.isEnabled = true
            }
            else {
                self.toDoEntryDelegate?.checkBoxPressed(in: self, deletion: true)//delete the cell if its still blank after editing
            }
        }
        else {
            if (resignedOnEnter) {
                
                self.toDoEntryDelegate?.createNewToDoEntryCell(in: self, makeFirstResponder: true)
                resignedOnEnter = false
            }
            
        }
        
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        
        let str = textView.text ?? ""
        textViewCallBack?(str)
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
            if text == "\n" {
                
                if (textView.text != "") {
                    resignedOnEnter = true
                }
                textView.resignFirstResponder()
                return false
            }
        
            if (textView.text == "") {
                if (text.isBackspace) {
                    print("delete key pressed")
                    textView.resignFirstResponder()
                    return false
                }
            }
            return true
        
        }
    
    
}

extension String {//for backspace
  var isBackspace: Bool {
    let char = self.cString(using: String.Encoding.utf8)!
    return strcmp(char, "\\b") == -92
  }
}

