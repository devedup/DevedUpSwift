// Created by David Casserly on 21/09/2020.
// Copyright (c) 2025 DevedUp Ltd. All rights reserved.

import UIKit

open class TapticEngine {

    public static let impact: Impact = Impact()
    public static let selection: Selection = Selection()
    public static let notification: Notification = Notification()

    /// Wrapper of `UIImpactFeedbackGenerator`
    open class Impact {

        public typealias ImpactStyle = UIImpactFeedbackGenerator.FeedbackStyle
        
        private var style: ImpactStyle = .light
        private var generator: Any? = Impact.makeGenerator(.light)

        private static func makeGenerator(_ style: ImpactStyle) -> Any? {
            guard #available(iOS 10.0, *) else { return nil }
            let generator: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            return generator
        }

        private func updateGeneratorIfNeeded(_ style: ImpactStyle) {
            guard self.style != style else { return }
            generator = Impact.makeGenerator(style)
            self.style = style
        }

        public func feedback(_ style: ImpactStyle) {
            guard #available(iOS 10.0, *) else { return }
            updateGeneratorIfNeeded(style)
            guard let generator = generator as? UIImpactFeedbackGenerator else { return }
            generator.impactOccurred()
        }

        public func prepare(_ style: ImpactStyle) {
            guard #available(iOS 10.0, *) else { return }
            updateGeneratorIfNeeded(style) // This will trigger the prepare()
        }
    }

    /// Wrapper of `UISelectionFeedbackGenerator`
    open class Selection {
        private var generator: Any? = {
            guard #available(iOS 10.0, *) else { return nil }
            let generator: UISelectionFeedbackGenerator = UISelectionFeedbackGenerator()
            generator.prepare()
            return generator
        }()

        public func feedback() {
            guard #available(iOS 10.0, *) else { return }
            guard let generator = generator as? UISelectionFeedbackGenerator else { return }
            generator.selectionChanged()
        }

        public func prepare() {
            guard #available(iOS 10.0, *) else { return }
            _ = generator // This will trigger the prepare()
        }
    }

    /// Wrapper of `UINotificationFeedbackGenerator`
    open class Notification {
        
        public typealias FeedbackType = UINotificationFeedbackGenerator.FeedbackType
        
        private var generator: Any? = {
            guard #available(iOS 10.0, *) else { return nil }
            let generator: UINotificationFeedbackGenerator = UINotificationFeedbackGenerator()
            generator.prepare() // safe to call more than once
            return generator
        }()

        public func feedback(_ type: FeedbackType) {
            guard #available(iOS 10.0, *) else { return }
            guard let generator = generator as? UINotificationFeedbackGenerator else { return }
            generator.notificationOccurred(type)
        }

        public func prepare() {
            guard #available(iOS 10.0, *) else { return }
            _ = generator // This will trigger the prepare()
        }
    }
}
