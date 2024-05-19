//
//  NumberSelectionViewFlowLayout.swift
//  GreekKino
//
//

import UIKit

class NumberSelectionViewFlowLayout: UICollectionViewFlowLayout {
    
    // MARK: - Public properties
    
    private(set) var customInsets: UIEdgeInsets = .zero
    private(set) var numberOfColumns: CGFloat
    private(set) var interitemSpacing: CGFloat

    init(customInsets: UIEdgeInsets, numberOfColumns: CGFloat, interitemSpacing: CGFloat) {
        self.customInsets = customInsets
        self.numberOfColumns = numberOfColumns
        self.interitemSpacing = interitemSpacing
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        
        let availableWidth = collectionView.bounds.width - customInsets.left - customInsets.right
        
        let itemWidth = (availableWidth - (numberOfColumns - 1) * interitemSpacing) / numberOfColumns
        
        itemSize = CGSize(width: itemWidth, height: itemWidth)
        minimumInteritemSpacing = interitemSpacing
        minimumLineSpacing = interitemSpacing
        sectionInset = customInsets
    }
}
