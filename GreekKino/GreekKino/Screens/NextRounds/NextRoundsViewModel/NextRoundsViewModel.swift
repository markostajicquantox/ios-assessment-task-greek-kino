//
//  NextRoundsViewModel.swift
//  GreekKino
//
//

import Foundation
import Combine

class NextRoundsViewModel {    

    // MARK: - Private properties
    
    private let refreshControlSubject = CurrentValueSubject<Bool?, Never>(nil)
    private let nextRoundsSubject = CurrentValueSubject<[NextRoundCellItem]?, Never>(nil)
    private let errorSubject = CurrentValueSubject<String?, Never>(nil)
    private let apiService: APIServiceProtocol

    // MARK: - Public properties

    var refreshControlPublisher: AnyPublisher<Bool?, Never> {
        refreshControlSubject.eraseToAnyPublisher()
    }
    
    var nextRoundsPublisher: AnyPublisher<[NextRoundCellItem]?, Never> {
        nextRoundsSubject.eraseToAnyPublisher()
    }

    var errorPublisher: AnyPublisher<String?, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization

    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }

    // MARK: - Public methods

    func fetchData() {
        let url = "https://api.opap.gr/draws/v3.0/1100/upcoming/20"
        apiService.fetchData(from: url) { [weak self] (result: Result<[GreekKinoRound], Error>) in
            self?.refreshControlSubject.value = true
            switch result {
            case .success(let rounds):
                self?.nextRoundsSubject.value = rounds.compactMap { NextRoundCellItem(id: $0.drawId, time: $0.drawTime, startTime: Date(timeIntervalSince1970: $0.drawTime/1000).toHourMinuteString() , remainingTime: Int($0.drawTime/1000 - Date().timeIntervalSince1970)) }
            case .failure(let error):
                self?.errorSubject.value = error.localizedDescription
            }
        }
    }
}
