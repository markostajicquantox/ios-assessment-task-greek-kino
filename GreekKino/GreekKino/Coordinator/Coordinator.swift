//
//  Coordinator.swift
//  GreekKino
//
//

import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    func start()
}

class MainCoordinator: Coordinator {
    
    // MARK: - Public properties
    
    var navigationController: UINavigationController

    // MARK: - Initialization

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Public method

    func start() {
        
        setupNavigationBarAppearance()
        let nextRoundsNavController = UINavigationController()
        let webViewNavController = UINavigationController()
        let resultsNavController = UINavigationController()
        
        let nextRoundsViewController = NextRoundsViewController(with: NextRoundsViewModel(), delegate: self)
        nextRoundsViewController.title = Localized.TabBar.nextRounds
        nextRoundsNavController.tabBarItem.title = Localized.TabBar.nextRounds
        nextRoundsNavController.tabBarItem.image = UIImage(systemName: "clock.arrow.circlepath")

        let webViewViewController = WebViewController(url: "https://mozzartbet.com/sr/lotto-animation/26#")
        webViewViewController.title = Localized.TabBar.draw
        webViewNavController.tabBarItem.title = Localized.TabBar.draw
        webViewNavController.tabBarItem.image = UIImage(systemName: "rectangle.stack.badge.plus")

        let resultsViewController = ResultsViewController(with: ResultsViewModel(), delegate: self)
        resultsViewController.title = Localized.TabBar.results
        resultsNavController.tabBarItem.title = Localized.TabBar.results
        resultsNavController.tabBarItem.image = UIImage(systemName: "list.bullet")

        nextRoundsNavController.setViewControllers([nextRoundsViewController], animated: false)
        webViewNavController.setViewControllers([webViewViewController], animated: false)
        resultsNavController.setViewControllers([resultsViewController], animated: false)

        let tabBarController = UITabBarController()
        setupTabBarAppearance(for: tabBarController)
        tabBarController.viewControllers = [nextRoundsNavController, webViewNavController, resultsNavController]

        navigationController.isNavigationBarHidden = true
        navigationController.setViewControllers([tabBarController], animated: true)
    }
    
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .highlight

        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 18, weight: .bold)
        ]
        
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        if #available(iOS 15.0, *) {
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.tintColor = .white
    }

    private func setupTabBarAppearance(for tabBarController: UITabBarController) {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = .secondaryText
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.secondaryText]
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = .highlight
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.highlight]

        tabBarController.tabBar.standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            tabBarController.tabBar.scrollEdgeAppearance = tabBarAppearance
        }
    }
}

// MARK: - NextRoundsViewControllerDelegate

extension MainCoordinator: NextRoundsViewControllerDelegate {
    func openNextRound(with id: Int, from viewController: UIViewController) {
        let numberSelectionViewController = NumberSelectionViewController(with: NumberSelectionViewModel(greekKinoRoundId: id), delegate: self)
        viewController.navigationController?.pushViewController(numberSelectionViewController, animated: true)
    }
}

extension MainCoordinator: NumberSelectionViewControllerDelegate {
    func checkout(from viewController: UIViewController) {
        viewController.showInfoAlert(message: Localized.General.missingFeature)
    }
}

// MARK: - ResultsViewControllerDelegate

extension MainCoordinator: ResultsViewControllerDelegate {
    func openPreviousRound(with id: Int, from viewController: UIViewController) {
        viewController.showInfoAlert(message: Localized.General.missingFeature)
    }
}
