//
//  NumberSelectionCollectionViewCell.swift
//  GreekKino
//
//

import UIKit

typealias NoArgsClosure = () -> Void
typealias VoidReturnClosure<T> = (T) -> Void

struct NumberSelectionItem: Hashable, Equatable {
    let number: Int
    var isSelected: Bool
    var onSelect: NoArgsClosure?
    
    static func == (lhs: NumberSelectionItem, rhs: NumberSelectionItem) -> Bool {
        lhs.number == rhs.number && lhs.isSelected == rhs.isSelected
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(number)
        hasher.combine(isSelected)
    }
}

class NumberSelectionCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var numberLabel: UILabel!
    @IBOutlet private weak var containerView: CircleView!
    
    // MARK: - Private properties

    private var item: NumberSelectionItem?
    
    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    // MARK: - Private methods

    private func setupViews() {
        numberLabel.style = .numberSelection
        containerView.backgroundColor = .clear
    }
        
    // MARK: - Public methods

    func configure(with item: NumberSelectionItem) {
        self.item = item
        numberLabel.text = String(item.number)
        containerView.layer.borderWidth = 3
        containerView.backgroundColor = item.isSelected ? UIColor.border : UIColor.clear
        containerView.layer.borderColor = item.isSelected ? UIColor.random.cgColor : UIColor.clear.cgColor
    }
}
