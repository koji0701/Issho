import Foundation
import UIKit

class ToDoEntryToolbar: UIToolbar {
    
    var dateSelectedCallBack: ((Date) -> ())?
    
    
    let dateButton: UIBarButtonItem = {
        
        let image = UIImage(named: "date")
        let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(dateButtonTapped))
        
        return button
    }()
    
    @objc func dateButtonTapped() {
        print("date button tapped")
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())
        dateSelectedCallBack?(tomorrow!)
    }

    
    convenience init() {
        self.init(frame: .zero)
        self.setItems([dateButton], animated: false)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

