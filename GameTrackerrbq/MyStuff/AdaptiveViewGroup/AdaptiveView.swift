//

import SwiftUI

// MARK: Size class

// Run this on a plus size device in landscape or on an iPad to see the regular
// size class.

/*
struct AdaptiveView<Content: View>: View {
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  var content: Content

  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  var body: some View {
    if horizontalSizeClass == .regular {
      HStack {
        content
      }
    } else {
      VStack {
        content
      }
    }
  }
}
*/

// MARK: Dynamic Type

// Change the system dynamic type to switch between layouts.

/*
struct AdaptiveView<Content: View>: View {
  @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory
  var content: Content

  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  var body: some View {
    if sizeCategory.isAccessibilityCategory {
      VStack {
        content
      }
    } else {
      HStack {
        content
      }
    }
  }
}
*/

// https://www.fivestars.blog/articles/adaptive-swiftui-views/

// MARK: Custom threshold

// didn't know what to call the hide parameters so went for wide and narrow

struct AdaptiveView<Content: View>: View {
    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory

    @State private var availableWidth: CGFloat = 0
    var threshold: CGFloat
    var hideOnNarrow: Bool
    var hideOnWide: Bool
    var content: Content

    public init(threshold: CGFloat = 690, hideOnNarrow: Bool = false, hideOnWide: Bool = false, @ViewBuilder content: () -> Content) {
        self.threshold = threshold
        self.hideOnNarrow = hideOnNarrow
        self.hideOnWide = hideOnWide
        self.content = content()
    }

    var body: some View {
        ZStack {
            Color.clear
                .frame(height: 1)
                .readSize { size in
                    availableWidth = size.width
//                    print("AdaptiveView.availableWidth: \(availableWidth) -- \(threshold)")
                }
            // using the if to hide since this is about saving space
            // if the .hidden is used, the space is still there
            if availableWidth > threshold {
                if !hideOnWide {
                HStack {
                    content
                }
                }
            } else {
                if !hideOnNarrow {
                VStack {
                    content
                }

                }
            }
        }
    }
}
