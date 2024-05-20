//
//  ResultsTableViewCell.swift
//  GreekKino
//
//

import UIKit

class ResultsTableViewCell: UITableViewCell {
    @IBOutlet private weak var timeAndRoundLabel: UILabel!
    @IBOutlet private weak var backgroundHolderView: UIView!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Private properties

    private var items: [NumberSelectionItem] = []
    private var dataSource: UICollectionViewDiffableDataSource<Int, NumberSelectionItem>!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupViews()
        setupCollectionView()
        configureDataSource()
    }
        
    // MARK: - Private methods
    
    private func setupViews() {
        backgroundHolderView.backgroundColor = .cardBackground
        backgroundHolderView.layer.removeAllAnimations()
        backgroundHolderView.layer.borderColor = UIColor.border.cgColor
        backgroundHolderView.layer.borderWidth = 1.0
        backgroundHolderView.layer.cornerRadius = 8
        backgroundHolderView.clipsToBounds = true
        timeAndRoundLabel.style = .secondaryDark
    }
    
    private func setupCollectionView() {
        let layout = NumberSelectionViewFlowLayout(
            customInsets: LayoutConstants.customInsets,
            numberOfColumns: LayoutConstants.numberOfColumns,
            interitemSpacing: LayoutConstants.interitemSpacing
        )
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .white
        collectionView.register(cellType: NumberSelectionCollectionViewCell.self)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, NumberSelectionItem>(collectionView: collectionView) {
            (collectionView, indexPath, item) -> UICollectionViewCell? in
            let cell = collectionView.dequeReusableCellOfType(NumberSelectionCollectionViewCell.self, indexPath: indexPath)
            cell.configure(with: item)
            return cell
        }
    }

    private func updateDataSource() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            var snapshot = NSDiffableDataSourceSnapshot<Int, NumberSelectionItem>()
            snapshot.appendSections([0])
            snapshot.appendItems(self.items)
            
            dataSource.apply(snapshot, animatingDifferences: false) {
                self.adjustCollectionViewHeight()
            }
        }
    }
    
    private func adjustCollectionViewHeight() {
        guard let layout = collectionView.collectionViewLayout as? NumberSelectionViewFlowLayout else { return }

        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        guard numberOfItems > 0 else {
            collectionViewHeightConstraint.constant = 0
            collectionView.layoutIfNeeded()
            return
        }
        
        let numberOfRows = ceil(CGFloat(numberOfItems) / layout.numberOfColumns)
        let itemHeight = layout.itemSize.height
        let totalVerticalSpacing = layout.minimumLineSpacing * (numberOfRows - 1)
        let totalHeight = (itemHeight * numberOfRows) + totalVerticalSpacing + layout.customInsets.top + layout.customInsets.bottom

        collectionViewHeightConstraint.constant = totalHeight
        collectionView.layoutIfNeeded()
    }

    // MARK: - Public methods

    func configure(with item: ResultItem) {
        timeAndRoundLabel.text = Localized.Results.time + " \(item.startTime) | " + Localized.Results.round + " \(item.id)"
        self.items = item.winningNumbers.map { NumberSelectionItem(number: $0, isSelected: true, onSelect: nil) }
        updateDataSource()
    }
}
