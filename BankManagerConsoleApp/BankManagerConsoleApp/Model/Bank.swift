//
//  Bank.swift
//  BankManagerConsoleApp
//
//  Created by Siwon Kim on 2021/12/23.
//

import Foundation

protocol BankDelegate: AnyObject {
    func printClosingMessage(customers: Int, processingTime: Double)
}

protocol BankTransactionable: AnyObject {
    func dequeue() -> Customer?
    func open()
    func close(totalCustomers: Int, totalProcessingTime: Double)
}

class Bank: BankTransactionable {
    private let customerQueue: Queue<Customer> = Queue<Customer>()
    private var bankClerk: BankClerk
    private weak var delegate: BankDelegate?
    
    init(bankClerk: BankClerk, delegatee: BankDelegate) {
        self.bankClerk = bankClerk
        self.bankClerk.setBank(bank: self)
        self.delegate = delegatee
        setupCustomerQueue()
    }
    
    private func setupCustomerQueue() {
        let randomCustomerCount: Int = 10 //Int.random(in: 10...30)
        
        (1...randomCustomerCount).forEach { number in
            customerQueue.enqueue(value: Customer(turn: number))
        }
    }
    
    func dequeue() -> Customer? {
        return customerQueue.dequeue()
    }
    
    func open() {
        let group = DispatchGroup()
        let depositQueue = DispatchQueue(label: "deposit", attributes: .concurrent)
        let loanQueue = DispatchQueue(label: "loan")
        let semaphore = DispatchSemaphore(value: 2)
        
        while !customerQueue.isEmpty {
            switch customerQueue.peek()?.task {
            case .deposit:
                depositQueue.async(group: group) {
                    semaphore.wait()
                    self.bankClerk.work()
                    semaphore.signal()
                }
            case .loan:
                loanQueue.async(group: group) {
                    self.bankClerk.work()
                }
                
            default:
                return
            }
        }
        
        group.wait()
    }
    
    func close(totalCustomers: Int, totalProcessingTime: Double) {
        delegate?.printClosingMessage(customers: totalCustomers, processingTime: totalProcessingTime)
    }
}
