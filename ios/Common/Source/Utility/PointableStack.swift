//
//  PointableStack.swift
//  Knowledge
//
//  Created by CSH on 28.01.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public class PointableStack<T> {

    private var stack: [T] = []

    private var stackPointer: Int = 0

    public init() { }

    public var isPointerIncreasable: Bool {
        stackPointer + 1 < stack.count
    }

    public var isPointerDecreasable: Bool {
        stackPointer > 0
    }

    public var currentItem: T? {
        guard !stack.isEmpty else { return nil }
        return stack[stackPointer]
    }

    public var previousItem: T? {
        guard isPointerDecreasable else { return nil }
        return stack[stackPointer - 1]
    }

    public var nextItem: T? {
        guard isPointerIncreasable else { return nil }
        return stack[stackPointer + 1]
    }

    /// Adds an item to the stack. If the stackPointer isn't pointing at the last index of the stack
    /// all items after the item pointed to will be removed first.
    /// - Parameter item: The item to add to the stack.
    public func append(_ item: T) {
        if isPointerIncreasable {
            stack = Array(stack.prefix(stackPointer + 1))
        }
        stack.append(item)
        stackPointer = stack.count - 1
    }

    public func pop() {
        guard !stack.isEmpty else { return }
        stack.removeLast()
        stackPointer = min(stackPointer, stack.count - 1)
    }

    public func increasePointer() {
        guard isPointerIncreasable else { return }
        stackPointer += 1
    }

    public func decreasePointer() {
        guard isPointerDecreasable else { return }
        stackPointer -= 1
    }
}
