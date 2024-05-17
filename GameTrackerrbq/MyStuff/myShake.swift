//
//  myShake.swift
//  GameTrackerrbq
//
//  Created by Brian Quick on 2024-02-03.
//
// got this from a blog
//       https://www.objc.io/blog/2019/10/01/swiftui-shake-animation/
//
//  The blog pointed to these articles
//      https://swiftui-lab.com/swiftui-animations-part1/
//          Some interesting line drawing effects

//      https://swiftui-lab.com/swiftui-animations-part2/
//          Moving text fields and rectangles around


import SwiftUI

struct Shake: GeometryEffect {
    var amount: CGFloat = 70
    var shakesPerUnit = 30
    var animatableData: CGFloat
    func effectValue(size: CGSize) -> ProjectionTransform {
        print("\(amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)))")
        return ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}

//      Sample usage

struct SkakeAText: View {
    @State var attempts: Int = 0

    var body: some View {
        VStack {
//            Spacer()
            Text("Hello World")
//                .fill(Color.pink)
//                .frame(width: 200, height: 100)
                .modifier(Shake(animatableData: CGFloat(attempts)))
                .onAppear() {
                    withAnimation(.default) {
                                        self.attempts += 1
                                    }
                }

//            Spacer()
//            Button(action: {
//                withAnimation(.default) {
//                    self.attempts += 1
//                }
//
//            }, label: { Text("Shake it") })
//            Spacer()
        }
    }
}
struct SkakeAText_Previews: PreviewProvider {
    static var previews: some View {
        SkakeAText()
    }
}



//public extension View {
//    func offset(x: CGFloat, y: CGFloat) -> some View {
//        return modifier(_OffsetEffect(offset: CGSize(width: x, height: y)))
//    }
//
//    func offset(_ offset: CGSize) -> some View {
//        return modifier(_OffsetEffect(offset: offset))
//    }
//}

struct _OffsetEffect: GeometryEffect {
    var offset: CGSize

    var animatableData: CGSize.AnimatableData {
        get { CGSize.AnimatableData(offset.width, offset.height) }
        set { offset = CGSize(width: newValue.first, height: newValue.second) }
    }

    public func effectValue(size: CGSize) -> ProjectionTransform {
        return ProjectionTransform(CGAffineTransform(translationX: offset.width, y: offset.height))
    }
}
struct SkewedOffset: GeometryEffect {
    var offset: CGFloat
    var skew: CGFloat

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(offset, skew) }
        set {
            offset = newValue.first
            skew = newValue.second
        }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        return ProjectionTransform(CGAffineTransform(a: 1, b: 0, c: skew, d: 1, tx: offset, ty: 0))
    }
}
