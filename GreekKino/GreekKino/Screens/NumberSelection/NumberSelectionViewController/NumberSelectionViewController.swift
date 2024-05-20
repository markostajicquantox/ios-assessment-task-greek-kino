//
//  NumberSelectionViewController.swift
//  GreekKino
//
//

import UIKit
import Combine

protocol NumberSelectionViewControllerDelegate: AnyObject {
    func checkout(from viewController: UIViewController)
}

class NumberSelectionViewController: UIViewController {
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var selectedItemLabel: UILabel!
    @IBOutlet private weak var stakeSelectionButtonContainer: UIView!
    @IBOutlet private weak var randomSelectionButtonContainer: UIView!
    @IBOutlet private weak var prizeInfoLabel: UILabel!
    @IBOutlet private weak var remainingTimeLabel: UILabel!
    @IBOutlet private weak var checkoutButton: UIButton!
    @IBOutlet private weak var clearSelectionButton: UIButton!
    @IBOutlet private weak var oddInfoLabel: UILabel!
    @IBOutlet private weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Private properties
    
    private weak var delegate: NumberSelectionViewControllerDelegate?
    private var viewModel: NumberSelectionViewModel
    private var randomSelectionButton: PickerButton<RandomSelectionElement>!
    private var stakeSelectionButton: PickerButton<CashStake>!
    private var cancellables = Set<AnyCancellable>()
    private var dataSource: UICollectionViewDiffableDataSource<Int, NumberSelectionItem>!
    private var stake: Double?
    private var selectedItems: [NumberSelectionItem] = [] {
        didSet {
            let numbers = selectedItems.map { $0.number }.map { String($0) }.joined(separator: ", ")
            selectedItemLabel.text = Localized.NumberSelection.selectedNumbers + " \(numbers)"
            viewModel.setStake(stake, selectedNumbersCount: selectedItems.count)
        }
    }
    private var items = GKConstants.possibleNumbers.compactMap { NumberSelectionItem(number: $0, isSelected: false, onSelect: nil) }
    
    // MARK: - Initialization

    init(with viewModel: NumberSelectionViewModel, delegate: NumberSelectionViewControllerDelegate?) {
        self.viewModel = viewModel
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        setupTexts()
        setupViews()
        setItemsSelectAction()
        setRandomSelectionButton()
        setStakeSelectionButton()
        setupCollectionView()
        configureDataSource()
        updateDataSource()
        fetchData()
    }
    
    // MARK: - Private actions

    @IBAction private func checkoutAction(_ sender: Any) {
        delegate?.checkout(from: self)
    }
    
    @IBAction func clearSelectionAction(_ sender: Any) {
        removeAllSelectedItems()
        updateDataSource()
        selectedItemLabel.text = Localized.NumberSelection.selectedNumbers
        prizeInfoLabel.text = Localized.NumberSelection.potentialPrize
        oddInfoLabel.text = Localized.NumberSelection.odd
    }
    
    // MARK: - Private methods

    private func bindViewModel() {
        viewModel.infoTitlePublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                guard let self = self, let text = text else { return }
                self.title = text
                self.stopActivityIndicator()
            }.store(in: &cancellables)
        
        viewModel.startTimePublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] time in
                guard let self = self, let time = time else { return }
                let timeLabel = UILabel()
                timeLabel.style = .primaryNavigation
                timeLabel.text = "⏱️" + " \(time)"
                navigationItem.rightBarButtonItem = UIBarButtonItem(customView: timeLabel)
            }.store(in: &cancellables)

        viewModel.errorPublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                guard let self = self, let message = message else { return }
                self.stopActivityIndicator()
                self.showErrorAlert(message: message)
            }.store(in: &cancellables)

        viewModel.oddPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] odd in
                guard let self = self else { return }
                guard let odd = odd else {
                    return
                }
                self.oddInfoLabel.text = Localized.NumberSelection.odd + ((odd != 0) ? " \(String(format: "%.2f", odd))" : "")
            }.store(in: &cancellables)

        viewModel.prizePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] prize in
                guard let self = self else { return }
                guard let prize = prize else {
                    self.prizeInfoLabel.text = Localized.NumberSelection.potentialPrize
                    return
                }
                self.prizeInfoLabel.text = Localized.NumberSelection.potentialPrize + " \(String(format: "%.2f", prize))" + " " + GKConstants.stakeCurrency
            }.store(in: &cancellables)
        
        viewModel.remainingTimePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] remainingTime in
                guard let self = self, let remainingTime = remainingTime else { return }
                if remainingTime <= 0 {
                    self.remainingTimeLabel.style = .secondaryDestructive
                    self.remainingTimeLabel.text = Localized.NumberSelection.remainingTimeNoTimeLeft
                    self.checkoutButton.isEnabled = false
                    self.clearSelectionButton.isEnabled = false
                    self.collectionView.isUserInteractionEnabled = false
                    self.randomSelectionButton.isEnabled = false
                    self.stakeSelectionButton.isEnabled = false
                } else {
                    self.remainingTimeLabel.style = .secondaryDark
                    self.remainingTimeLabel.text = Localized.NumberSelection.remainingTime + " \(remainingTime.toMinuteSecondString())"
                    self.checkoutButton.isEnabled = true
                    self.clearSelectionButton.isEnabled = true
                    self.collectionView.isUserInteractionEnabled = true
                    self.randomSelectionButton.isEnabled = true
                    self.stakeSelectionButton.isEnabled = true
                }
            }.store(in: &cancellables)
    }
        
    private func setupTexts() {
        navigationController?.navigationBar.topItem?.title = ""
        selectedItemLabel.text = Localized.NumberSelection.selectedNumbers
        prizeInfoLabel.text = Localized.NumberSelection.potentialPrize
        oddInfoLabel.text = Localized.NumberSelection.odd
        remainingTimeLabel.text = Localized.NumberSelection.remainingTime
    }
    
    private func setupViews() {
        selectedItemLabel.style = .primaryDark
        prizeInfoLabel.style = .semiboldDark
        oddInfoLabel.style = .secondaryDark
        remainingTimeLabel.style = .secondaryDark
        randomSelectionButtonContainer.backgroundColor = .blinking
        stakeSelectionButtonContainer.backgroundColor = .blinking
        randomSelectionButtonContainer.layer.cornerRadius = 8
        stakeSelectionButtonContainer.layer.cornerRadius = 8
        randomSelectionButtonContainer.clipsToBounds = true
        stakeSelectionButtonContainer.clipsToBounds = true
        clearSelectionButton.layer.cornerRadius = 8
        clearSelectionButton.clipsToBounds = true
        clearSelectionButton.setTitleColor(.white, for: .normal)
        clearSelectionButton.setTitleColor(.white, for: .highlighted)
        clearSelectionButton.backgroundColor = .destructive
        clearSelectionButton.setTitle(Localized.NumberSelection.clear, for: .normal)
        checkoutButton.layer.cornerRadius = 8
        checkoutButton.clipsToBounds = true
        checkoutButton.setTitleColor(.white, for: .normal)
        checkoutButton.setTitleColor(.white, for: .highlighted)
        checkoutButton.backgroundColor = .highlight
        checkoutButton.setTitle(Localized.NumberSelection.checkout, for: .normal)
    }
 
    private func setItemsSelectAction() {
        for (index, _) in items.enumerated() {
            items[index].onSelect = { [weak self] in
                guard let self = self else { return }
                if !self.items[index].isSelected {
                    if selectedItems.count < GKConstants.manualSelectionMaximum {
                        self.items[index].isSelected.toggle()
                        self.selectedItems.append(self.items[index])
                    }
                } else {
                    self.items[index].isSelected.toggle()
                    if let index = self.selectedItems.firstIndex(where: { $0.number == self.items[index].number }) {
                        self.selectedItems.remove(at: index)
                    }
                }
                self.updateDataSource()
            }
        }
    }

    private func setRandomSelectionButton() {
        randomSelectionButton = PickerButton(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 32, height: 50))
        randomSelectionButton.setTitle(Localized.NumberSelection.random, for: .normal)
        randomSelectionButton.fixInView(randomSelectionButtonContainer)
        
        let randomSelectionDataSource = Array(1...GKConstants.randomSelectionMaximum).map { RandomSelectionElement(title: String($0) + (($0 == 1) ? " \(Localized.NumberSelection.number)" : " \(Localized.NumberSelection.numbers)"), value: $0) }
        
        randomSelectionButton.configure(with: randomSelectionDataSource, selectAction: { [weak self] randomSelectionElement in
            guard let randomSelectionElement = randomSelectionElement else { return }
            
            self?.randomSelectionButton.setTitle(Localized.NumberSelection.random + ": \(randomSelectionElement.value)", for: .normal)
            self?.removeAllSelectedItems()
            self?.randomSelectItems(count: randomSelectionElement.value)
        })
    }
    
    private func setStakeSelectionButton() {
        stakeSelectionButton = PickerButton(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 32, height: 50))
        stakeSelectionButton.setTitle(Localized.NumberSelection.stake, for: .normal)
        stakeSelectionButton.fixInView(stakeSelectionButtonContainer)
        
        let stakeDataSource = GKConstants.possibleStakes.map { CashStake(title: String($0) + " " + GKConstants.stakeCurrency, value: $0) }
        
        stakeSelectionButton.configure(with: stakeDataSource, selectAction: { [weak self] cashStake in
            guard let self = self, let cashStake = cashStake else { return }
            
            self.stake = Double(cashStake.value)
            self.stakeSelectionButton.setTitle(cashStake.title, for: .normal)
            self.viewModel.setStake(self.stake, selectedNumbersCount: self.selectedItems.count)
        })
    }
        
    private func setupCollectionView() {
        let layout = NumberSelectionViewFlowLayout(
            customInsets: LayoutConstants.customInsets,
            numberOfColumns: LayoutConstants.numberOfColumns,
            interitemSpacing: LayoutConstants.interitemSpacing
        )
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .white
        collectionView.delegate = self
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
    
    private func removeAllSelectedItems() {
        self.selectedItems.removeAll()
        for (index, _) in items.enumerated() {
            items[index].isSelected = false
        }
    }
    
    private func randomSelectItems(count: Int) {
        let randomElements = GKConstants.possibleNumbers.shuffled().prefix(count)
        randomElements.forEach { element in
            if let index = items.firstIndex(where: { $0.number == element }) {
                items[index].isSelected = true
                selectedItems.append(items[index])
            }
        }
        updateDataSource()
    }
    
    private func adjustCollectionViewHeight() {
        guard let layout = collectionView.collectionViewLayout as? NumberSelectionViewFlowLayout else { return }
        
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        let numberOfRows = ceil(CGFloat(numberOfItems) / layout.numberOfColumns)
        
        let itemHeight = layout.itemSize.height
        let totalVerticalSpacing = layout.minimumLineSpacing * (numberOfRows - 1)
        let totalHeight = (itemHeight * numberOfRows) + totalVerticalSpacing + layout.customInsets.top + layout.customInsets.bottom
        
        collectionViewHeightConstraint.constant = totalHeight
        collectionView.layoutIfNeeded()
    }
    
    private func fetchData() {
        showActivityIndicator(style: .large, color: .highlight)
        viewModel.fetchData()
    }
}

// MARK: - UICollectionViewDelegate

extension NumberSelectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }

        item.onSelect?()
    }
}
