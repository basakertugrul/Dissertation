import Foundation

// MARK: - Merchant Name Extraction
   func extractMerchantName(from lines: [String]) -> String? {
       // Skip patterns - things that are definitely NOT merchant names
       let skipPatterns = [
           #"(?i)^(give us feedback|thank you|thanks|visit|come again|see back|survey)"#,
           #"(?i)^(receipt|invoice|bill|order|id #|ref #)"#,
           #"(?i)^(address|phone|tel|email|website|www\.|manager|cashier)"#,
           #"(?i)(tax|vat|gst|total|subtotal|change|cash|card|debit|credit)"#,
           #"(?i)(save money|live better|always low|low prices|good food for all)"#,
           #"^\d+.*"#,                                                    // Lines starting with numbers
           #".*\d{4}[-/]\d{2}[-/]\d{2}.*"#,                              // Date patterns
           #".*\d{1,2}[-/]\d{1,2}[-/]\d{2,4}.*"#,                       // More date patterns
           #".*[£$€¥₹]\s*\d+.*"#,                                        // Lines with currency amounts
           #".*\d+\.\d{2}.*"#,                                           // Lines with decimal amounts
           #"^\s*$"#,                                                    // Empty lines
           #"^[^A-Za-z]*$"#,                                             // No letters
           #".*[0-9]{8,}.*"#,                                            // Long number sequences
           #"^.{1,2}$"#,                                                 // Very short lines
           #"(?i)(store hours|open|closed|appr code|terminal|network)"#,
           #"(?i)(items sold|barcode|scan with|app|vat number|auth code)"#,
           #"(?i)(step|street|london|charterhouse|supermarkets ltd)"#,   // Address components
           #"^\d{4}\s\d{3}\s\d{4}$"#,                                   // Phone numbers
           #"^www\."#,                                                   // Websites
           #"^\*+.*"#                                                    // Lines starting with asterisks
       ]
       
       // Known merchant patterns - boost confidence for recognized brands
       let merchantPatterns = [
           (#"(?i)^sainsbury'?s?$"#, 100),                              // Exact Sainsbury's match
           (#"(?i)^walmart$|^wal-?mart$"#, 100),
           (#"(?i)^tesco$"#, 100),
           (#"(?i)^asda$"#, 100),
           (#"(?i)^morrisons?$"#, 100),
           (#"(?i)^target$"#, 100),
           (#"(?i)^costco$"#, 100),
           (#"(?i)^kroger$"#, 100),
           (#"(?i).*market$|.*mart$|.*store$|.*shop$"#, 50)             // Generic store names
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
           
           // Check for known merchant patterns
           for (pattern, bonusScore) in merchantPatterns {
               if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                   let range = NSRange(location: 0, length: trimmedLine.utf16.count)
                   if regex.firstMatch(in: trimmedLine, options: [], range: range) != nil {
                       score += bonusScore
                       break
                   }
               }
           }
           
           // High bonus for being at the very top (first 3 lines)
           if index < 3 {
               score += 50
           } else if index < 6 {
               score += 30
           } else if index < 10 {
               score += 10
           }
           
           // Bonus for reasonable length business names
           if trimmedLine.count >= 3 && trimmedLine.count <= 25 {
               score += 15
           }
           
           // Bonus for containing only letters and common business characters
           let businessChars = CharacterSet.letters.union(CharacterSet.punctuationCharacters).union(CharacterSet.whitespaces)
           if trimmedLine.rangeOfCharacter(from: businessChars.inverted) == nil {
               score += 10
           }
           
           // Penalty for too many numbers
           let numberCount = trimmedLine.filter { $0.isNumber }.count
           if numberCount > trimmedLine.count / 3 {
               score -= 30
           }
           
           // Must have some letters to be a valid business name
           if trimmedLine.rangeOfCharacter(from: .letters) != nil && score > 0 {
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
