import Foundation

extension ReceiptDataExtractor {
   public func extractDate(from lines: [String], _ text: String) -> Date? {
        extractDateFromLabeledLine(of: lines) ??
        extractDateFromMonthNames(text: text) ??
        extractDateFromNumericPatterns(text: text)
    }

    public func extractDateFromLabeledLine(of lines: [String]) -> Date? {
        lines
            .first { $0.lowercased().hasPrefix("date:") }
            .flatMap { line in
                let dateText = String(line.dropFirst(5)).trimmingCharacters(in: .whitespacesAndNewlines)
                return parseDate(from: dateText)
            }
    }

    public func extractDateFromMonthNames(text: String) -> Date? {
        let monthPattern = """
                (January|February|March|April|May|June|July|August|September|October|November|December|
                Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\\s+\\d{1,2},?\\s+\\d{4}
                """
        return extractDateUsingRegex(pattern: monthPattern, options: .caseInsensitive, text: text)
    }

    public func extractDateFromNumericPatterns(text: String) -> Date? {
        let numericPattern = "\\d{1,2}[\\/\\-\\.]\\d{1,2}[\\/\\-\\.]\\d{2,4}"
        return extractDateUsingRegex(pattern: numericPattern, text: text)
    }

    public func extractDateUsingRegex(
        pattern: String,
        options: NSRegularExpression.Options = [],
        text: String
    ) -> Date? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return .none
        }

        let range = NSRange(location: 0, length: text.utf16.count)
        let matches = regex.matches(in: text, options: [], range: range)

        return matches.compactMap { match in
            Range(match.range, in: text)
                .map { String(text[$0]) }
                .flatMap(parseDate)
        }.first
    }

    public func parseDate(from dateString: String) -> Date? {
        let cleanString = dateString.trimmingCharacters(in: .whitespacesAndNewlines)

        return DateFormatterProvider.shared.formatters
            .compactMap { $0.date(from: cleanString) }
            .first { isValidReceiptDate($0) }
    }

    public func isValidReceiptDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let year2000 = calendar.date(from: DateComponents(year: 2000, month: 1, day: 1))!
        let futureLimit = calendar.date(byAdding: .year, value: 5, to: Date())!
        return date >= year2000 && date <= futureLimit
    }
}
