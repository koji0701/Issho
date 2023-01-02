import Foundation
import UIKit

class ToDoEntryToolbar: UIToolbar {
    
    var dateSelectedCallBack: ((Date) -> ())?
    
    
    let datePicker = UIDatePicker()
        
    convenience init() {
        self.init(frame: .zero)
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        let datePickerItem = UIBarButtonItem(customView: datePicker)
        self.setItems([datePickerItem], animated: true)
    }
    
    @objc func dateChanged() {
        dateSelectedCallBack?(datePicker.date)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

