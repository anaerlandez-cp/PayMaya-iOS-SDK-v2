//  Copyright (c) 2020 PayMaya Philippines, Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
//  associated documentation files (the "Software"), to deal in the Software without restriction,
//  including without limitation the rights to use, copy, modify, merge, publish, distribute,
//  sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or
//  substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
//  NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
//  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation
import UIKit

private struct Constants {
    static let buttonDefaultConstraint: CGFloat = -16
    static let secureText: String = "✅ Your card details will be saved securely."
    static let captionText: String = "Your card may be charged to make sure it's valid. That amount will be automatically refunded."
    static let synTextContainerOffset: CGFloat = 8
}

protocol CardPaymentTokenViewContract: class {
    func initialSetup(data: CardPaymentTokenInitialData)
}

class CardPaymentTokenView: UIView {

    private let syn_textContainerView = UIView()
    private let syn_cardHStack = UIStackView()

    private let cardNumber: LabeledTextField
    private let cvv: CVVLabeledTextField
    private let validityDate: LabeledTextField
    private let secureLabel = UILabel()
    private let captionLabel = UILabel()

    private let imageView = UIImageView()
    private let indicatorView = UIActivityIndicatorView(style: .gray)

    private let mainStack = UIStackView()
    private let minorStack = UIStackView()
    private let textStack = UIStackView()
    private let actionButton = RoundButton(type: .system)

    private let model: CardPaymentTokenViewModel

    private var buttonConstraint: NSLayoutConstraint?
    private var synTextContainerBottomConstraint: NSLayoutConstraint?

    init(with model: CardPaymentTokenViewModel, secureLabel: UILabel = UILabel()) {
        self.model = model
        self.cardNumber = CardLabeledTextField(model: model.cardNumberModel)
        self.cvv = CVVLabeledTextField(model: model.cvvModel)
        self.validityDate = LabeledTextField(model: model.expirationDateModel)
        super.init(frame: .zero)
        model.setContract(self)
        model.setOnEditingChanged({ [weak self] in self?.onEditingChanged($0) })
        setupNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func hideActivityIndicator() {
        indicatorView.isHidden = true
    }

    func onEditingChanged(_ valid: Bool) {
        actionButton.isEnabled = valid
    }

}

extension CardPaymentTokenView: CardPaymentTokenViewContract {
    func initialSetup(data: CardPaymentTokenInitialData) {
        setupViews(with: data)
    }
}

private extension CardPaymentTokenView {
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

//    func setupViews(with data: CardPaymentTokenInitialData) {
//        addSubviews()
//        setupSelf(with: data.styling)
//        setupLogo(with: data.styling.image)
//        setupMainStack()
//        setupMinorStack()
//        setupButton(with: data.styling)
//        setupActivityIndicator()
//
//        setupSynTextContainerView()
//        setup_cardHStack()
//    }

    func setupViews(with data: CardPaymentTokenInitialData) {
        addSubviews()
        setupSelf(with: data.styling)
        setupLogo(with: data.styling.image)
        setupMainStack()
        setupMinorStack()

        setupSynTextContainerView()   // ← MOVE THIS UP

        setupButton(with: data.styling)
        setupActivityIndicator()
    }

    func addSubviews() {
        addSubview(imageView)
        addSubview(mainStack)
        addSubview(syn_cardHStack)
        mainStack.addArrangedSubview(cardNumber)
        mainStack.addArrangedSubview(minorStack)
        minorStack.addArrangedSubview(validityDate)
        minorStack.addArrangedSubview(cvv)
        addSubview(indicatorView)
    }

    func setupSelf(with styling: CardPaymentTokenViewStyle) {
        self.backgroundColor = styling.backgroundColor
    }

    func setupLogo(with image: UIImage) {
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -32),
            imageView.heightAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.height / 5),
            imageView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
    }

    func setupMainStack() {
        mainStack.axis = .vertical
        mainStack.distribution = .fillEqually
        mainStack.spacing = 16
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: UIDevice.current.isSmall ? 8 : 16),
            mainStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16)
        ])
    }

    func setupMinorStack() {
        minorStack.axis = .horizontal
        minorStack.distribution = .fillEqually
        minorStack.spacing = 16
    }

    func setup_cardHStack() {
        syn_cardHStack.translatesAutoresizingMaskIntoConstraints = false
        syn_cardHStack.backgroundColor = .clear
        syn_cardHStack.axis = .horizontal
        syn_cardHStack.distribution = .fillEqually
        syn_cardHStack.spacing = 4

        let hstackHeight = 20.0

        let cardImageView = UIImageView(image: UIImage(named: "card"))
        cardImageView.translatesAutoresizingMaskIntoConstraints = false
        cardImageView.contentMode = .scaleAspectFit
        syn_cardHStack.addArrangedSubview(cardImageView)

        let visaImageView = UIImageView(image: UIImage(named: "visa"))
        visaImageView.translatesAutoresizingMaskIntoConstraints = false
        visaImageView.contentMode = .scaleAspectFit
        syn_cardHStack.addArrangedSubview(visaImageView)

        let jcbImageView = UIImageView(image: UIImage(named: "jcb"))
        jcbImageView.translatesAutoresizingMaskIntoConstraints = false
        jcbImageView.contentMode = .scaleAspectFit
        syn_cardHStack.addArrangedSubview(jcbImageView)

        let amexImageView = UIImageView(image: UIImage(named: "amex"))
        amexImageView.translatesAutoresizingMaskIntoConstraints = false
        amexImageView.contentMode = .scaleAspectFit
        syn_cardHStack.addArrangedSubview(amexImageView)

        NSLayoutConstraint.activate([
            syn_cardHStack.heightAnchor.constraint(equalToConstant: hstackHeight),
            syn_cardHStack.widthAnchor.constraint(equalToConstant: 100),
            syn_cardHStack.topAnchor.constraint(
                equalTo: mainStack.topAnchor,
                constant: -hstackHeight/6
            ),
            syn_cardHStack.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor)
        ])

    }

    func setupSynTextContainerView() {
        addSubview(syn_textContainerView)
        syn_textContainerView.translatesAutoresizingMaskIntoConstraints = false
        syn_textContainerView.backgroundColor = UIColor.clear // You can customize this

        // Calculate width (100% minus 16 for padding)
        let widthConstraint = syn_textContainerView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -16)

        // Calculate height based on 16:9 ratio
        // height = width * (9/16)
        let heightConstraint = syn_textContainerView.heightAnchor.constraint(equalTo: syn_textContainerView.widthAnchor, multiplier: 9.0/16.0)

        // Position constraints
//        self.synTextContainerBottomConstraint = syn_textContainerView.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -Constants.synTextContainerOffset)

        self.synTextContainerBottomConstraint =
        syn_textContainerView.bottomAnchor.constraint(
            equalTo: self.safeAreaLayoutGuide.bottomAnchor,
            constant: -68
        )

        let imageView = UIImageView(image: UIImage(named: "powered_by_maya"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit

        secureLabel.text = Constants.secureText
        secureLabel.font = UIFont(name: "Montserrat", size: 14)
        secureLabel.textColor = .gray
        secureLabel.numberOfLines = 0
        secureLabel.translatesAutoresizingMaskIntoConstraints = false

        captionLabel.text = Constants.captionText
        captionLabel.font = UIFont(name: "Montserrat", size: 14)
        captionLabel.textColor = .gray
        captionLabel.lineBreakMode = .byWordWrapping
        captionLabel.numberOfLines = 0
        captionLabel.translatesAutoresizingMaskIntoConstraints = false

        syn_textContainerView.addSubview(secureLabel)
        syn_textContainerView.addSubview(captionLabel)
        syn_textContainerView.addSubview(imageView)


        NSLayoutConstraint.activate([
            syn_textContainerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            widthConstraint,
            heightConstraint,
            synTextContainerBottomConstraint!
        ])

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: syn_textContainerView.centerXAnchor),
            imageView.bottomAnchor.constraint(equalTo: syn_textContainerView.bottomAnchor, constant: 16),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            imageView.widthAnchor.constraint(equalToConstant: 100)
        ])

        NSLayoutConstraint.activate([
            secureLabel.topAnchor.constraint(equalTo: syn_textContainerView.topAnchor, constant: 16),
            secureLabel.leftAnchor.constraint(equalTo: syn_textContainerView.leftAnchor, constant: 16),
            secureLabel.rightAnchor.constraint(equalTo: syn_textContainerView.rightAnchor, constant: -16)
        ])

        NSLayoutConstraint.activate([
            captionLabel.topAnchor.constraint(equalTo: secureLabel.bottomAnchor, constant: 16),
            captionLabel.leftAnchor.constraint(equalTo: syn_textContainerView.leftAnchor, constant: 16),
            captionLabel.rightAnchor.constraint(equalTo: syn_textContainerView.rightAnchor, constant: -16)
        ])

    }

    func setupButton(with styling: CardPaymentTokenViewStyle) {
        addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.backgroundColor = styling.buttonStyling.backgroundColor
        actionButton.setTitleColor(styling.buttonStyling.textColor, for: .normal)
        actionButton.titleLabel?.font = styling.font
        actionButton.setTitle(styling.buttonStyling.title, for: .normal)

        // 🔵 ADD IT HERE
        actionButton.setContentCompressionResistancePriority(.required, for: .vertical)
        actionButton.setContentHuggingPriority(.required, for: .vertical)

        self.buttonConstraint = actionButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: Constants.buttonDefaultConstraint)
        NSLayoutConstraint.activate([
            actionButton.heightAnchor.constraint(equalToConstant: UIDevice.current.isSmall ? 44 : 50),
            actionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            actionButton.topAnchor.constraint(
                greaterThanOrEqualTo: minorStack.bottomAnchor,
                constant: UIDevice.current.isSmall ? 32 : 48
            ),
            buttonConstraint!,
            actionButton.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        actionButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        actionButton.isEnabled = false
    }

    func setupActivityIndicator() {
        indicatorView.isHidden = true
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicatorView.centerYAnchor.constraint(equalTo: centerYAnchor),
            indicatorView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    @objc func buttonAction() {
        self.endEditing(true)
        indicatorView.isHidden = false
        indicatorView.startAnimating()
        model.buttonPressed()
    }

    @objc func keyboardWillShow(_ notification: NSNotification) {
        guard let size = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {return}
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.buttonConstraint?.constant = Constants.buttonDefaultConstraint - size.height + (UIDevice.current.isSmall ? 8 : 0)
            self?.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.buttonConstraint?.constant = Constants.buttonDefaultConstraint
            self?.layoutIfNeeded()
        }
    }
}

