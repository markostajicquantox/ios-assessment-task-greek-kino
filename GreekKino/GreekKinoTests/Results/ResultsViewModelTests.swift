//
//  ResultsViewModelTests.swift
//  GreekKino
//
//

import XCTest
import Combine

fileprivate class MockAPIService: APIServiceProtocol {
    var mockFetchDataResult: Result<PreviousRoundsResponse, Error>?

    func fetchData<T>(from urlString: String, completion: @escaping (Result<T, Error>) -> Void) where T : Decodable, T : Encodable {
        if let result = mockFetchDataResult as? Result<T, Error> {
            completion(result)
        }
    }
}

struct PreviousRoundsResponse: Codable {
    let content: [GreekKinoRound]
}

struct WinningNumbers: Codable {
    let list: [Int]
}

extension Date {
    func toDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}

class ResultsViewModelTests: XCTestCase {
    var viewModel: ResultsViewModel!
    fileprivate var mockAPIService: MockAPIService!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()
        viewModel = ResultsViewModel(apiService: mockAPIService)
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
        let date = "2024-05-19"
        let expectedRounds = [
            GreekKinoRound(drawId: 1, drawTime: Date().addingTimeInterval(-1000).timeIntervalSince1970 * 1000, winningNumbers: WinningNumbers(list: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]))
        ]
        mockAPIService.mockFetchDataResult = .success(PreviousRoundsResponse(content: expectedRounds))
        
        let expectationPreviousRounds = expectation(description: "Previous rounds are fetched")
        let expectationRefreshControl = expectation(description: "Refresh control is updated")
        
        // When
        viewModel.fetchData(for: date)

        // Then
        viewModel.previousRoundsPublisher
            .sink { previousRounds in
                if let previousRounds = previousRounds {
                    XCTAssertEqual(previousRounds.count, expectedRounds.count)
                    XCTAssertEqual(previousRounds.first?.id, expectedRounds.first?.drawId)
                    XCTAssertEqual(previousRounds.first?.winningNumbers, expectedRounds.first?.winningNumbers?.list)
                    expectationPreviousRounds.fulfill()
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
        
        wait(for: [expectationPreviousRounds, expectationRefreshControl], timeout: 1.0)
    }

    func testFetchDataFailure() {
        // Given
        let date = "2024-05-19"
        let expectedError = APIError.requestFailed
        mockAPIService.mockFetchDataResult = .failure(expectedError)
        
        let expectationError = expectation(description: "Error is emitted")
        
        // When
        viewModel.fetchData(for: date)

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
