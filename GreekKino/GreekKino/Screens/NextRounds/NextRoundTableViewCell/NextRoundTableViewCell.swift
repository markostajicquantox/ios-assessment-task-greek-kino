//
//  NextRoundTableViewCell.swift
//  GreekKino
//
//

import UIKit

class NextRoundTableViewCell: UITableViewCell {
    @IBOutlet private weak var backgroundHolderView: UIView!
    @IBOutlet private weak var drawIdLabel: UILabel!
    @IBOutlet private weak var startTimeLabel: UILabel!
    @IBOutlet private weak var remainingTimeLabel: UILabel!
    @IBOutlet private weak var startingSoonLabel: UILabel!
    
    // MARK: - Private properties

    private var item: NextRoundCellItem?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupViews()
        setupLabelStyling(isEnabled: true)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopBlinkingAnimation()
        setupLabelStyling(isEnabled: true)
        startingSoonLabel.isHidden = true
    }
    
    // MARK: - Private methods
    
    private func setupViews() {
        backgroundHolderView.backgroundColor = .cardBackground
        backgroundHolderView.layer.removeAllAnimations()
        backgroundHolderView.layer.borderColor = UIColor.border.cgColor
        backgroundHolderView.layer.borderWidth = 1.0
        backgroundHolderView.layer.cornerRadius = 8
        backgroundHolderView.clipsToBounds = true
        startingSoonLabel.text = Localized.NextRounds.startingSoon
    }
    
    private func setupLabelStyling(isEnabled: Bool) {
        drawIdLabel.style = isEnabled ? .primaryDark : .primaryDisabled
        startTimeLabel.style = isEnabled ? .secondaryDark : .secondaryDisabled
        remainingTimeLabel.style = isEnabled ? .primaryDark : .primaryDisabled
        startingSoonLabel.style = .primaryDestructive
    }

    private func startBlinkingAnimation() {
        let duration = 0.5
        let delay = 0.1
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            UIView.animate(withDuration: duration, delay: 0, options: [.autoreverse, .repeat, .allowUserInteraction], animations: {
                self?.backgroundHolderView.backgroundColor = .disabledCardBackground
            })
        }
    }

    private func stopBlinkingAnimation() {
        backgroundHolderView.layer.removeAllAnimations()
        backgroundHolderView.backgroundColor = .cardBackground
    }
    
    // MARK: - Public methods

    func configure(with item: NextRoundCellItem) {
        self.item = item
        
        // TODO: Normally i would avoid concatenating the placeholder strings (data key) and data value labels, but to save time i opted for this way
        drawIdLabel.text = Localized.NextRounds.round + " \(item.id)"
        startTimeLabel.text = Localized.NextRounds.starts + " \(item.startTime)"
        
        if item.remainingTime <= 0 {
            setupLabelStyling(isEnabled: false)
            remainingTimeLabel.text = Localized.NextRounds.noTimeLeft
            backgroundHolderView.backgroundColor = .disabledCardBackground
            startingSoonLabel.isHidden = true
        } else if item.remainingTime <= 60 {
            remainingTimeLabel.text = "\(item.remainingTime.toMinuteSecondString())"
            startBlinkingAnimation()
            startingSoonLabel.isHidden = false
        } else {
            remainingTimeLabel.text = "\(item.remainingTime.toMinuteSecondString())"
            backgroundHolderView.backgroundColor = .cardBackground
            startingSoonLabel.isHidden = true
        }
    }
}
