import Foundation

// OKLCH through linear sRGB/OKLab. Keep coefficients, rounding and iteration
// counts are documented in the API business guide. Web never runs this derivation.
nonisolated enum StoreThemeColor {

    private struct Oklch {

        let lightness: Double
        let chroma: Double
        let hue: Double

    }

    private static func clamp(_ value: Double) -> Double { max(0, min(1, value)) }

    private static func linear(_ value: Double) -> Double {
        value <= 0.04045 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
    }

    private static func gamma(_ value: Double) -> Double {
        value <= 0.0031308 ? 12.92 * value : 1.055 * pow(value, 1 / 2.4) - 0.055
    }

    private static func channels(_ hex: String) -> [Double] {

        let value = UInt32(hex.dropFirst(), radix: 16) ?? 0
        return [Double((value >> 16) & 255), Double((value >> 8) & 255), Double(value & 255)]
            .map { linear($0 / 255) }

    }

    private static func oklch(_ hex: String) -> Oklch {

        let rgb = channels(hex)
        let red = rgb[0], green = rgb[1], blue = rgb[2]
        let l = cbrt(0.4122214708 * red + 0.5363325363 * green + 0.0514459929 * blue)
        let m = cbrt(0.2119034982 * red + 0.6806995451 * green + 0.1073969566 * blue)
        let s = cbrt(0.0883024619 * red + 0.2817188376 * green + 0.6299787005 * blue)
        let a = 1.9779984951 * l - 2.428592205 * m + 0.4505937099 * s
        let b = 0.0259040371 * l + 0.7827717662 * m - 0.808675766 * s
        return Oklch(lightness: 0.2104542553 * l + 0.793617785 * m - 0.0040720468 * s,
                     chroma: hypot(a, b),
                     hue: atan2(b, a))

    }

    private static func linearChannels(_ color: Oklch) -> [Double] {

        let a = color.chroma * cos(color.hue)
        let b = color.chroma * sin(color.hue)
        let l = pow(color.lightness + 0.3963377774 * a + 0.2158037573 * b, 3)
        let m = pow(color.lightness - 0.1055613458 * a - 0.0638541728 * b, 3)
        let s = pow(color.lightness - 0.0894841775 * a - 1.291485548 * b, 3)
        return [4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
                -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
                -0.0041960863 * l - 0.7034186147 * m + 1.707614701 * s]

    }

    private static func hex(_ color: Oklch) -> String {

        let bounded = Oklch(lightness: clamp(color.lightness), chroma: color.chroma, hue: color.hue)
        var low = 0.0
        var high = bounded.chroma
        var rgb = linearChannels(bounded)

        if rgb.contains(where: { $0 < -0.0000001 || $0 > 1.0000001 }) {

            for _ in 0..<12 {

                let chroma = (low + high) / 2
                rgb = linearChannels(Oklch(lightness: bounded.lightness, chroma: chroma, hue: bounded.hue))
                if rgb.allSatisfy({ $0 >= -0.0000001 && $0 <= 1.0000001 }) {
                    low = chroma
                } else {
                    high = chroma
                }

            }

            rgb = linearChannels(Oklch(lightness: bounded.lightness, chroma: low, hue: bounded.hue))

        }

        return "#" + rgb.map { String(format: "%02X", Int((clamp(gamma(clamp($0))) * 255).rounded())) }.joined()

    }

    static func lightness(_ hex: String) -> Double { oklch(hex).lightness }

    static func tone(_ color: String, lightness: Double, chromaScale: Double = 1) -> String {

        let source = oklch(color)
        return hex(Oklch(lightness: lightness, chroma: source.chroma * chromaScale, hue: source.hue))

    }

    static func mix(_ first: String, _ second: String, secondWeight: Double) -> String {

        let one = oklch(first)
        let two = oklch(second)
        let a = one.chroma * cos(one.hue) * (1 - secondWeight) + two.chroma * cos(two.hue) * secondWeight
        let b = one.chroma * sin(one.hue) * (1 - secondWeight) + two.chroma * sin(two.hue) * secondWeight
        return hex(Oklch(lightness: one.lightness * (1 - secondWeight) + two.lightness * secondWeight,
                         chroma: hypot(a, b),
                         hue: atan2(b, a)))

    }

    static func luminance(_ hex: String) -> Double {

        let rgb = channels(hex)
        return 0.2126 * rgb[0] + 0.7152 * rgb[1] + 0.0722 * rgb[2]

    }

    static func contrast(_ first: String, _ second: String) -> Double {

        let one = luminance(first)
        let two = luminance(second)
        return (max(one, two) + 0.05) / (min(one, two) + 0.05)

    }

    static func contrasting(_ base: String, backgrounds: [String], minimum: Double) -> String {

        func score(_ candidate: String) -> Double {
            backgrounds.map { contrast(candidate, $0) }.min() ?? 0
        }

        if score(base) >= minimum { return base.uppercased() }
        let source = oklch(base)
        var best = base.uppercased()
        var bestScore = score(best)
        var nearest = Double.infinity

        for step in 0...200 {

            let lightness = Double(step) / 200
            let candidate = tone(base, lightness: lightness)
            let candidateScore = score(candidate)
            let distance = abs(lightness - source.lightness)
            if candidateScore >= minimum && distance < nearest {

                best = candidate
                nearest = distance

            } else if nearest == .infinity && candidateScore > bestScore {

                best = candidate
                bestScore = candidateScore

            }

        }

        return best

    }

}
