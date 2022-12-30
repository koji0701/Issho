import Foundation
import UIKit

class ToDoEntryToolbar: UIToolbar {
    
    let dateButton: UIBarButtonItem = {
        
        let image = UIImage(named: "date")
        let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(dateButtonTapped))
        
        return button
    }()
    
    @objc func dateButtonTapped() {
        print("date button tapped")
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

