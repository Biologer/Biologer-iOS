import UIKit

final class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    private let addActionViewController = UIViewController()

    var onAddTapped: Observer<Void>?

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        configureAppearance()
    }

    func setTabs(
        findings: UIViewController,
        settings: UIViewController
    ) {
        findings.tabBarItem = UITabBarItem(
            title: "SideMenu.lb.listOfFindings".localized,
            image: UIImage(systemName: "list.bullet"),
            selectedImage: UIImage(systemName: "list.bullet")
        )

        let addImage = UIImage(
            systemName: "plus.circle.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .semibold)
        )
        addActionViewController.tabBarItem = UITabBarItem(
            title: "TabBar.add.title".localized,
            image: addImage,
            selectedImage: addImage
        )
        addActionViewController.tabBarItem.imageInsets = UIEdgeInsets(
            top: -4,
            left: 0,
            bottom: 4,
            right: 0
        )

        settings.tabBarItem = UITabBarItem(
            title: "SideMenu.lb.setup".localized,
            image: UIImage(systemName: "gearshape"),
            selectedImage: UIImage(systemName: "gearshape.fill")
        )

        setViewControllers([findings, addActionViewController, settings], animated: false)
        selectedIndex = 0
    }

    func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {
        guard viewController === addActionViewController else {
            return true
        }

        onAddTapped?(())
        return false
    }

    private func configureAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.12)

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        tabBar.tintColor = .biologerGreenColor
        tabBar.unselectedItemTintColor = .secondaryLabel
    }
}
