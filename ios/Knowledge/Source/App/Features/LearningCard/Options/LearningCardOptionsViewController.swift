//
//  LearningCardOptionsViewController.swift
//  Knowledge DE
//
//  Created by CSH on 17.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit
import Localization
import DesignSystem

/// @mockable
protocol LearningCardOptionsViewType: AnyObject {
    func setShareButton(title: String, image: UIImage, isEnabled: Bool)
    func setLearnedButton(title: String, image: UIImage, isEnabled: Bool)
    func setQbankButton(title: String, image: UIImage, isEnabled: Bool)

    func setHighlightingSwitch(title: String, subtitle: String, isOn: Bool, isEnabled: Bool)
    func setHighYieldModeSwitch(title: String, subtitle: String, isOn: Bool, isEnabled: Bool)
    func setPhysikumFokusSwitch(title: String, subtitle: String, isOn: Bool, isEnabled: Bool)
    func setLearningRadarSwitch(title: String, subtitle: String, isOn: Bool, isEnabled: Bool)
    func setModeCallout(text: NSAttributedString, isVisible: Bool)
    func setFontSize(title: String, value: Float)
    func updatePreferredContentSize()
}

final class LearningCardOptionsViewController: UIViewController, LearningCardOptionsViewType {

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        scrollView.bounces = false
        return scrollView
    }()

    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // Buttons
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0)
        return stackView
    }()

    private lazy var shareButton: LearningCardOptionsButton = {
        let button = LearningCardOptionsButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var learnedButton: LearningCardOptionsButton = {
        let button = LearningCardOptionsButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.button.addTarget(self, action: #selector(learnedButtonTapped(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var qbankButton: LearningCardOptionsButton = {
        let button = LearningCardOptionsButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.button.addTarget(self, action: #selector(qbankButtonTapped(_:)), for: .touchUpInside)
        return button
    }()

    // Divider
    private lazy var divider: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .dividerPrimary
        return view
    }()

    // Title
    private lazy var viewSettingsTitleContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var viewSettingsTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = NSAttributedString(string: L10n.LearningCardOptionsView.Modes.subheading, attributes: ThemeManager.currentTheme.learningCardOptionsSubheadingAttributes)
        return label
    }()

    // Switches
    private lazy var switchesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 12, leading: 0, bottom: 0, trailing: 0)
        return stackView
    }()

    private lazy var highlightSwitch: LearningCardOptionsSwitch = {
        let toggle = LearningCardOptionsSwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.toggle.addTarget(self, action: #selector(highlightingSwitchDidChange(_:)), for: .valueChanged)
        return toggle
    }()

    private lazy var highYieldSWitch: LearningCardOptionsSwitch = {
        let toggle = LearningCardOptionsSwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.toggle.addTarget(self, action: #selector(highYieldModeSwitchDidChange(_:)), for: .valueChanged)
        return toggle
    }()

    private lazy var physikumFokusSwitch: LearningCardOptionsSwitch = {
        let toggle = LearningCardOptionsSwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.toggle.addTarget(self, action: #selector(physikumFokusModeSwitchDidChange(_:)), for: .valueChanged)
        return toggle
    }()

    private lazy var learningRadarSwitch: LearningCardOptionsSwitch = {
        let toggle = LearningCardOptionsSwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.toggle.addTarget(self, action: #selector(learningRadarSwitchDidChange(_:)), for: .valueChanged)
        return toggle
    }()

    private lazy var calloutContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var modeCallout: CalloutView = {
        let view = CalloutView()
        view.setContentHuggingPriority(.required, for: .vertical)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var calloutDivider: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .dividerPrimary
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }()

    // Slider
    private lazy var textSizeSlider: LearningCardOptionsSlider = {
        let slider = LearningCardOptionsSlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.slider.addTarget(self, action: #selector(fontSizeSliderValueChanged(_:)), for: .valueChanged)
        return slider
    }()

    private var presenter: LearningCardOptionsPresenterType! // swiftlint:disable:this implicitly_unwrapped_optional
    private lazy var feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    private var isFeedbackGenerated = false
    private var isFontSliderTracking = false {
        didSet {
            if oldValue != isFontSliderTracking {
                let alpha: CGFloat = self.isFontSliderTracking ? 0 : 1
                self.presenter.fontSliderTrackingChanged(isTracking: self.isFontSliderTracking)
                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveLinear]) { [weak self] in
                    guard let self = self else { return }
                    self.buttonsStackView.alpha = alpha
                    self.divider.alpha = alpha
                    self.viewSettingsTitleContainer.alpha = alpha
                    self.switchesStackView.alpha = alpha
                    self.buttonsStackView.alpha = alpha
                }
            }
        }
    }

    init(presenter: LearningCardOptionsPresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePreferredContentSize()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.LearningCardOptionsView.title
        view.backgroundColor = .clear
        setNavigationBarStyle()
        setupViews()
        setupButtons()
        presenter.view = self
        updatePreferredContentSize()
        feedbackGenerator.prepare()
    }

    func updatePreferredContentSize() {
        // Popover width should fit the width of the screen up to 600.
        // UIScreen is used here instead of view.bounds.width because
        // the purpose of this is to calculate what the view bounds
        // should be in the first place
        let width = min(600, UIScreen.main.bounds.width)
        let height = scrollView.contentSize.height + view.safeAreaInsets.top + view.safeAreaInsets.bottom
        preferredContentSize = CGSize(width: width, height: height)
    }

    func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(mainStackView)
        scrollView.constrainEdges(to: view)
        mainStackView.constrainEdges(to: scrollView.contentLayoutGuide)

        let widthConstraint = mainStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        let heightConstraint = mainStackView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)

        heightConstraint.priority = UILayoutPriority(250)

        NSLayoutConstraint.activate([
            widthConstraint,
            heightConstraint
        ])

        mainStackView.addArrangedSubview(buttonsStackView)

        buttonsStackView.addArrangedSubview(shareButton)
        buttonsStackView.addArrangedSubview(learnedButton)
        buttonsStackView.addArrangedSubview(qbankButton)

        mainStackView.addArrangedSubview(divider)

        mainStackView.addArrangedSubview(viewSettingsTitleContainer)
        viewSettingsTitleContainer.addSubview(viewSettingsTitleLabel)
        mainStackView.addArrangedSubview(switchesStackView)

        calloutContainer.addSubview(modeCallout)
        calloutContainer.addSubview(calloutDivider)

        calloutDivider.pinBottom(to: calloutContainer)
        modeCallout.pin(to: calloutContainer,
                        insets: UIEdgeInsets(top: .spacing.none,
                                             left: .spacing.l,
                                             bottom: .spacing.m,
                                             right: .spacing.l))

        switchesStackView.addArrangedSubview(highlightSwitch)
        switchesStackView.addArrangedSubview(highYieldSWitch)
        switchesStackView.addArrangedSubview(physikumFokusSwitch)
        switchesStackView.addArrangedSubview(learningRadarSwitch)
        switchesStackView.addArrangedSubview(calloutContainer)

        mainStackView.addArrangedSubview(textSizeSlider)

        NSLayoutConstraint.activate([
            divider.heightAnchor.constraint(equalToConstant: 1),
            viewSettingsTitleLabel.leadingAnchor.constraint(equalTo: viewSettingsTitleContainer.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            viewSettingsTitleLabel.trailingAnchor.constraint(equalTo: viewSettingsTitleContainer.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            viewSettingsTitleLabel.topAnchor.constraint(equalTo: viewSettingsTitleContainer.safeAreaLayoutGuide.topAnchor, constant: 16),
            viewSettingsTitleLabel.bottomAnchor.constraint(equalTo: viewSettingsTitleContainer.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTapCallout))
        calloutContainer.addGestureRecognizer(recognizer)
    }

    @objc func didTapCallout() {
        presenter.didTapModeCallout()
    }

    func setNavigationBarStyle() {
        guard let standardAppearance = navigationController?.navigationBar.standardAppearance else { return }

        standardAppearance.shadowColor = .clear
        standardAppearance.backgroundColor = ThemeManager.currentTheme.popoverNavigationBarBackgroundColor

        navigationController?.navigationBar.standardAppearance = standardAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = standardAppearance
        navigationController?.navigationBar.compactAppearance = standardAppearance
    }

    func setupButtons() {
        shareButton.button.addTarget(self, action: #selector(shareButtonTapped(_:)), for: .touchUpInside)
        learnedButton.button.addTarget(self, action: #selector(learnedButtonTapped(_:)), for: .touchUpInside)
        qbankButton.button.addTarget(self, action: #selector(qbankButtonTapped(_:)), for: .touchUpInside)
    }

    func setShareButton(title: String, image: UIImage, isEnabled: Bool) {
        shareButton.set(title: title, image: image, hasChevron: false)
        shareButton.isHidden = !isEnabled
        updateButtonsStackViewVisibility()
    }

    func setLearnedButton(title: String, image: UIImage, isEnabled: Bool) {
        learnedButton.set(title: title, image: image, hasChevron: false)
        learnedButton.isHidden = !isEnabled
        updateButtonsStackViewVisibility()
    }

    func setQbankButton(title: String, image: UIImage, isEnabled: Bool) {
        qbankButton.set(title: title, image: image, hasChevron: true)
        qbankButton.isHidden = !isEnabled
        updateButtonsStackViewVisibility()
    }

    func setHighlightingSwitch(title: String, subtitle: String, isOn: Bool, isEnabled: Bool) {
        highlightSwitch.set(title: title, subtitle: subtitle, isOn: isOn)
        highlightSwitch.isHidden = !isEnabled
        updateSwitchesStackViewVisibility()
    }

    func setHighYieldModeSwitch(title: String, subtitle: String, isOn: Bool, isEnabled: Bool) {
        highYieldSWitch.set(title: title, subtitle: subtitle, isOn: isOn)
        highYieldSWitch.isHidden = !isEnabled
        updateSwitchesStackViewVisibility()
    }

    func setPhysikumFokusSwitch(title: String, subtitle: String, isOn: Bool, isEnabled: Bool) {
        physikumFokusSwitch.set(title: title, subtitle: subtitle, isOn: isOn)
        physikumFokusSwitch.isHidden = !isEnabled
        updateSwitchesStackViewVisibility()
    }

    func setLearningRadarSwitch(title: String, subtitle: String, isOn: Bool, isEnabled: Bool) {
        learningRadarSwitch.set(title: title, subtitle: subtitle, isOn: isOn)
        learningRadarSwitch.isHidden = !isEnabled
        updateSwitchesStackViewVisibility()
    }

    func setFontSize(title: String, value: Float) {
        textSizeSlider.set(title: title, minValue: 0.4, maxValue: 1.6, value: value)
    }

    func setModeCallout(text: NSAttributedString, isVisible: Bool) {
        modeCallout.viewData = .init(attributedDescription: text,
                                     calloutType: .informational)
        calloutContainer.isHidden = !isVisible
        updateSwitchesStackViewVisibility()
    }

    private func updateButtonsStackViewVisibility() {
        buttonsStackView.isHidden = shareButton.isHidden && learnedButton.isHidden && qbankButton.isHidden
        divider.isHidden = buttonsStackView.isHidden
    }

    private func updateSwitchesStackViewVisibility() {
        switchesStackView.isHidden = highlightSwitch.isHidden && highYieldSWitch.isHidden && physikumFokusSwitch.isHidden && learningRadarSwitch.isHidden && calloutContainer.isHidden
    }

    @objc func shareButtonTapped(_ sender: UIButton) {
        presenter.shareLearningCard()
    }

    @objc private func learnedButtonTapped(_ sender: UIButton) {
        presenter.toggleIsLearned()
    }

    @objc private func qbankButtonTapped(_ sender: UIButton) {
        presenter.createQuestionSession()
    }

    @objc private func highlightingSwitchDidChange(_ sender: UISwitch) {
        presenter.highlightingSwitchDidChange(sender.isOn)
    }

    @objc private func highYieldModeSwitchDidChange(_ sender: UISwitch) {
        presenter.highYieldModeSwitchDidChange(sender.isOn)
    }

    @objc private func physikumFokusModeSwitchDidChange(_ sender: UISwitch) {
        presenter.physikumFokusSwitchDidChange(sender.isOn)
    }

    @objc private func learningRadarSwitchDidChange(_ sender: UISwitch) {
        presenter.learningRadarSwitchDidChange(sender.isOn)
    }

    @objc private func fontSizeSliderValueChanged(_ sender: UISlider) {
        isFontSliderTracking = sender.isTracking
        ensureSliderSnapsInCenter(sender)
        presenter.changeFontScale(sender.value)
    }

    private func ensureSliderSnapsInCenter(_ sender: UISlider) {
        // We want the slider to snap in place in the center
        let sliderRange = sender.maximumValue - sender.minimumValue
        let centerValue = sliderRange * 0.5 + sender.minimumValue
        let snappingRange = Float(0.05 * sliderRange)

        let correctedValue: Float

        switch sender.value {
        case centerValue - snappingRange..<centerValue + snappingRange:
            correctedValue = centerValue

            // Generate a feedback when the slider is in the centre.
            generateHapticFeedback()
        default:
            correctedValue = sender.value
            isFeedbackGenerated = false
        }

        sender.value = correctedValue
    }

    private func generateHapticFeedback() {
        if !isFeedbackGenerated {
            feedbackGenerator.impactOccurred()
            isFeedbackGenerated = true
        }
    }
}
