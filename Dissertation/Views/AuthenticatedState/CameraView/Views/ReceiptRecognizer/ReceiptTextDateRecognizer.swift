import Foundation

extension ReceiptDataExtractor {
    func extractDate(from lines: [String]) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        // Common date formats to try (including 2-digit years)
        let dateFormats = [
            // 4-digit year formats
            "yyyy-MM-dd",           // 2024-12-25
            "MM/dd/yyyy",           // 12/25/2024
            "dd/MM/yyyy",           // 25/12/2024
            "MM-dd-yyyy",           // 12-25-2024
            "dd-MM-yyyy",           // 25-12-2024
            "yyyy/MM/dd",           // 2024/12/25
            "MM.dd.yyyy",           // 12.25.2024
            "dd.MM.yyyy",           // 25.12.2024
            "yyyyMMdd",             // 20241225
            "MMM dd, yyyy",         // Dec 25, 2024
            "MMMM dd, yyyy",        // December 25, 2024
            "dd MMM yyyy",          // 25 Dec 2024
            "dd MMMM yyyy",         // 25 December 2024
            "MMM dd yyyy",          // Dec 25 2024
            "MMMM dd yyyy",         // December 25 2024
            
            // 2-digit year formats (CRITICAL for fixing your issue)
            "MM/dd/yy",             // 12/25/20
            "dd/MM/yy",             // 25/12/20
            "MM-dd-yy",             // 12-25-20
            "dd-MM-yy",             // 25-12-20
            "yy/MM/dd",             // 20/12/25
            "MM.dd.yy",             // 12.25.20
            "dd.MM.yy",             // 25.12.20
            "MMM dd, yy",           // Dec 25, 20
            "dd MMM yy",            // 25 Dec 20
            "MMM dd yy",            // Dec 25 20
            
            // Common receipt timestamp formats
            "MM/dd/yyyy HH:mm:ss",  // 12/25/2024 10:30:45
            "MM/dd/yy HH:mm:ss",    // 12/25/20 10:30:45
            "yyyy-MM-dd HH:mm:ss",  // 2024-12-25 10:30:45
            "dd/MM/yy HH:mm",       // 25/12/20 10:30
            "MM/dd/yy HH:mm",       // 12/25/20 10:30
        ]
        
        // Enhanced date patterns with 2-digit year support
        let datePatterns = [
            // 4-digit years
            #"\b\d{4}[-/]\d{1,2}[-/]\d{1,2}\b"#,                    // 2024-12-25, 2024/12/25
            #"\b\d{1,2}[-/]\d{1,2}[-/]\d{4}\b"#,                    // 12/25/2024, 12-25-2024
            
            // 2-digit years (THIS IS KEY!)
            #"\b\d{1,2}[-/]\d{1,2}[-/]\d{2}\b"#,                     // 12/25/20, 12-25-20
            
            // Named month patterns
            #"\b[A-Za-z]{3,9}\s+\d{1,2},?\s+\d{4}\b"#,              // December 25, 2024
            #"\b[A-Za-z]{3,9}\s+\d{1,2},?\s+\d{2}\b"#,              // Dec 25, 20
            #"\b\d{1,2}\s+[A-Za-z]{3,9}\s+\d{4}\b"#,                // 25 December 2024
            #"\b\d{1,2}\s+[A-Za-z]{3,9}\s+\d{2}\b"#,                // 25 Dec 20
            
            // Timestamp patterns (date + time)
            #"\b\d{1,2}[-/]\d{1,2}[-/]\d{2,4}\s+\d{1,2}:\d{2}(:\d{2})?\b"#,  // 12/25/20 10:30:45
        ]
        
        var foundDates: [(date: Date, confidence: Int)] = []
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Skip lines that are clearly not dates
            if trimmedLine.isEmpty ||
               trimmedLine.lowercased().contains("item") ||
               trimmedLine.lowercased().contains("sold") ||
               trimmedLine.lowercased().contains("total") ||
               trimmedLine.lowercased().contains("tax") ||
               trimmedLine.contains("$") || trimmedLine.contains("£") || trimmedLine.contains("€") {
                continue
            }
            
            // Try exact line match first
            for (index, format) in dateFormats.enumerated() {
                dateFormatter.dateFormat = format
                if let date = dateFormatter.date(from: trimmedLine) {
                    let confidence = dateFormats.count - index // Earlier formats get higher confidence
                    foundDates.append((date: date, confidence: confidence))
                }
            }
            
            // Try regex patterns within the line
            for pattern in datePatterns {
                if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                    let range = NSRange(location: 0, length: trimmedLine.utf16.count)
                    let matches = regex.matches(in: trimmedLine, options: [], range: range)
                    
                    for match in matches {
                        if let swiftRange = Range(match.range, in: trimmedLine) {
                            let matchedString = String(trimmedLine[swiftRange])
                            
                            // Try to parse the matched substring
                            for (index, format) in dateFormats.enumerated() {
                                dateFormatter.dateFormat = format
                                if let date = dateFormatter.date(from: matchedString.trimmingCharacters(in: .whitespacesAndNewlines)) {
                                    let confidence = dateFormats.count - index
                                    foundDates.append((date: date, confidence: confidence))
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Filter out obviously wrong dates and sort by confidence
        let currentYear = Calendar.current.component(.year, from: Date())
        let validDates = foundDates.filter { dateInfo in
            let year = Calendar.current.component(.year, from: dateInfo.date)
            // Accept dates from 1990 to 5 years in the future
            return year >= 1990 && year <= currentYear + 5
        }
        
        // Return the date with highest confidence, or most recent if tied
        return validDates.sorted { first, second in
            if first.confidence != second.confidence {
                return first.confidence > second.confidence
            }
            return first.date > second.date
        }.first?.date
    }
}
