import Foundation

extension ReceiptDataExtractor {
    /// Extracts the total amount from receipt text lines
    func extractAmount(from lines: [String]) -> Double? {
        var totalCandidates: [(amount: Double, confidence: Int, line: String)] = []
        
        for (lineIndex, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmedLine.isEmpty || shouldSkipLine(trimmedLine) { continue }
            
            /// Look for lines containing "TOTAL"
            if trimmedLine.lowercased().contains("total") {
                
                /// Pattern 1: Total with amount on same line
                if let amount = extractAmountFromTotalLine(trimmedLine) {
                    let confidence = calculateTotalConfidence(for: trimmedLine, amount: amount)
                    totalCandidates.append((amount: amount, confidence: confidence, line: trimmedLine))
                }
                
                /// Pattern 2: Standalone "TOTAL" - check adjacent lines
                else if isStandaloneTotalLine(trimmedLine) {
                    
                    /// Check next line for amount
                    if lineIndex + 1 < lines.count {
                        let nextLine = lines[lineIndex + 1].trimmingCharacters(in: .whitespacesAndNewlines)
                        if let amount = extractReasonableAmount(from: nextLine) {
                            let confidence = calculateTotalConfidence(for: "\(trimmedLine) → \(nextLine)", amount: amount) + 20
                            totalCandidates.append((amount: amount, confidence: confidence, line: "\(trimmedLine) → \(nextLine)"))
                        }
                    }
                    
                    /// Check previous line for amount
                    if lineIndex > 0 {
                        let previousLine = lines[lineIndex - 1].trimmingCharacters(in: .whitespacesAndNewlines)
                        if let amount = extractReasonableAmount(from: previousLine) {
                            let confidence = calculateTotalConfidence(for: "\(previousLine) → \(trimmedLine)", amount: amount) + 15
                            totalCandidates.append((amount: amount, confidence: confidence, line: "\(previousLine) → \(trimmedLine)"))
                        }
                    }
                }
            }
        }
        
        /// Return best total candidate or fallback
        if !totalCandidates.isEmpty {
            let sortedCandidates = totalCandidates.sorted { $0.confidence > $1.confidence }
            return sortedCandidates.first?.amount
        }
        
        /// Fallback - find largest reasonable standalone amount
        return findFallbackAmount(from: lines)
    }
    
    /// Determines if a line should be skipped during processing
    private func shouldSkipLine(_ line: String) -> Bool {
        let skipPatterns = [
            #"(?i)(cash\s*tend|debit\s*tend|credit\s*tend|visa\s*tend|mcard\s*tend)"#,
            #"(?i)(shopping\s*card|gift\s*card|payment\s*service)"#,
            #"(?i)(change\s*due|cash\s*back|refund)"#,
            #"(?i)(account|approval|ref\s*#|trans\s*id|network\s*id|terminal)"#,
            #"(?i)(beg\s*bal|end\s*bal|tran\s*amt)"#,
            #"(?i)(manager|phone|address|store|items\s*sold)"#,
            #"(?i)(thank\s*you|feedback|survey|save\s*money)"#,
            #"\d{2}[/-]\d{2}[/-]\d{2,4}"#,
            #"\d{10,}"#,
            #"(?i)(subtotal|sub\s*total|tax\s*\d+|vat)"#
        ]
        
        for pattern in skipPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let range = NSRange(location: 0, length: line.utf16.count)
                if regex.firstMatch(in: line, options: [], range: range) != nil {
                    return true
                }
            }
        }
        return false
    }
    
    /// Checks if line contains only "TOTAL" keyword
    private func isStandaloneTotalLine(_ line: String) -> Bool {
        let cleanLine = line.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return cleanLine == "total" ||
               cleanLine == "grand total" ||
               cleanLine == "final total" ||
               cleanLine == "totai." ||
               cleanLine == "total:"
    }
    
    /// Extracts amount from a line containing "TOTAL"
    private func extractAmountFromTotalLine(_ line: String) -> Double? {
        let totalPatterns = [
            #"(?i)total\s*:?\s*\$?([0-9]+\.[0-9]{2})"#,
            #"(?i)total\s*:?\s*([0-9]+\.[0-9]{2})"#,
            #"\$?([0-9]+\.[0-9]{2})\s*(?i)total"#,
            #"([0-9]+\.[0-9]{2})\s*(?i)total"#
        ]
        
        for pattern in totalPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let range = NSRange(location: 0, length: line.utf16.count)
                if let match = regex.firstMatch(in: line, options: [], range: range) {
                    let captureRange = match.range(at: 1)
                    if let swiftRange = Range(captureRange, in: line) {
                        let amountString = String(line[swiftRange])
                        if let amount = Double(amountString) {
                            if amount >= 0.01 && amount <= 10000.00 {
                                return amount
                            }
                        }
                    }
                }
            }
        }
        return nil
    }
    
    /// Extracts reasonable decimal amounts from standalone lines
    private func extractReasonableAmount(from line: String) -> Double? {
        let amountPatterns = [
            #"^\$?([0-9]{1,4}\.[0-9]{2})$"#,
            #"^([0-9]{1,4}\.[0-9]{2})\s*$"#
        ]
        
        for pattern in amountPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let range = NSRange(location: 0, length: line.utf16.count)
                if let match = regex.firstMatch(in: line, options: [], range: range) {
                    let captureRange = match.range(at: 1)
                    if let swiftRange = Range(captureRange, in: line) {
                        let amountString = String(line[swiftRange])
                        if let amount = Double(amountString) {
                            if amount >= 0.01 && amount <= 2000.00 {
                                return amount
                            }
                        }
                    }
                }
            }
        }
        return nil
    }
    
    /// Calculates confidence score for total amount candidates
    private func calculateTotalConfidence(for line: String, amount: Double) -> Int {
        var confidence = 0
        let lowerLine = line.lowercased()
        
        if lowerLine.contains("grand total") || lowerLine.contains("final total") {
            confidence += 100
        } else if lowerLine.contains("total") {
            confidence += 50
        }
        
        if amount >= 1.00 && amount <= 500.00 {
            confidence += 30
        } else if amount >= 0.50 && amount <= 1000.00 {
            confidence += 20
        }
        
        if String(format: "%.2f", amount).contains(".") {
            confidence += 10
        }
        
        if amount < 0.10 || amount > 1500.00 {
            confidence -= 50
        }
        
        return confidence
    }
    
    /// Finds largest reasonable amount as fallback when no total found
    private func findFallbackAmount(from lines: [String]) -> Double? {
        var candidates: [Double] = []
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if shouldSkipLine(trimmedLine) { continue }
            
            if let amount = extractReasonableAmount(from: trimmedLine) {
                candidates.append(amount)
            }
        }
        
        return candidates.filter { $0 >= 1.00 && $0 <= 1000.00 }.max()
    }
}
