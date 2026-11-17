import Foundation

protocol NumericConvertible {
    var nsNumber: NSNumber { get }
}

extension CGFloat: NumericConvertible {

    var nsNumber: NSNumber {
        return NSNumber(value: self)
    }

}

extension Float: NumericConvertible {

    var nsNumber: NSNumber {
        return NSNumber(value: self)
    }

}

extension Double: NumericConvertible {

    var nsNumber: NSNumber {
        return NSNumber(value: self)
    }

}

extension Int: NumericConvertible {

    var nsNumber: NSNumber {
        return NSNumber(value: self)
    }

}
