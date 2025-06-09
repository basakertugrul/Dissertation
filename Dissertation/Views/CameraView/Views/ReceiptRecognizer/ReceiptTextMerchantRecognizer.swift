import Foundation

extension ReceiptDataExtractor {
   public func extractMerchantName(from lines: [String]) -> String? {
        let businessNameCandidates = lines.prefix(3)
    
        return businessNameCandidates.first { line in
            isValidBusinessName(line)
        } ?? lines.first { line in
            isReasonableLengthBusinessName(line)
        }
    }

    func isValidBusinessName(_ line: String) -> Bool {
        guard isReasonableLengthBusinessName(line) else { return false }

        let excludedTerms = ["receipt", "invoice", "phone", "address", "date"]
        let lowerLine = line.lowercased()

        return !excludedTerms.contains { lowerLine.contains($0) }
    }

    func isReasonableLengthBusinessName(_ line: String) -> Bool {
        (3...50).contains(line.count)
    }
}
