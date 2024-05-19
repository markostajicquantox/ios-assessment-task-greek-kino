//
//  ResultsViewModel.swift
//  GreekKino
//
//

import Foundation
import Combine

class ResultsViewModel {
    
    // MARK: - Private properties

    private let refreshControlSubject = CurrentValueSubject<Bool?, Never>(nil)
    private let previousRoundsSubject = CurrentValueSubject<[ResultItem]?, Never>(nil)
    private let errorSubject = CurrentValueSubject<String?, Never>(nil)
    private let apiService: APIServiceProtocol

    // MARK: - Public properties

    var refreshControlPublisher: AnyPublisher<Bool?, Never> {
        refreshControlSubject.eraseToAnyPublisher()
    }
    
    var previousRoundsPublisher: AnyPublisher<[ResultItem]?, Never> {
        previousRoundsSubject.eraseToAnyPublisher()
    }
    
    var errorPublisher: AnyPublisher<String?, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization

    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }

    // MARK: - Public methods

    func fetchData(for date: String) {
        let url = "https://api.opap.gr/draws/v3.0/1100/draw-date/\(date)/\(date)"
        apiService.fetchData(from: url) { [weak self] (result: Result<PreviousRoundsResponse, Error>) in
            self?.refreshControlSubject.value = true
            switch result {
            case .success(let rounds):
                self?.previousRoundsSubject.value = rounds.content.compactMap { ResultItem(id: $0.drawId, startTime: Date(timeIntervalSince1970: $0.drawTime/1000).toDateString(), winningNumbers: $0.winningNumbers?.list ?? []) }
            case .failure(let error):
                self?.errorSubject.value = error.localizedDescription
            }
        }
    }
}
