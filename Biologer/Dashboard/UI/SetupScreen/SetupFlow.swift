import SwiftUI

struct SetupFlow: View {

    private enum Screen: Hashable {
        case dataLicense
        case imageLicense
    }

    private enum PresentedSheet: Identifiable {
        case projectName
        case downloadUpload

        var id: String {
            switch self {
            case .projectName:
                return "projectName"
            case .downloadUpload:
                return "downloadUpload"
            }
        }
    }

    private enum SetupAlert: Identifiable {
        case confirmTaxonReset
        case taxaEmpty
        case taxaReset

        var id: String {
            switch self {
            case .confirmTaxonReset:
                return "confirmTaxonReset"
            case .taxaEmpty:
                return "taxaEmpty"
            case .taxaReset:
                return "taxaReset"
            }
        }
    }

    @StateObject
    private var setupViewModel: SetupScreenViewModel

    @State
    private var path: NavigationPath = .init()

    @State
    private var selectedDataLicense: CheckMarkItem

    @State
    private var selectedImageLicense: CheckMarkItem

    @State
    private var presentedSheet: PresentedSheet?

    @State
    private var setupAlert: SetupAlert?

    private let setupUseCase: SetupUseCase
    private let onSideMenuTapped: Observer<Void>
    private let onStartDownloadTaxon: Observer<Void>

    init(
        setupUseCase: SetupUseCase,
        onSideMenuTapped: @escaping Observer<Void>,
        onStartDownloadTaxon: @escaping Observer<Void>
    ) {
        self.setupUseCase = setupUseCase
        self.onSideMenuTapped = onSideMenuTapped
        self.onStartDownloadTaxon = onStartDownloadTaxon
        _setupViewModel = StateObject(
            wrappedValue: SetupScreenViewModel(
                useCase: setupUseCase,
                onItemTapped: { _ in }
            )
        )
        _selectedDataLicense = State(initialValue: setupUseCase.selectedDataLicense())
        _selectedImageLicense = State(initialValue: setupUseCase.selectedImageLicense())
    }

    var body: some View {
        NavigationStack(path: $path) {
            setupScreen
                .navigationDestination(for: Screen.self) { screen in
                    switch screen {
                    case .dataLicense:
                        dataLicenseScreen
                    case .imageLicense:
                        imageLicenseScreen
                    }
                }
        }
        .sheet(item: $presentedSheet) { sheet in
            switch sheet {
            case .projectName:
                projectNameScreen
            case .downloadUpload:
                downloadAndUploadScreen
            }
        }
        .alert(item: $setupAlert) { alert in
            makeAlert(alert)
        }
    }

    private var setupScreen: some View {
        SetupScreen(
            viewModel: setupViewModel,
            onItemTapped: { item in
                handle(item)
            }
        )
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    onSideMenuTapped(())
                }) {
                    Image("side_menu_icon")
                        .renderingMode(.original)
                }
            }

            ToolbarItem(placement: .principal) {
                Text("SideMenu.lb.setup".localized)
                    .font(.system(size: navigationBarTitleSize, weight: .bold))
                    .foregroundColor(Color(.darkText))
            }
        }
    }

    private var dataLicenseScreen: some View {
        LicenseSelectionScreen(
            selectedItem: $selectedDataLicense,
            items: setupUseCase.dataLicenses(),
            onSelectionChanged: { item in
                setupUseCase.saveDataLicense(item)
            }
        )
        .authorizationNavigationBar(
            title: "DataLicense.nav.title".localized,
            onBack: {
                goBack()
            }
        )
    }

    private var imageLicenseScreen: some View {
        LicenseSelectionScreen(
            selectedItem: $selectedImageLicense,
            items: setupUseCase.imageLicenses(),
            onSelectionChanged: { item in
                setupUseCase.saveImageLicense(item)
            }
        )
        .authorizationNavigationBar(
            title: "ImgLicense.nav.title".localized,
            onBack: {
                goBack()
            }
        )
    }

    private var projectNameScreen: some View {
        SetupProjectNameScreen(
            viewModel: SetupProjectNameScreenViewModel(
                useCase: setupUseCase,
                onCancelTapped: { _ in
                    presentedSheet = nil
                },
                onOkTapped: { _ in
                    presentedSheet = nil
                }
            )
        )
        .presentationDetents([.height(220)])
    }

    private var downloadAndUploadScreen: some View {
        SetupDownloadAndUploadScreen(
            viewModel: SetupDownloadAndUploadScreenViewModel(
                useCase: setupUseCase,
                onCancelTapped: { _ in
                    presentedSheet = nil
                },
                onItemTapped: { _ in
                    presentedSheet = nil
                }
            )
        )
        .presentationDetents([.height(260)])
    }

    private func handle(_ item: SetupItemViewModel) {
        switch item.type {
        case .chooseGropups, .observationEntry, .adultByDefault, .englishNames:
            break
        case .projectName:
            presentedSheet = .projectName
        case .dataLicense:
            path.append(Screen.dataLicense)
        case .imageLicense:
            path.append(Screen.imageLicense)
        case .downloadUpload:
            presentedSheet = .downloadUpload
        case .downloadAllTaxa:
            onStartDownloadTaxon(())
        case .resetAllTaxa:
            setupAlert = setupUseCase.hasDownloadedTaxa() ? .confirmTaxonReset : .taxaEmpty
        }
    }

    private func makeAlert(_ alert: SetupAlert) -> Alert {
        switch alert {
        case .confirmTaxonReset:
            return Alert(
                title: Text("Settings.lb.resetAllTaxa.yesOrNoAlert.title".localized),
                primaryButton: .destructive(Text("Common.btn.yes".localized)) {
                    setupUseCase.resetDownloadedTaxa()
                    setupAlert = .taxaReset
                },
                secondaryButton: .cancel(Text("Common.btn.no".localized))
            )
        case .taxaEmpty:
            return Alert(
                title: Text("Settings.lb.resetAllTaxa.confirmAlert.whentTaxonEmpty.title".localized),
                message: Text("Settings.lb.resetAllTaxa.confirmAlert.whentTaxonEmpty.description".localized),
                dismissButton: .default(Text("Common.btn.ok".localized))
            )
        case .taxaReset:
            return Alert(
                title: Text("Settings.lb.resetAllTaxa.confirmAlert.title".localized),
                message: Text("Settings.lb.resetAllTaxa.confirmAlert.description".localized),
                dismissButton: .default(Text("Common.btn.ok".localized))
            )
        }
    }

    private func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}
