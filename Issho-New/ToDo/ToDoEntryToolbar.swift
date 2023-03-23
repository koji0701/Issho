import Foundation
import UIKit



class ToDoEntryToolbar: UIToolbar {
    
    var dateSelectedCallBack: ((Date) -> ())?
    var currentTaskCallBack: ((Bool) -> ())?
    
    let datePickerItem: ((Date) -> UIBarButtonItem) = { setDate in
        let datePicker = UIDatePicker()
        let calendar = Calendar.current
        datePicker.date = setDate
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(dateChanged(sender:)), for: .valueChanged)
        return UIBarButtonItem(customView: datePicker)
    }

    @objc func dateChanged(sender: UIDatePicker) {
        dateSelectedCallBack?(sender.date)
    }
    
    
    
    var currentTaskButton: UIBarButtonItem = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bolt"), for: .normal)
        
        button.tintColor = .black
        button.backgroundColor = .systemGray5
        button.layer.cornerRadius = 5
        
        button.addTarget(self, action: #selector(handleCurrentTask), for: .touchUpInside)
        
        return UIBarButtonItem(customView: button)
    }()
    
    @objc func handleCurrentTask() {
        
        let button = currentTaskButton.customView as! UIButton
        
        if button.imageView?.image == UIImage(systemName: "bolt") {
            button.setImage(UIImage(systemName: "bolt.fill"), for: .normal)
            button.tintColor = .systemYellow
            currentTaskCallBack?(true)
        }
        else {
            button.setImage(UIImage(systemName: "bolt"), for: .normal)
            button.tintColor = .black
            currentTaskCallBack?(false)
        }
        
        
    }
    
    convenience init(setDate: Date, isCurrentTask: Bool) {
        self.init(frame: .zero)
        
        
        self.setItems([datePickerItem(setDate), currentTaskButton], animated: true)
        let button = currentTaskButton.customView as! UIButton
        if isCurrentTask {//initial color config
            button.setImage(UIImage(systemName: "bolt.fill"), for: .normal)
            button.tintColor = .systemYellow
            
        }
        else {
            button.setImage(UIImage(systemName: "bolt"), for: .normal)
            button.tintColor = .black
        }
    }
    
    
    
    override init(frame: CGRect) {
       
        super.init(frame: frame)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

