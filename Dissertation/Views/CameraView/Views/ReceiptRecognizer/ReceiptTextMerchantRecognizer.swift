import Foundation

extension ReceiptDataExtractor {
    func extractMerchantName(from lines: [String]) -> String? {
        // Skip common non-name patterns (MORE COMPREHENSIVE)
        let skipPatterns = [
            #"(?i)^(give us feedback|thank you|thanks|visit|come again|see back|survey)"#,  // Promotional text
            #"(?i)^(receipt|invoice|bill|order|id #|ref #)"#,                              // Receipt headers
            #"(?i)^(address|phone|tel|email|website|www\.|manager|cashier)"#,              // Contact/staff info
            #"(?i)(tax|vat|gst|total|subtotal|change|cash|card|debit|credit)"#,            // Financial terms
            #"(?i)(save money|live better|always low|low prices)"#,                        // Slogans
            #"^\d+.*"#,                                                                    // Lines starting with numbers
            #".*\d{4}[-/]\d{2}[-/]\d{2}.*"#,                                              // Date patterns
            #".*\d{1,2}[-/]\d{1,2}[-/]\d{2,4}.*"#,                                       // More date patterns
            #".*(\$|£|€|¥|₹)\s*\d+.*"#,                                                   // Lines with currency amounts
            #".*\d+\.\d{2}.*"#,                                                           // Lines with decimal amounts
            #"^\s*$"#,                                                                    // Empty lines
            #"^[^A-Za-z]*$"#,                                                             // No letters
            #".*[0-9]{8,}.*"#,                                                            // Long number sequences
            #"^.{1,2}$"#,                                                                 // Very short lines
            #"(?i)(store hours|open|closed|appr code|terminal|network)"#,                 // Store info/tech terms
            #"(?i)(items sold|barcode|scan with|app)"#                                    // Receipt footer terms
        ]
        
        // Known merchant indicators (help identify valid business names)
        let merchantIndicators = [
            #"(?i)(walmart|wal-mart|wal\*mart)"#,
            #"(?i)(trader joe'?s)"#,
            #"(?i)(whole foods)"#,
            #"(?i)(costco)"#,
            #"(?i)(winco)"#,
            #"(?i)(target)"#,
            #"(?i)(kroger)"#,
            #"(?i)(safeway)"#,
            #"(?i)(meijer)"#,
            #"(?i)(publix)"#,
            #"(?i)(spar)"#,
            #"(?i)(market|mart|store|shop|cafe|restaurant|crêperie)"#
        ]
        
        var candidates: [(line: String, score: Int, position: Int)] = []
        
        for (index, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Skip empty lines
            if trimmedLine.isEmpty { continue }
            
            // Check if line should be skipped
            var shouldSkip = false
            for skipPattern in skipPatterns {
                if let regex = try? NSRegularExpression(pattern: skipPattern, options: []) {
                    let range = NSRange(location: 0, length: trimmedLine.utf16.count)
                    if regex.firstMatch(in: trimmedLine, options: [], range: range) != nil {
                        shouldSkip = true
                        break
                    }
                }
            }
            
            if shouldSkip { continue }
            
            // Score potential merchant names
            var score = 0
            
            // Bonus for known merchant indicators
            for indicator in merchantIndicators {
                if let regex = try? NSRegularExpression(pattern: indicator, options: []) {
                    let range = NSRange(location: 0, length: trimmedLine.utf16.count)
                    if regex.firstMatch(in: trimmedLine, options: [], range: range) != nil {
                        score += 100  // High score for known merchants
                        break
                    }
                }
            }
            
            // Bonus for being early in receipt (business names usually appear first)
            if index < 5 {
                score += 20
            } else if index < 10 {
                score += 10
            }
            
            // Bonus for ALL CAPS (common for business names)
            if trimmedLine == trimmedLine.uppercased() && trimmedLine.count > 2 {
                score += 15
            }
            
            // Bonus for reasonable length (not too short, not too long)
            if trimmedLine.count >= 3 && trimmedLine.count <= 30 {
                score += 10
            }
            
            // Bonus for containing letters (must be a real name)
            if trimmedLine.rangeOfCharacter(from: .letters) != nil {
                score += 5
            }
            
            // Penalty for containing too many numbers
            let numberCount = trimmedLine.filter { $0.isNumber }.count
            if numberCount > trimmedLine.count / 2 {
                score -= 20
            }
            
            // Only consider lines with some minimum criteria
            if score > 0 && trimmedLine.count >= 3 && trimmedLine.rangeOfCharacter(from: .letters) != nil {
                candidates.append((line: trimmedLine, score: score, position: index))
            }
        }
        
        // Sort by score (highest first), then by position (earlier first)
        candidates.sort { first, second in
            if first.score != second.score {
                return first.score > second.score
            }
            return first.position < second.position
        }
        
        // Return the best candidate
        return candidates.first?.line
    }
}
