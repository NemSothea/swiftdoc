import Foundation

// 1. Practise Coding Challenge
// - Reverse Linked List in Swift
// - LRU Cache Implementation
//
// 2. iOS Technical
// a mix of Swift language fundamentals + UIKit/SwiftUI + concurrency + memory management.


//1. Practice Coding Challenges

class ListNode<T> {
    var value : T
    var next : ListNode?
    
    init(_ value : T , next: ListNode? = nil) {
        self.value = value
        self.next = next
    }
}
// Iterative approach (Most efficient: O(n) time, O(1) space)

func reverseLinkedListIterative<T>(_ head : ListNode<T>?) -> ListNode<T>? {
    var prev: ListNode<T>? = nil
    var current = head
    
    
    while current != nil {
        let next = current?.next
        current?.next = prev
        current = next
    }
    
    
    
    return prev
    
}
