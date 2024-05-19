//
//  NumberSelectionViewModelTests.swift
//  GreekKinoTests
//
//

import XCTest
import Combine

fileprivate class MockAPIService: APIServiceProtocol {
    var mockFetchDataResult: Result<GreekKinoRound, Error>?

    func fetchData<T>(from url: String, completion: @escaping (Result<T, Error>) -> Void) where T : Decodable {
        if let result = mockFetchDataResult as? Result<T, Error> {
            completion(result)
        }
    }
}

class NumberSelectionViewModelTests: XCTestCase {
    
    var viewModel: NumberSelectionViewModel!
    fileprivate var apiService: MockAPIService!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        apiService = MockAPIService()
        viewModel = NumberSelectionViewModel(greekKinoRoundId: 1234, apiService: apiService)
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        apiService = nil
        cancellables = nil
        super.tearDown()
    }

    func testFetchDataSuccess() {
        let expectation = XCTestExpectation(description: "Fetch data success")
        
        apiService.mockFetchDataResult = .success(GreekKinoRound(drawId: 1234, drawTime: Date().timeIntervalSince1970 * 1000, winningNumbers: nil))
        
        viewModel.infoTitlePublisher
            .sink { value in
                if value != nil {
                    XCTAssertEqual(value, "ID: 1234\n")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.startTimePublisher
            .sink { value in
                if value != nil {
                    XCTAssertEqual(value, Date(timeIntervalSince1970: Date().timeIntervalSince1970).toHourMinuteString())
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.fetchData()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchDataFailure() {
        let expectation = XCTestExpectation(description: "Fetch data failure")
        
        apiService.mockFetchDataResult = .failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "An error occurred"]))
        
        viewModel.errorPublisher
            .sink { value in
                if value != nil {
                    XCTAssertEqual(value, "An error occurred")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.fetchData()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSetStake() {
        let expectation = XCTestExpectation(description: "Set stake")

        viewModel.oddPublisher
            .sink { value in
                if value != nil {
                    XCTAssertEqual(value, 65.0)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.setStake(nil, selectedNumbersCount: 3)
        
        wait(for: [expectation], timeout: 1.0)
    }

    func testSetStakeWithStake() {
        let expectation = XCTestExpectation(description: "Set stake with value")

        viewModel.prizePublisher
            .sink { value in
                if value != nil {
                    XCTAssertEqual(value, 650.0)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.setStake(10.0, selectedNumbersCount: 3)
        
        wait(for: [expectation], timeout: 1.0)
    }
}
