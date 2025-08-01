import Foundation

extension ReceiptDataExtractor {
    // MARK: - Amount Extraction
    func extractAmount(from lines: [String]) -> Double {
            var totalCandidates: [(amount: Double, confidence: Int, line: String)] = []
            
            for (lineIndex, line) in lines.enumerated() {
                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if trimmedLine.isEmpty { continue }
                
                // Look for "BALANCE DUE" - this is the final amount on Sainsbury's receipts
                if trimmedLine.lowercased().contains("balance due") {
                    // Check next line for amount
                    if lineIndex + 1 < lines.count {
                        let nextLine = lines[lineIndex + 1].trimmingCharacters(in: .whitespacesAndNewlines)
                        if let amount = extractCurrencyAmount(from: nextLine) {
                            totalCandidates.append((amount: amount, confidence: 150, line: "BALANCE DUE -> \(nextLine)"))
                        }
                    }
                    continue
                }
                
                // Look for lines containing "TOTAL"
                if trimmedLine.lowercased().contains("total") && !trimmedLine.lowercased().contains("subtotal") {
                    
                    // Try to extract amount from same line
                    if let amount = extractAmountFromTotalLine(trimmedLine) {
                        let confidence = calculateTotalConfidence(for: trimmedLine, amount: amount)
                        totalCandidates.append((amount: amount, confidence: confidence, line: trimmedLine))
                    }
                    
                    // Check adjacent lines for standalone totals
                    if lineIndex + 1 < lines.count {
                        let nextLine = lines[lineIndex + 1].trimmingCharacters(in: .whitespacesAndNewlines)
                        if let amount = extractCurrencyAmount(from: nextLine) {
                            let confidence = calculateTotalConfidence(for: "\(trimmedLine) -> \(nextLine)", amount: amount) + 30
                            totalCandidates.append((amount: amount, confidence: confidence, line: "\(trimmedLine) -> \(nextLine)"))
                        }
                    }
                }
            }
            
            // Return best total candidate
            if !totalCandidates.isEmpty {
                let bestCandidate = totalCandidates.sorted { $0.confidence > $1.confidence }.first!
                return bestCandidate.amount
            }
            
            // Fallback - find largest reasonable amount
            return findLargestReasonableAmount(from: lines) ?? 0.0
        }
        
        // MARK: - Helper Methods
        
        private func extractCurrencyAmount(from line: String) -> Double? {
            // Patterns for currency amounts
            let currencyPatterns = [
                // Pattern 1: Any currency symbol + amount with decimals (e.g., $41.11, €41,11, ₺41.11, ¥41.11)
                #"^[£$€₺¥₹₽₩¢₪₫₡₦₵₸₴₱₲₯₧₨₭﷼₼₾₿](\d{1,6}[.,]\d{1,3})$"#,
                
                // Pattern 2: Amount with decimals only (e.g., 41.11, 41,11)
                #"^(\d{1,6}[.,]\d{1,3})$"#,
                
                // Pattern 3: Any currency symbol + whole amount (e.g., $41, €41, ₺41, ¥4111)
                #"^[£$€₺¥₹₽₩¢₪₫₡₦₵₸₴₱₲₯₧₨₭﷼₼₾₿](\d{1,8})$"#,
                
                // Pattern 4: Whole amount only (e.g., 41, 4111)
                #"^(\d{1,8})$"#,
                
                // Pattern 5: Amount + currency symbol at end (e.g., 41.11€, 41,11₺)
                #"^(\d{1,6}[.,]\d{1,3})\s?[£$€₺¥₹₽₩¢₪₫₡₦₵₸₴₱₲₯₧₨₭﷼₼₾₿]$"#,
                
                // Pattern 6: Whole amount + currency symbol at end (e.g., 41€, 4111¥)
                #"^(\d{1,8})\s?[£$€₺¥₹₽₩¢₪₫₡₦₵₸₴₱₲₯₧₨₭﷼₼₾₿]$"#
            ]
            
            for pattern in currencyPatterns {
                if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                    let range = NSRange(location: 0, length: line.utf16.count)
                    if let match = regex.firstMatch(in: line, options: [], range: range) {
                        let captureRange = match.range(at: 1)
                        if let swiftRange = Range(captureRange, in: line) {
                            let amountString = String(line[swiftRange])
                            if let amount = Double(amountString) {
                                if amount >= 0.01 && amount <= 5000.00 {
                                    return amount
                                }
                            }
                        }
                    }
                }
            }
            return nil
        }
        
        private func extractAmountFromTotalLine(_ line: String) -> Double? {
            let totalPatterns = [
                // Pattern 1: "Total:" + any currency + flexible decimals
                #"(?i)total\s*:?\s*[£$€₺¥₹₽₩¢₪₫₡₦₵₸₴₱₲₯₧₨₭﷼₼₾₿]?\s*(\d{1,8}[.,]\d{1,3})"#,
                
                // Pattern 2: Amount + currency + "total"
                #"[£$€₺¥₹₽₩¢₪₫₡₦₵₸₴₱₲₯₧₨₭﷼₼₾₿]?\s*(\d{1,8}[.,]\d{1,3})\s*(?i)total"#,
                
                // Pattern 3: Amount + currency at end + "total"
                #"(\d{1,8}[.,]\d{1,3})\s*[£$€₺¥₹₽₩¢₪₫₡₦₵₸₴₱₲₯₧₨₭﷼₼₾₿]\s*(?i)total"#,
                
                // Pattern 4: "Total:" + whole amounts + any currency
                #"(?i)total\s*:?\s*[£$€₺¥₹₽₩¢₪₫₡₦₵₸₴₱₲₯₧₨₭﷼₼₾₿]?\s*(\d{1,8})"#,
                
                // Pattern 5: Whole amount + currency + "total"
                #"[£$€₺¥₹₽₩¢₪₫₡₦₵₸₴₱₲₯₧₨₭﷼₼₾₿]?\s*(\d{1,8})\s*(?i)total"#,
                
                // Pattern 6: Whole amount + currency at end + "total"
                #"(\d{1,8})\s*[£$€₺¥₹₽₩¢₪₫₡₦₵₸₴₱₲₯₧₨₭﷼₼₾₿]\s*(?i)total"#,
                
                // Pattern 7: "Total:" + amount + currency at end
                #"(?i)total\s*:?\s*(\d{1,8}[.,]\d{1,3})\s*[£$€₺¥₹₽₩¢₪₫₡₦₵₸₴₱₲₯₧₨₭﷼₼₾₿]"#,
                
                // Pattern 8: "Total:" + whole amount + currency at end
                #"(?i)total\s*:?\s*(\d{1,8})\s*[£$€₺¥₹₽₩¢₪₫₡₦₵₸₴₱₲₯₧₨₭﷼₼₾₿]"#
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
        
        private func calculateTotalConfidence(for line: String, amount: Double) -> Int {
            var confidence = 0
            let lowerLine = line.lowercased()
            
            if lowerLine.contains("balance due") {
                confidence += 100
            } else if lowerLine.contains("grand total") || lowerLine.contains("final total") {
                confidence += 80
            } else if lowerLine.contains("total") {
                confidence += 50
            }
            
            // Reasonable amount range
            if amount >= 1.00 && amount <= 500.00 {
                confidence += 30
            } else if amount >= 0.50 && amount <= 1000.00 {
                confidence += 20
            }
            
            // Penalty for unreasonable amounts
            if amount < 0.10 || amount > 2000.00 {
                confidence -= 50
            }
            
            return confidence
        }
        
        private func findLargestReasonableAmount(from lines: [String]) -> Double? {
            var amounts: [Double] = []
            
            for line in lines {
                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Skip lines that are clearly not totals
                if trimmedLine.lowercased().contains("change") ||
                   trimmedLine.lowercased().contains("tender") ||
                   trimmedLine.lowercased().contains("cash back") {
                    continue
                }
                
                if let amount = extractCurrencyAmount(from: trimmedLine) {
                    amounts.append(amount)
                }
            }
            
            // Return largest reasonable amount
            return amounts.filter { $0 >= 1.00 && $0 <= 1000.00 }.max()
        }
}
