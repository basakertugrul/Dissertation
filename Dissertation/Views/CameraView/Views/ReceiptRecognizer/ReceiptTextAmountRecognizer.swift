import Foundation

extension ReceiptDataExtractor {
    public func extractAmount() -> Double? {
        extractAmountFromTotalLine(of: lines) ??
        extractAmountFromBottomLines(of: lines) ??
        extractLargestNonSubtotalAmount(of: lines, text)
    }

    func extractAmountFromTotalLine(of lines: [String]) -> Double? {
        lines
            .first { isTotalLine($0) }
            .flatMap { extractAmountFromLine($0, preferLast: true) }
    }

    func extractAmountFromBottomLines(of lines: [String]) -> Double? {
        let bottomLines = Array(lines.reversed().prefix(5))

        return bottomLines.compactMap { line in
            guard isValidTotalCandidate(line) else { return .none }
            return extractAmountFromLine(line)
        }
        .first { $0 >= 50.0 }
    }

    func extractLargestNonSubtotalAmount(of lines: [String], _ text: String) -> Double? {
        let subtotalAmounts = Set(extractSubtotalAmounts(from: lines))
        let allAmounts = extractAllAmounts(text: text)
            .filter { $0 >= 50.0 && !subtotalAmounts.contains($0) }
        
        return allAmounts.max()
    }
    
    func isTotalLine(_ line: String) -> Bool {
        let lowerLine = line.lowercased()
        return (lowerLine.hasPrefix("total:") || lowerLine.hasPrefix("total ")) &&
               !lowerLine.contains("subtotal")
    }
    
    func isValidTotalCandidate(_ line: String) -> Bool {
        let lowerLine = line.lowercased()
        let excludedTerms = ["subtotal", "tax", "thank", "visit", "phone", "address", "www", "appropriate"]
        
        return !excludedTerms.contains { lowerLine.contains($0) } && !line.isEmpty
    }
    
    func extractSubtotalAmounts(from lines: [String]) -> [Double] {
        lines
            .filter { $0.lowercased().contains("subtotal") }
            .compactMap { extractAmountFromLine($0) }
    }

    func extractAllAmounts(text: String) -> [Double] {
        let amountPattern = "([\\d,]+\\.\\d{2})"
        guard let regex = try? NSRegularExpression(pattern: amountPattern) else { return [] }
        
        let range = NSRange(location: 0, length: text.utf16.count)
        let matches = regex.matches(in: text, options: [], range: range)
        
        return matches.compactMap { match in
            Range(match.range(at: 1), in: text)
                .map { String(text[$0]).replacingOccurrences(of: ",", with: "") }
                .flatMap { Double($0) }
        }
    }

    func extractAmountFromLine(_ line: String, preferLast: Bool = false) -> Double? {
        let amountPattern = "([\\d,]+\\.\\d{2})"
        guard let regex = try? NSRegularExpression(pattern: amountPattern) else { return .none }
        
        let range = NSRange(location: 0, length: line.utf16.count)
        let matches = regex.matches(in: line, options: [], range: range)
        
        let targetMatch = preferLast ? matches.last : matches.first
        
        return targetMatch
            .flatMap { Range($0.range(at: 1), in: line) }
            .map { String(line[$0]).replacingOccurrences(of: ",", with: "") }
            .flatMap { Double($0) }
    }
}

// MARK: - Date Formatter Provider

public final class DateFormatterProvider {
    static let shared = DateFormatterProvider()

    lazy var formatters: [DateFormatter] = {
        let formats = [
            "MMMM d, yyyy", "MMM d, yyyy", "MM/dd/yyyy", "dd/MM/yyyy", "yyyy/MM/dd",
            "MM-dd-yyyy", "dd-MM-yyyy", "yyyy-MM-dd", "MM.dd.yyyy", "dd.MM.yyyy",
            "M/d/yyyy", "d/M/yyyy", "MM/dd/yy", "dd/MM/yy", "M/d/yy", "d/M/yy"
        ]
        return formats.map { format in
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.locale = .current
            return formatter
        }
    }()

    private init() {}
}
