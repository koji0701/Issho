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
        //datePicker.subviews[0].subviews[0].subviews[0].alpha = 0

        datePicker.addTarget(self, action: #selector(dateChanged(sender:)), for: .valueChanged)
        datePicker.setValue(UIColor.secondarySystemBackground, forKey: "backgroundColor")
        datePicker.subviews[0].subviews[0].subviews[0].alpha = 0
        datePicker.layer.cornerRadius = 10
        let barButton = UIBarButtonItem(customView: datePicker)
        
        return barButton
    }


    @objc func dateChanged(sender: UIDatePicker) {
        dateSelectedCallBack?(sender.date)
    }

    var currentTaskButton: UIBarButtonItem = {
        let button = UIButton(type: .system)
        let boltImage = UIImage(systemName: "bolt")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(weight: .bold))
        button.setImage(boltImage, for: .normal)
        button.tintColor = Settings.progressBar.hasFinishedToday
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(handleCurrentTask), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()

    @objc func handleCurrentTask() {
        let button = currentTaskButton.customView as! UIButton
        if button.imageView?.image == UIImage(systemName: "bolt") {
            button.setImage(UIImage(systemName: "bolt.fill"), for: .normal)
            button.tintColor = Settings.progressBar.hasFinishedToday
            currentTaskCallBack?(true)
        }
        else {
            button.setImage(UIImage(systemName: "bolt"), for: .normal)
            button.tintColor = Settings.progressBar.hasFinishedToday
            currentTaskCallBack?(false)
        }
    }

    convenience init(setDate: Date, isCurrentTask: Bool) {
        self.init(frame: .zero)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        self.setItems([currentTaskButton, flexibleSpace, datePickerItem(setDate)], animated: true)
        let button = currentTaskButton.customView as! UIButton
        if isCurrentTask {//initial color config
            button.setImage(UIImage(systemName: "bolt.fill"), for: .normal)
            button.tintColor = Settings.progressBar.hasFinishedToday
        }
        else {
            button.setImage(UIImage(systemName: "bolt"), for: .normal)
            button.tintColor = Settings.progressBar.hasFinishedToday
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/*
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
        let barButton = UIBarButtonItem(customView: datePicker)
        return barButton
    }

    @objc func dateChanged(sender: UIDatePicker) {
        dateSelectedCallBack?(sender.date)
    }
    
    
    
    var currentTaskButton: UIBarButtonItem = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bolt"), for: .normal)
        
        button.tintColor = Settings.progressBar.hasFinishedToday
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = 5
        
        button.addTarget(self, action: #selector(handleCurrentTask), for: .touchUpInside)
        
        return UIBarButtonItem(customView: button)
    }()
    
    @objc func handleCurrentTask() {
        
        let button = currentTaskButton.customView as! UIButton
        
        if button.imageView?.image == UIImage(systemName: "bolt") {
            button.setImage(UIImage(systemName: "bolt.fill"), for: .normal)
            button.tintColor = Settings.progressBar.hasFinishedToday
            currentTaskCallBack?(true)
        }
        else {
            button.setImage(UIImage(systemName: "bolt"), for: .normal)
            button.tintColor = Settings.progressBar.hasFinishedToday
            currentTaskCallBack?(false)
        }
        
        
    }
    
    convenience init(setDate: Date, isCurrentTask: Bool) {
        self.init(frame: .zero)
        
        
        self.setItems([datePickerItem(setDate), currentTaskButton], animated: true)
        let button = currentTaskButton.customView as! UIButton
        if isCurrentTask {//initial color config
            button.setImage(UIImage(systemName: "bolt.fill"), for: .normal)
            button.tintColor = Settings.progressBar.hasFinishedToday

        }
        else {
            button.setImage(UIImage(systemName: "bolt"), for: .normal)
            button.tintColor = Settings.progressBar.hasFinishedToday
        }
    }
    
    
    
    override init(frame: CGRect) {
       
        super.init(frame: frame)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}*/

