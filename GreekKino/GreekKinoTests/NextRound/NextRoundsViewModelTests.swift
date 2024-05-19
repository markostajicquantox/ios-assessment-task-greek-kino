//
//  NextRoundsViewModelTests.swift
//  GreekKinoTests
//
//

import XCTest
import Combine

fileprivate class MockAPIService: APIServiceProtocol {
    var mockFetchDataResult: Result<[GreekKinoRound], Error>?

    func fetchData<T>(from urlString: String, completion: @escaping (Result<T, Error>) -> Void) where T : Decodable, T : Encodable {
        if let result = mockFetchDataResult as? Result<T, Error> {
            completion(result)
        }
    }
}

class NextRoundsViewModelTests: XCTestCase {
    var viewModel: NextRoundsViewModel!
    fileprivate var mockAPIService: MockAPIService!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()
        viewModel = NextRoundsViewModel(apiService: mockAPIService)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockAPIService = nil
        cancellables = nil
        super.tearDown()
    }

    func testFetchDataSuccess() {
        // Given
        let expectedRounds = [
            GreekKinoRound(drawId: 1, drawTime: Date().addingTimeInterval(1000).timeIntervalSince1970 * 1000, winningNumbers: nil)
        ]
        mockAPIService.mockFetchDataResult = .success(expectedRounds as [GreekKinoRound])
        
        let expectationNextRounds = expectation(description: "Next rounds are fetched")
        let expectationRefreshControl = expectation(description: "Refresh control is updated")
        
        // When
        viewModel.fetchData()

        // Then
        viewModel.nextRoundsPublisher
            .sink { nextRounds in
                if let nextRounds = nextRounds {
                    XCTAssertEqual(nextRounds.count, expectedRounds.count)
                    XCTAssertEqual(nextRounds.first?.id, expectedRounds.first?.drawId)
                    XCTAssertEqual(nextRounds.first?.remainingTime, Int(expectedRounds.first!.drawTime/1000 - Date().timeIntervalSince1970))
                    expectationNextRounds.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.refreshControlPublisher
            .sink { refreshControl in
                if let refreshControl = refreshControl {
                    XCTAssertTrue(refreshControl)
                    expectationRefreshControl.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [expectationNextRounds, expectationRefreshControl], timeout: 1.0)
    }

    func testFetchDataFailure() {
        // Given
        let expectedError = APIError.requestFailed
        mockAPIService.mockFetchDataResult = .failure(expectedError)
        
        let expectationError = expectation(description: "Error is emitted")
        
        // When
        viewModel.fetchData()

        // Then
        viewModel.errorPublisher
            .sink { error in
                if let error = error {
                    XCTAssertEqual(error, expectedError.localizedDescription)
                    expectationError.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [expectationError], timeout: 1.0)
    }
}

struct GreekKinoRound: Codable {
    let drawId: Int
    let drawTime: TimeInterval
    let winningNumbers: WinningNumbers?
}

extension Date {
    func toHourMinuteString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
}
