import Foundation

extension ReceiptDataExtractor {
    // MARK: - Date Extraction
       func extractDate(from lines: [String]) -> Date? {
           let dateFormatter = DateFormatter()
           dateFormatter.locale = Locale(identifier: "en_US_POSIX")
           
           // Date formats to try - prioritize most common receipt formats
           let dateFormats = [
               "dd/MM/yy",             // 25/12/20 (UK format, most common on receipts)
               "MM/dd/yy",             // 12/25/20 (US format)
               "dd-MM-yy",             // 25-12-20
               "MM-dd-yy",             // 12-25-20
               "dd/MM/yyyy",           // 25/12/2020
               "MM/dd/yyyy",           // 12/25/2020
               "yyyy-MM-dd",           // 2020-12-25
               "dd.MM.yy",             // 25.12.20
               "MM.dd.yy",             // 12.25.20
               "ddMMyy",               // 251220
               "MMddyy",               // 122520
           ]
           
           // Date patterns to find in text
           let datePatterns = [
               #"\b\d{1,2}[/-]\d{1,2}[/-]\d{2}\b"#,                        // DD/MM/YY or MM/DD/YY
               #"\b\d{1,2}[/-]\d{1,2}[/-]\d{4}\b"#,                        // DD/MM/YYYY or MM/DD/YYYY
               #"\b\d{4}[/-]\d{1,2}[/-]\d{1,2}\b"#,                        // YYYY-MM-DD
               #"\b\d{6}\b"#                                                // DDMMYY or MMDDYY
           ]
           
           var foundDates: [(date: Date, confidence: Int, line: String)] = []
           
           for (lineIndex, line) in lines.enumerated() {
               let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
               
               // Skip obvious non-date lines
               if trimmedLine.isEmpty ||
                  trimmedLine.lowercased().contains("item") ||
                  trimmedLine.lowercased().contains("total") ||
                  trimmedLine.contains("\(getCurrencySymbol())") {
                   continue
               }
               
               // Try to find date patterns in the line
               for pattern in datePatterns {
                   if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                       let range = NSRange(location: 0, length: trimmedLine.utf16.count)
                       let matches = regex.matches(in: trimmedLine, options: [], range: range)
                       
                       for match in matches {
                           if let swiftRange = Range(match.range, in: trimmedLine) {
                               let matchedString = String(trimmedLine[swiftRange])
                               
                               // Try to parse with each format
                               for (formatIndex, format) in dateFormats.enumerated() {
                                   dateFormatter.dateFormat = format
                                   if let date = dateFormatter.date(from: matchedString) {
                                       // Calculate confidence based on format priority and position
                                       var confidence = dateFormats.count - formatIndex
                                       
                                       // Bonus for being near the top of receipt
                                       if lineIndex < 10 {
                                           confidence += 20
                                       }
                                       
                                       foundDates.append((date: date, confidence: confidence, line: trimmedLine))
                                       break
                                   }
                               }
                           }
                       }
                   }
               }
           }
           
           // Filter out unreasonable dates
           let currentDate = Date()
           let calendar = Calendar.current
           let currentYear = calendar.component(.year, from: currentDate)
           
           let validDates = foundDates.filter { dateInfo in
               let year = calendar.component(.year, from: dateInfo.date)
               // Accept dates from 2000 to current year + 1
               return year >= 2000 && year <= currentYear + 1 && dateInfo.date <= currentDate
           }
           
           // Return the most confident valid date
           return validDates.sorted { first, second in
               if first.confidence != second.confidence {
                   return first.confidence > second.confidence
               }
               return first.date > second.date // More recent dates preferred if confidence tied
           }.first?.date
       }
}
