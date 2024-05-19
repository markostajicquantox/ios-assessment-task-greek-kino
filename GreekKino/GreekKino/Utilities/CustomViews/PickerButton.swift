//
//  RandomSelectionButton.swift
//  GreekKino
//
//

import UIKit

protocol Pickable {
    var title: String { get set }
    var value: Int { get set }
}

struct RandomSelectionElement: Pickable {
    var title: String
    var value: Int
}

struct CashStake: Pickable {
    var title: String
    var value: Int
}

class PickerButton<T: Pickable>: UIButton, UIPickerViewDataSource, UIPickerViewDelegate {
    
    private var selectedElement: T?
    private var onSelect: VoidReturnClosure<T?>?
    private var dataSource: [T] = []
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    private let pickerView = UIPickerView()
    
    override var inputView: UIView? {
        return pickerView
    }
    
    override var inputAccessoryView: UIView? {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        let cancelButton = UIBarButtonItem(title: Localized.PickerView.cancel, style: .plain, target: self, action: #selector(cancelButtonTapped))
        let doneButton = UIBarButtonItem(title: Localized.PickerView.done, style: .done, target: self, action: #selector(doneButtonTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancelButton, flexibleSpace, doneButton], animated: false)
        return toolbar
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPickerView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPickerView()
    }
    
    private func setupPickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc private func doneButtonTapped() {
        resignFirstResponder()
        onSelect?(selectedElement)
    }
    
    @objc private func cancelButtonTapped() {
        resignFirstResponder()
    }
    
    @objc private func buttonTapped() {
        becomeFirstResponder()
        if selectedElement == nil {
            selectedElement = dataSource.first
        }
    }
    
    func configure(with dataSource: [T], selectAction: VoidReturnClosure<T?>?) {
        self.dataSource = dataSource
        self.onSelect = selectAction
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSource[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Handle selection
        self.selectedElement = dataSource[row]
    }
}
