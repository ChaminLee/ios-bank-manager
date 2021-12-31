//
//  BankManagerUIApp - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom academy. All rights reserved.
// 

import UIKit

protocol TimerDelegate: AnyObject {
    func setupTimeLabel(second: Int, milisecond: Int, nanoSecond: Int)
}

class ViewController: UIViewController {
    private let bankStackView = CustomStackView(axis: .vertical, spacing: 10, distribution: .fill, alignment: .fill)
    private let waitingCustomerStackView = CustomStackView(axis: .vertical, spacing: 5, distribution: .equalSpacing, alignment: .center)
    private let processingCustomerStackView = CustomStackView(axis: .vertical, spacing: 5, distribution: .equalSpacing, alignment: .center)
    private var processingTimeLabel = UILabel()
    
    private var bankTimer = BankTimer()
    private var bank: Bank?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bank = BankFactory.createBank(with: self)
        bankTimer.delegate = self
        setupUI()
        bank?.open()
    }
    
    func setupUI() {
        setupBankStackView()
        setupButtons()
        setupProcessingTimeLabel()
        setupCustomerView()
        setupInitialCustomers()
    }
    
    func setupBankStackView() {
        self.view.addSubview(bankStackView)
        bankStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bankStackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            bankStackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            bankStackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            bankStackView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    func setupButtons() {
        let buttonStackView = CustomStackView(axis: .horizontal, spacing: .zero, distribution: .fillEqually, alignment: .center)
        let addCustomerButton = CustomButton(title: "고객 10명 추가", textColor: .blue)
        let resetButton = CustomButton(title: "초기화", textColor: .red)
        
        addCustomerButton.addTarget(self, action: #selector(setupTenCustomerQueue), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(reset), for: .touchUpInside)
        
        [addCustomerButton, resetButton].forEach {
            buttonStackView.addArrangedSubview($0)
        }
        
        bankStackView.addArrangedSubview(buttonStackView)
    }
    
    @objc func setupTenCustomerQueue() {
        let amount = 10
        bank?.setupCustomerQueue(with: amount)
        
        guard let customers = bank?.returnAllCustomers() else {
            return
        }
        
        let count = customers.count
        
        customers[count-amount..<count].forEach { customer in
            waitingCustomerStackView.addArrangedSubview(CustomerLabel(order: customer.turn, type: customer.task))
        }
    }
    
    @objc func reset() {
        bank?.resetCustomerQueue()
        waitingCustomerStackView.arrangedSubviews.forEach { view in
            view.removeFromSuperview()
        }
        processingCustomerStackView.arrangedSubviews.forEach { view in
            view.removeFromSuperview()
        }
        
        bankTimer.stop()
    }
    
    func setupProcessingTimeLabel() {
        processingTimeLabel.text = "업무시간 - 00:00:000"
        processingTimeLabel.textAlignment = .center
        bankStackView.addArrangedSubview(processingTimeLabel)
    }
    
    func setupInitialCustomers() {
        guard let customers = bank?.returnAllCustomers() else {
            return
        }
        
        customers.forEach { customer in
            let waitingCustomerLabel = CustomerLabel(order: customer.turn, type: customer.task)
            waitingCustomerStackView.addArrangedSubview(waitingCustomerLabel)
        }
    }
    
    func setupCustomerView() {
        let waitingAndProcessingStackView = CustomStackView(axis: .horizontal, spacing: 0, distribution: .fillEqually, alignment: .fill)
        [waitingCustomerStackView, processingCustomerStackView].forEach { stackView in
            let customerStackView = CustomStackView(axis: .vertical, spacing: 10, distribution: .equalSpacing, alignment: .fill)
            
            let waitingLabel = stackView == waitingCustomerStackView ? StateLabel(text: "대기중") : StateLabel(text: "업무중")
            
            let waitingCustomerScrollView = UIScrollView()
            let waitingCustomerContentView = UIView()
            
            waitingCustomerScrollView.showsVerticalScrollIndicator = false
            
            waitingAndProcessingStackView.addArrangedSubview(customerStackView)
            customerStackView.addArrangedSubview(waitingLabel)
            customerStackView.addArrangedSubview(waitingCustomerScrollView)
            
            waitingCustomerScrollView.addSubview(waitingCustomerContentView)
            waitingCustomerContentView.addSubview(stackView)
            
            [customerStackView, waitingCustomerScrollView, waitingCustomerContentView, stackView].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
            }
            
            NSLayoutConstraint.activate([
                waitingCustomerScrollView.topAnchor.constraint(equalTo: waitingLabel.bottomAnchor, constant: 15),
                waitingCustomerScrollView.leadingAnchor.constraint(equalTo: customerStackView.leadingAnchor),
                waitingCustomerScrollView.trailingAnchor.constraint(equalTo: customerStackView.trailingAnchor),
                waitingCustomerScrollView.bottomAnchor.constraint(equalTo: customerStackView.bottomAnchor),
                
                waitingCustomerContentView.topAnchor.constraint(equalTo: waitingCustomerScrollView.topAnchor),
                waitingCustomerContentView.leadingAnchor.constraint(equalTo: waitingCustomerScrollView.leadingAnchor),
                waitingCustomerContentView.trailingAnchor.constraint(equalTo: waitingCustomerScrollView.trailingAnchor),
                waitingCustomerContentView.bottomAnchor.constraint(equalTo: waitingCustomerScrollView.bottomAnchor),
                waitingCustomerContentView.widthAnchor.constraint(equalTo: waitingCustomerScrollView.widthAnchor),
                
                stackView.topAnchor.constraint(equalTo: waitingCustomerContentView.topAnchor),
                stackView.leadingAnchor.constraint(equalTo: waitingCustomerContentView.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: waitingCustomerContentView.trailingAnchor),
                stackView.bottomAnchor.constraint(equalTo: waitingCustomerContentView.bottomAnchor)
            ])
        }
        
        bankStackView.addArrangedSubview(waitingAndProcessingStackView)
        
    }
}

extension ViewController: TimerDelegate {
    func setupTimeLabel(second: Int, milisecond: Int, nanoSecond: Int) {
        let formattedSecond = second < 10 ? "0\(second)" : "\(second)"
        let formattedMilisecond = milisecond == 0 ? "00" : "\(milisecond)"
        let formattedNanoSecond = nanoSecond == 0 ? "000" : "\(nanoSecond)"
        processingTimeLabel.text = "업무시간 - \(formattedSecond):\(formattedMilisecond):\(formattedNanoSecond)"
    }
}

extension ViewController: BankClerkDelegate {
    func moveToProcessingState(of customer: Customer) {
        DispatchQueue.main.async {
            for label in self.waitingCustomerStackView.arrangedSubviews {
                guard let waitingCustomerLabel = label as? CustomerLabel else {
                    return
                }
                guard let waitingCustomer = waitingCustomerLabel.text?.components(separatedBy: " - ") else {
                    return
                }
                
                let processingCustomer = [String(customer.turn), customer.task.description]
                if waitingCustomer == processingCustomer {
                    label.removeFromSuperview()
                    self.processingCustomerStackView.addArrangedSubview(label)
                    
                }
            }
        }
    }
    
    func moveToCompletionState(of customer: Customer) {
        
    }
}
