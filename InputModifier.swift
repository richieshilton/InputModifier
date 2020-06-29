//
//  Copyright 2019 Richie Shilton
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import SwiftUI
import Combine

struct InputModifier: ViewModifier {
    
    @State private var notification: KeyboardNotification?
    private var notificationPublisher: AnyPublisher<KeyboardNotification?, Never>
    
    init() {
        notificationPublisher = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .merge(with: NotificationCenter.default
                    .publisher(for: UIResponder.keyboardWillChangeFrameNotification))
            .merge(with: NotificationCenter.default
                    .publisher(for: UIResponder.keyboardWillHideNotification))
            .map { KeyboardNotification(notification: $0) }
            .eraseToAnyPublisher()
    }

    func body(content: Content) -> some View {
        content
            .padding(.bottom, notification?.height)
            .edgesIgnoringSafeArea(.bottom)
            .animation(notification?.animation)
            .onReceive(notificationPublisher) { self.notification = $0 }
    }
}

private struct KeyboardNotification {
    
    let animation: Animation
    let height: CGFloat
    
    init?(notification: Notification) {
        guard
            [UIWindow.keyboardWillShowNotification, UIWindow.keyboardWillHideNotification, UIWindow.keyboardWillChangeFrameNotification].contains(notification.name),
            let userInfo = notification.userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let curveRawValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
            let curve = UIView.AnimationCurve(rawValue: curveRawValue) else {
                return nil
        }
        
        let animation: Animation = {
            switch curve {
            case .easeIn:       return .easeIn(duration: duration)
            case .easeOut:      return .easeOut(duration: duration)
            case .easeInOut:    return .easeInOut(duration: duration)
            case .linear:       return .linear(duration: duration)
            default:            return .linear(duration: duration)
            }
        }()
        
        let height: CGFloat = {
            switch notification.name {
                case UIWindow.keyboardWillShowNotification: return endFrame.height
                default: return 0
            }
        }()
        
        self.animation = animation
        self.height = height
    }
}

extension View {
    
    func keyboardPadding() -> some View {
        ModifiedContent(content: self, modifier: InputModifier())
    }
}
