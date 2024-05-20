//
//  NumberSelectionViewModel.swift
//  GreekKino
//
//

import Foundation
import Combine

class NumberSelectionViewModel {
    
    // MARK: - Private properties
    
    private var greekKinoRoundId: Int
    private var greekKinoRound: GreekKinoRound?
    private let infoTitleSubject = CurrentValueSubject<String?, Never>(nil)
    private let startTimeSubject = CurrentValueSubject<String?, Never>(nil)
    private let errorSubject = PassthroughSubject<String?, Never>()
    private let oddSubject = CurrentValueSubject<Double?, Never>(nil)
    private let prizeSubject = CurrentValueSubject<Double?, Never>(nil)
    private let remainingTimeSubject = CurrentValueSubject<Int?, Never>(nil)
    private var timer: Timer?
    private let apiService: APIServiceProtocol

    // MARK: - Public properties

    var infoTitlePublisher: AnyPublisher<String?, Never> {
        infoTitleSubject.eraseToAnyPublisher()
    }
    
    var startTimePublisher: AnyPublisher<String?, Never> {
        startTimeSubject.eraseToAnyPublisher()
    }
    
    var errorPublisher: AnyPublisher<String?, Never> {
        errorSubject.eraseToAnyPublisher()
    }

    var oddPublisher: AnyPublisher<Double?, Never> {
        oddSubject.eraseToAnyPublisher()
    }
    
    var prizePublisher: AnyPublisher<Double?, Never> {
        prizeSubject.eraseToAnyPublisher()
    }
    
    var remainingTimePublisher: AnyPublisher<Int?, Never> {
        remainingTimeSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization

    init(greekKinoRoundId: Int, apiService: APIServiceProtocol = APIService()) {
        self.greekKinoRoundId = greekKinoRoundId
        self.apiService = apiService
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Private methods

    private func configureTimer(with drawTime: TimeInterval) {
        DispatchQueue.main.async { [weak self] in
            self?.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                let remainingTime = Int(drawTime/1000 - Date().timeIntervalSince1970)
                self?.remainingTimeSubject.value = remainingTime
            }
            if let timer = self?.timer {
                RunLoop.current.add(timer, forMode: .common)
            }
        }
    }
    
    // MARK: - Public methods
    
    func fetchData() {
        let url = "https://api.opap.gr/draws/v3.0/1100/\(greekKinoRoundId)"
        apiService.fetchData(from: url) { [weak self] (result: Result<GreekKinoRound, Error>) in
            switch result {
            case .success(let round):
                self?.greekKinoRound = round
                self?.infoTitleSubject.value = Localized.NumberSelection.id + " \(round.drawId)\n"
                self?.startTimeSubject.value = Date(timeIntervalSince1970: round.drawTime/1000).toHourMinuteString()
                self?.configureTimer(with: round.drawTime)
            case .failure(let error):
                self?.errorSubject.send(error.localizedDescription)
            }
        }
    }
    
    func setStake(_ stake: Double?, selectedNumbersCount: Int) {
        guard let stake = stake else {
            updateOdds(for: selectedNumbersCount)
            return
        }
       
        if selectedNumbersCount == 0 {
            self.oddSubject.value = 0
            self.prizeSubject.value = nil
        } else if let odd = GKConstants.odds.first(where: { $0.number == selectedNumbersCount }) {
            self.oddSubject.value = odd.odd
            self.prizeSubject.value = odd.odd * stake
        } else {
            calculateCombinationOdds(for: selectedNumbersCount, stake: stake)
        }
    }
    
    private func updateOdds(for selectedNumbersCount: Int) {
        if let odd = GKConstants.odds.first(where: { $0.number == selectedNumbersCount }) {
            self.oddSubject.value = odd.odd
        } else if selectedNumbersCount != 0 {
            let combinationCount = CombinationCalculator(n: selectedNumbersCount, k: GKConstants.odds.count).combinations()
            if let maxOdd = GKConstants.odds.compactMap({ $0.odd }).max() {
                let odd = maxOdd / combinationCount
                self.oddSubject.value = odd
            }
        }
    }

    private func calculateCombinationOdds(for selectedNumbersCount: Int, stake: Double) {
        let combinationCount = CombinationCalculator(n: selectedNumbersCount, k: GKConstants.odds.count).combinations()
        guard let maxOdd = GKConstants.odds.compactMap({ $0.odd }).max() else {
            self.prizeSubject.value = nil
            self.oddSubject.value = nil
            return
        }
        let odd = maxOdd / combinationCount
        self.oddSubject.value = odd
        self.prizeSubject.value = odd * stake
    }
}
