//
//  NextRoundsViewController.swift
//  GreekKino
//
//

import UIKit
import Combine

protocol NextRoundsViewControllerDelegate: AnyObject {
    func openNextRound(with id: Int, from viewController: UIViewController)
}

class NextRoundsViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Private properties

    private weak var delegate: NextRoundsViewControllerDelegate?
    private var viewModel: NextRoundsViewModel
    private var dataSource: UITableViewDiffableDataSource<Int, GreekKinoRoundCellItem>!
    private var timer: Timer?
    private var roundItems: [GreekKinoRoundCellItem] = []
    private var refreshControl = UIRefreshControl()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(with viewModel: NextRoundsViewModel, delegate: NextRoundsViewControllerDelegate?) {
        self.viewModel = viewModel
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        setupTableView()
        configureRefreshControl()
        configureDataSource()
        fetchData()
    }
    
    // MARK: - Private methods

    private func bindViewModel() {
        viewModel.refreshControlPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.stopActivityIndicator()
                self?.refreshControl.endRefreshing()
            }.store(in: &cancellables)
        
        viewModel.nextRoundsPublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rounds in
                guard let self = self, let rounds = rounds else { return }
                self.stopActivityIndicator()
                self.roundItems = rounds
                self.configureTimer()
            }.store(in: &cancellables)
        
        viewModel.errorPublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                guard let self = self, let message = message else { return }
                self.stopActivityIndicator()
                self.showErrorAlert(message: message)
            }.store(in: &cancellables)
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .background
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.register(cellType: NextRoundTableViewCell.self)
        tableView.refreshControl = refreshControl
        tableView.delegate = self
    }
            
    private func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }

    @objc private func refreshData() {
        viewModel.fetchData()
    }

    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Int, GreekKinoRoundCellItem>(tableView: tableView) { tableView, indexPath, round in
            let cell = tableView.dequeueReusableCell(NextRoundTableViewCell.self)
            cell.configure(with: round)
            return cell
        }
    }
    
    private func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, GreekKinoRoundCellItem>()
        snapshot.appendSections([0])
        snapshot.appendItems(self.roundItems)
        self.dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func configureTimer() {
        DispatchQueue.main.async { [weak self] in
            self?.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                
                self?.roundItems = self?.roundItems.map { item in
                    var mutableItem = item
                    mutableItem.remainingTime = Int(item.time/1000 - Date().timeIntervalSince1970)
                    return mutableItem
                } ?? []
                self?.updateDataSource()
            }
            
            if let timer = self?.timer {
                RunLoop.current.add(timer, forMode: .common)
            }
        }
    }
    
    private func fetchData() {
        showActivityIndicator(style: .large, color: .highlight)
        viewModel.fetchData()
    }
}

extension NextRoundsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        delegate?.openNextRound(with: item.id, from: self)
    }
}
