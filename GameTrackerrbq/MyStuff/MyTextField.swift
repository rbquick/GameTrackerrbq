//
//  MyTextField.swift
//  icloudIOS
//
//  Created by Brian Quick on 2021-09-02.
//
// 2021-11-26 added numberPad if numeric
import SwiftUI

enum myTextType: String {
    case String
    case Int
    case Double
    case CGFloat
    case Display
}
struct myTextField: View {
    @Binding var value: String
    var title: String
    var subtitle: String?
    var texttype: myTextType
    let ints = "1234567890"
    let doubles = "1234567890."

    var body: some View {
        return GeometryReader { geometry in
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .frame(width: geometry.size.width * 0.33)
                    if let subtitle = subtitle, subtitle.isEmpty == false {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(Color.gray)
                    }
                }
                switch texttype {
                case .Display:
                    Text("\(value)")
                default:

                    Spacer()

                    TextField(title, text: $value)
                    // FIXME: this will set the keyboard type on ios but not on macos
#if os(iOS)
                        .keyboardType(texttype == myTextType.Int || texttype == myTextType.Double ? .numberPad : .default)
#endif
                        .border(Color.gray)
                        .onChange(of: value, perform: {
                            var txt = ""
                            switch texttype {
                            case .Double, .CGFloat:
                                txt = $0.filter(doubles.contains)
                            case .Int:
                                txt = $0.filter(ints.contains)
                            default:
                                txt = $0
                            }
                            if $0 != txt {
                                value = txt
                            }
                        })
                }
            }
        }
    }
}

// Previews OK 2021-11-03 08:18
struct myTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            myTextField(value: .constant("1"), title: "title", subtitle: "subTitle", texttype: .Int)
                .frame(width: 300)
        }
    }
}

