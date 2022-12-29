//
//  ToDoEntryCell.swift
//  Issho
//
//  Created by Koji Wong on 6/6/22.
//

import UIKit

protocol ToDoEntryDelegate {
    func checkBoxPressed(in cell: UITableViewCell)
    func createNewToDoEntryCell(in cell: UITableViewCell) -> ToDoEntryCell
    func saveInfoToContext(in cell: UITableViewCell)
}



class ToDoEntryCell: UITableViewCell,UITextViewDelegate  {

    @IBOutlet weak var checkboxButton: UIButton!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var addButton: UIButton!
    
    
    @IBOutlet weak var selectedView: UIView!
    
    
    @IBOutlet weak var textViewWrapper: UIView!
    
    
    @IBOutlet weak var regularView: UIStackView!
    
    @IBOutlet weak var dateTextField: UITextField!
    
    
    
    
    var toDoEntryDelegate: ToDoEntryDelegate!
    
    var toDoEntry: ToDoEntry? {
        didSet {
            
            textView.text = toDoEntry?.text
        }//not sure if i need this whole toDoEntry thing anymore because i edit it in here then ill send it back to be saved in the context. coredata can handle the permanent saving of the edits over here i dont need to load it back
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
        
        selectedView.isHidden = false
        
        
        //MARK: temporary
        addButton.isHidden = true
        checkboxButton.isHidden = false
        checkboxButton.isEnabled = true
        addButton.isEnabled = false
        
        //button images
        //circle.inset.filled,circle
        //checkboxButton.setImage(UIImage(named: "circle"), for: .normal)
        //addButton.setImage(UIImage(named: "plus.circle"), for: .normal)
        
        
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
        self.toDoEntryDelegate?.saveInfoToContext(in: self)
        print("text View did finish editing")
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
    
    //date text field
    //MARK: USE THE SAVEINFO TO CONTEXT FEATURE FOR THE TEXTFIELD
    
    @IBAction func dateTextFieldFinishedEditing(_ sender: Any) {
        
        self.toDoEntryDelegate?.saveInfoToContext(in: self)
        
    }
    
}



