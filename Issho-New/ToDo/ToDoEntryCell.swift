//
//  ToDoEntryCell.swift
//  Issho
//
//  Created by Koji Wong on 6/6/22.
//

import UIKit
import IQKeyboardManagerSwift

protocol ToDoEntryDelegate {
    func checkBoxPressed(in cell: ToDoEntryCell, deletionInContext: Bool, resignedOnBackspace: Bool)
    func createNewToDoEntryCell(in cell: ToDoEntryCell)
    func commandOrderEntries()
    //toolbar stuff
    func updateDate(in cell: ToDoEntryCell, newDate: Date)
    func updateIsCurrentTask(in cell: ToDoEntryCell, isCurrentTask: Bool)
    func updateText(in cell: ToDoEntryCell, newText: String)
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
                contentView.backgroundColor = .systemGray6
                
            }
            else {
                checkboxButton.setImage(UIImage(systemName: "circle"), for: .normal)
                contentView.backgroundColor = .clear

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
    
    
    
    
    
    
    //var textViewCallBack: ((String) -> ())?
    lazy var toolbar: ToDoEntryToolbar! = ToDoEntryToolbar(setDate: toDoEntry?.date ?? Date(), isCurrentTask: toDoEntry?.isCurrentTask ?? false) {
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
                self.toDoEntryDelegate?.updateIsCurrentTask(in: self, isCurrentTask: isCurrentTask)
                
                if (isCurrentTask) {
                    self.contentView.backgroundColor = Settings.progressBarColorForHasNotFinishedToday
                }
                else {
                    self.contentView.backgroundColor = .clear

                }
                
                //self.styleTextView(isCurrent: isCurrentTask)
                //self.toDoEntry?.isCurrentTask = isCurrentTask//rely on the didset to call the styling method
            }
        }
    }
    /*
    func styleTextView(isCurrent: Bool) {//also put fonts and color here
        if (isCurrent) {
            //let imageAttachment = NSTextAttachment()
            //imageAttachment.image = UIImage(systemName: "bolt.fill")?.withTintColor(.systemYellow)
            
            
            //fullString.insert(NSAttributedString(attachment: imageAttachment), at: 0)
            if (textView.text.prefix(1) != "⚡️") {
                textView.text.insert(contentsOf: "⚡️: ", at: textView.text.startIndex)

            }
            
            let displayText = NSMutableAttributedString(string: textView.text)
            displayText.addAttribute(NSAttributedString.Key.font, value: Constants.Fonts.toDoEntryCellFont, range: NSRange(location: 3, length: textView.text.count + 1 - 3))

            displayText.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.systemGray5, range: NSRange(location: 0, length: 3))
            displayText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemPink, range: NSRange(location: 0, length: 3))
            displayText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 15, weight: .bold), range: NSRange(location: 0, length: 3))

            textView.attributedText = displayText
            

        }
        else {
            if (textView.text.prefix(1) == "⚡️") {
                textView.text = String(textView.text.dropFirst())
                textView.text = String(textView.text.dropFirst())
                textView.text = String(textView.text.dropFirst())
            }
            textView.attributedText = NSMutableAttributedString(string: textView.text)
            textView.font = Constants.Fonts.toDoEntryCellFont

            
        }

        
    }*/
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textView.text = toDoEntry?.text
        
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.textContainer.maximumNumberOfLines = 0
        textView.isEditable = true
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainer.widthTracksTextView = true
        //textView.textContainer.size = textView.frame.size
        
        addButton.tintColor = .darkGray
        
        
        contentView.layer.cornerRadius = 18
        
    }
    
    
    
    
    
    
    
    
    @IBAction func checkboxPressed(_ sender: Any) {
        
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: .punctuationCharacters)
            .trimmingCharacters(in: .symbols).isEmpty {
            
            //MARK: account for double deletion situation. When ending editing and pressing at the same time, double deletion
            if !textView.isFirstResponder {
                self.toDoEntryDelegate?.checkBoxPressed(in: self, deletionInContext: true, resignedOnBackspace: false)
            }
            
        }
        else {
            self.toDoEntryDelegate?.checkBoxPressed(in: self, deletionInContext: false, resignedOnBackspace: false)
            if (Settings.showCompletedEntries) {
                contentView.backgroundColor = .systemGray6
            }
        }
        
        
        
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
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        toolbar = ToDoEntryToolbar(setDate: toDoEntry?.date ?? Date(), isCurrentTask: toDoEntry?.isCurrentTask ?? false)
        textView.inputAccessoryView = toolbar
        
        return true
    }
    
    private var resignedOnEnter = false
    
    func textViewDidEndEditing(_ textView: UITextView) {

        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: .punctuationCharacters)
            .trimmingCharacters(in: .symbols).isEmpty {//if textview is still blank after done editing
            
            if (toDoEntry?.isPlaceholder == true) {//if its the placeholder cell, go back to the "add" phase
                addButton.isHidden = false
                checkboxButton.isHidden = true
                checkboxButton.isEnabled = false
                addButton.isEnabled = true
                resignedOnBackspace = false
            }
            else {
                if (!resignedOnBackspace) {
                    toDoEntryDelegate?.checkBoxPressed(in: self, deletionInContext: true, resignedOnBackspace: false)
                }
                resignedOnBackspace = false
                
            }
        }
        else {
            /*
            if (resignedOnEnter) {
                if (toDoEntry?.isPlaceholder == false) {
                    self.toDoEntryDelegate?.createNewToDoEntryCell(in: self)
                    resignedOnEnter = false
                }
                else if (Settings.showCompletedEntries == false) {
                    self.toDoEntryDelegate?.createNewToDoEntryCell(in: self)
                    resignedOnEnter = false
                }
                else if (Settings.showCompletedEntries == true) {
                    self.toDoEntryDelegate?.createNewToDoEntryCell(in: self)
                    resignedOnEnter = false
                }
            }
            else {
                
                toDoEntryDelegate?.commandOrderEntries()//if theres stuff in there still, but i gesture tap off then re order entries. 
            }*/
            if (!resignedOnEnter) {
                toDoEntryDelegate?.commandOrderEntries()//if theres stuff in there still, but i gesture tap off then re order entries.
            }
            resignedOnEnter = false

            
        }

        
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        
        let str = textView.text ?? ""
        print(Constants.Fonts.toDoEntryCellFont?.lineHeight)
        //textViewCallBack?(str)
        toDoEntryDelegate?.updateText(in: self, newText: str)
    }
    
    private var resignedOnBackspace = false
    
    private let tagWords: [String] = ["today", "tomorrow", "yesterday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday", "next monday", "next tuesday", "next wednesday", "next thursday", "next friday", "next saturday", "next sunday", "next week"];
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        
        
        if text == "\n" {
            resignedOnEnter = true
            if (textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: .punctuationCharacters)
                .trimmingCharacters(in: .symbols).isEmpty) {
            
                textView.resignFirstResponder()
                
            }
            else {
                toDoEntryDelegate?.createNewToDoEntryCell(in: self)
            }
            return false
        }
        
        if (text.isBackspace) {

            if (textView.text == "") {
                resignedOnBackspace = true
                toDoEntryDelegate?.checkBoxPressed(in: self, deletionInContext: true, resignedOnBackspace: true)
                return false
            }
            
        }
        else if (textView.text.prefix(1) == "⚡️" && range.location < 3) {
            //if the user wants to write text before this position, don't let the user
            print("user writes before the prefix lightning")
            return false
        }
        
        
        
            return true
        
    }
    
    
}
