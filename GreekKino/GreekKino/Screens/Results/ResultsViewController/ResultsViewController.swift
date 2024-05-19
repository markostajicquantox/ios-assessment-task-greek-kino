//
//  ResultsViewController.swift
//  GreekKino
//
//

import UIKit
import Combine

protocol ResultsViewControllerDelegate: AnyObject {
    func openPreviousRound(with id: Int, from viewController: UIViewController)
}

class ResultsViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Private properties

    private weak var delegate: ResultsViewControllerDelegate?
    private var viewModel: ResultsViewModel
    private var dataSource: UITableViewDiffableDataSource<Int, ResultItem>!
    private var timer: Timer?
    private var resultItems: [ResultItem] = []
    private var refreshControl = UIRefreshControl()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(with viewModel: ResultsViewModel, delegate: ResultsViewControllerDelegate?) {
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
        setupViews()
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
        
        viewModel.previousRoundsPublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rounds in
                guard let self = self, let rounds = rounds else { return }
                self.stopActivityIndicator()
                self.resultItems = rounds
                self.updateDataSource()
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
    
    private func setupViews() {
        self.title = Localized.TabBar.results
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(cellType: ResultsTableViewCell.self)
        tableView.refreshControl = refreshControl
    }
            
    private func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }

    @objc private func refreshData() {
        fetchData()
    }

    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Int, ResultItem>(tableView: tableView) { tableView, indexPath, round in
            let cell = tableView.dequeueReusableCell(ResultsTableViewCell.self)
            cell.configure(with: round)
            return cell
        }
    }
    
    private func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, ResultItem>()
        snapshot.appendSections([0])
        snapshot.appendItems(self.resultItems)
        self.dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func fetchData() {
        showActivityIndicator(style: .large, color: .highlight)
        viewModel.fetchData()
    }
}
