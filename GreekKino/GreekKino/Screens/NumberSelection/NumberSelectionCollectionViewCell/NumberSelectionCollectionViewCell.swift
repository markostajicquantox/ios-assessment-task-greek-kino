//
//  NumberSelectionCollectionViewCell.swift
//  GreekKino
//
//

import UIKit

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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        numberLabel.text = nil
        containerView.backgroundColor = .clear
        containerView.layer.borderColor = UIColor.clear.cgColor
    }

    // MARK: - Private methods

    private func setupViews() {
        containerView.layer.borderWidth = 3
        numberLabel.style = .semiboldDark
        containerView.backgroundColor = .clear
        containerView.layer.borderColor = UIColor.clear.cgColor
    }
        
    // MARK: - Public methods

    func configure(with item: NumberSelectionItem) {
        self.item = item
        numberLabel.text = String(item.number)
        containerView.backgroundColor = item.isSelected ? UIColor.border : UIColor.clear
        containerView.layer.borderColor = item.isSelected ? UIColor.random.cgColor : UIColor.clear.cgColor
    }
}
