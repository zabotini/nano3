 //
 //  AddTaskViewController.swift
 //  nano3
 //
 //  Created by Rafael Zabotini on 12/02/18.
 //  Copyright © 2018 Rafael Zabotini. All rights reserved.
 //
 
 import UIKit
 import CoreData
 
 class AddTaskViewController: UIViewController {
    
    //MARK: - Properties
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .default
	}
	
    var managedContext: NSManagedObjectContext!
    var task: Task?
    
    //MARK: Outlets
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
	override func loadView() {
		super.loadView()
		setNeedsStatusBarAppearanceUpdate()
	}
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.text = "Describe it because empty wishes actually are nil... And we can't save nil ;)"
        textView.textColor = UIColor.lightGray
        doneButton.isHidden = true
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(with:)),
            name: .UIKeyboardWillShow,
            object: nil
        )
        textField.becomeFirstResponder()
        
        if let task = task {
            textField.text = task.title
            textView.text = task.text
            textView.text = task.text
            segmentedControl.selectedSegmentIndex = Int(Int16(task.category))
            
        }
    }
    
    //MARK: Actions
    
    @objc func keyboardWillShow(with notification: Notification) {
        let key = "UIKeyboardFrameEndUserInfoKey"
        guard let keyboardFrame = notification.userInfo?[key] as? NSValue else {
            print("fail")
            return
        }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        bottomConstraint.constant = keyboardHeight + 8
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
            print("layoutUpdated - keyboardShow")
        }
    }
    
    fileprivate func dismissAndResign() {
        dismiss(animated: true)
        textField.resignFirstResponder()
    }
    
    //MARK: - Actions for buttons
    
    @IBAction func done(_ sender: Any) {
        
        guard let title = textField.text, !title.isEmpty else { return }
        guard let text = textView.text, !text.isEmpty else { return }
        
        if let task = self.task { // When selected one existing task to edit
            task.title = title
            task.text = text
            task.category = Int16(segmentedControl.selectedSegmentIndex)
        } else { // When created a new task
            let task = Task(context: managedContext)
            task.title = title
            task.text = text
            task.category = Int16(segmentedControl.selectedSegmentIndex)
            task.date = Date()
        }
        
        do {
            try managedContext.save()
            dismissAndResign()
        } catch {
            print("Error savind data: \(error)")
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismissAndResign()
    }
    @IBAction func cancelSwipe(_ sender: Any) {
        dismissAndResign()
    }
    
 }
 
 //MARK: - Code extensions
 
 extension AddTaskViewController:  UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Heyyyyy! Did you forgot me?"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        
        if doneButton.isHidden && !textView.text.isEmpty {
            
            textView.tintColor = .red
            textView.autocapitalizationType = .sentences
            doneButton.isHidden = false
            
            
            // Animate button DONE
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
                print("layoutUpdated - removeText")
            }
        } else if !doneButton.isHidden && textView.text == "Heyyyyy! Did you forgot me?" {
            doneButton.isHidden = true
        }
    }
 }
 
 extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
 }
