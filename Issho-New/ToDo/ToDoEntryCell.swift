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
    func commandOrderEntries()
    //toolbar stuff
    func updateDate(in cell: ToDoEntryCell, newDate: Date)
    func updateToolbarAttributesExceptDate(in cell: ToDoEntryCell, isCurrentTask: Bool)
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
            if (toDoEntry?.isPlaceholder == true) {
                
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
            }
        }
    }
    
    
    
    
    
    
    var textViewCallBack: ((String) -> ())?
    var toolbar: ToDoEntryToolbar! {
        didSet {
            print("toolbar set")
            //toolbar
            toolbar.sizeToFit()
            textView.inputAccessoryView = toolbar
            IQKeyboardManager.shared.keyboardDistanceFromTextField = toolbar.frame.height
            
            toolbar.dateSelectedCallBack = { [weak self] date in
                    guard let self = self else { return }
                self.toDoEntry?.date = date
                self.toDoEntryDelegate?.updateDate(in: self, newDate: date)
            }
            toolbar.currentTaskCallBack = { [weak self] isCurrentTask in
                guard let self = self else { return }
                self.toDoEntryDelegate?.updateToolbarAttributesExceptDate(in: self, isCurrentTask: isCurrentTask)
                self.styleTextView(isCurrent: isCurrentTask)
                //self.toDoEntry?.isCurrentTask = isCurrentTask//rely on the didset to call the styling method
            }
        }
    }
    
    func styleTextView(isCurrent: Bool) {//also put fonts and color here
        if (isCurrent) {
            //let imageAttachment = NSTextAttachment()
            //imageAttachment.image = UIImage(systemName: "bolt.fill")?.withTintColor(.systemYellow)
            let fullString = NSMutableAttributedString(string:  textView.text)
            
            //fullString.insert(NSAttributedString(attachment: imageAttachment), at: 0)
            if (textView.text.prefix(1) != "⚡️") {
                print("no lightning, set the lightning")
                fullString.insert(NSAttributedString("⚡️"), at: 0)
            }
            textView.attributedText = fullString
        }
        else {
            textView.text = String(textView.text.dropFirst())
            textView.attributedText = NSMutableAttributedString(string: textView.text)
        }
        
    }
    
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
    }
    
    
    override func layoutSubviews() {//round the edges
        super.layoutSubviews()
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
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
        if (toDoEntry?.isPlaceholder == true) {
            addButton.isHidden = true
            checkboxButton.isHidden = false
            checkboxButton.isEnabled = true
            addButton.isEnabled = false
        }
    }
    
    private var resignedOnEnter = false
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        
        if (textView.text == "") {//if textview is still blank after done editing
            
            if (toDoEntry?.isPlaceholder == true) {//if its the placeholder cell, go back to the "add" phase
                addButton.isHidden = false
                checkboxButton.isHidden = true
                checkboxButton.isEnabled = false
                addButton.isEnabled = true
                resignedOnBackspace = false
            }
            else {
                if (resignedOnBackspace) {//MARK: NOT WORKING
                    print("resigned on backspace")
                    /**if (IQKeyboardManager.shared.canGoPrevious) {
                        print("can go previous")
                        IQKeyboardManager.shared.goPrevious()
                    }**/
                    IQKeyboardManager.shared.goPrevious()
                    resignedOnBackspace = false
                }
                
                self.toDoEntryDelegate?.checkBoxPressed(in: self, deletion: true)//delete the cell if its still blank after editing
            }
        }
        else {
            if (resignedOnEnter) {
                if (toDoEntry?.isPlaceholder == false) {
                    self.toDoEntryDelegate?.createNewToDoEntryCell(in: self, makeFirstResponder: true)
                    resignedOnEnter = false
                }
                else if (Constants.ToDo.showCheckedEntries == false) {
                    self.toDoEntryDelegate?.createNewToDoEntryCell(in: self, makeFirstResponder: true)
                    resignedOnEnter = false
                }
                else if (Constants.ToDo.showCheckedEntries == true) {
                    self.toDoEntryDelegate?.createNewToDoEntryCell(in: self, makeFirstResponder: true)
                    IQKeyboardManager.shared.goPrevious()
                    resignedOnEnter = false
                }
            }
            else {
                toDoEntryDelegate?.commandOrderEntries()//if theres stuff in there still, but i gesture tap off then re order entries. 
            }
            
        }
        
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        
        let str = textView.text ?? ""
        textViewCallBack?(str)
    }
    
    private var resignedOnBackspace = false
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
            if text == "\n" {
                
                if (textView.text != "") {
                    resignedOnEnter = true
                }
                textView.resignFirstResponder()
                return false
            }
        
            if (text.isBackspace) {
                if (textView.text == "") {
                    resignedOnBackspace = true
                    textView.resignFirstResponder()
                    return false
                }
                
            }
            if (textView.text.prefix(1) == "⚡️" && range.location < 1) {
                    //if the user wants to write text before this position, don't let the user
                print("user writes before the prefix lightning")
                return false
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

