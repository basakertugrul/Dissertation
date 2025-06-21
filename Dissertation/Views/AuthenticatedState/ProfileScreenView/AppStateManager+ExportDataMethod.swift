import UIKit
import PDFKit

extension AppStateManager {
    func generateExpensePDF(completion: @escaping (Data?) -> Void) {
        let pdfMetaData = [
            kCGPDFContextCreator: "FundBud",
            kCGPDFContextAuthor: user?.fullName ?? "User",
            kCGPDFContextTitle: "Expense Report"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let pdfData = renderer.pdfData { context in
            context.beginPage()
            
            var yPosition: CGFloat = 60
            let margin: CGFloat = 40
            let contentWidth = pageWidth - (margin * 2)
            
            // Title
            yPosition = drawTitle(in: pageRect, yPosition: yPosition)
            
            // User Info
            yPosition = drawUserInfo(in: pageRect, yPosition: yPosition, margin: margin)
            
            // Summary Stats
            yPosition = drawSummaryStats(in: pageRect, yPosition: yPosition, margin: margin, contentWidth: contentWidth)
            
            // Expenses Table
            yPosition = drawExpensesTable(in: pageRect, yPosition: yPosition, margin: margin, contentWidth: contentWidth, context: context)
        }
        
        completion(pdfData)
    }
    
    private func drawTitle(in pageRect: CGRect, yPosition: CGFloat) -> CGFloat {
        let titleText = "FundBud Expense Report"
        let titleFont = UIFont.boldSystemFont(ofSize: 24)
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor.systemBlue
        ]
        
        let titleRect = CGRect(x: 40, y: yPosition, width: pageRect.width - 80, height: 40)
        titleText.draw(in: titleRect, withAttributes: titleAttributes)
        
        return yPosition + 50
    }
    
    private func drawUserInfo(in pageRect: CGRect, yPosition: CGFloat, margin: CGFloat) -> CGFloat {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        
        let userInfo = """
       Generated: \(dateFormatter.string(from: Date()))
       User: \(user?.fullName ?? "User")
       Period: \(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: Date()))
       """
        
        let font = UIFont.systemFont(ofSize: 12)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.gray
        ]
        
        let rect = CGRect(x: margin, y: yPosition, width: pageRect.width - (margin * 2), height: 60)
        userInfo.draw(in: rect, withAttributes: attributes)
        
        return yPosition + 80
    }
    
    private func drawSummaryStats(in pageRect: CGRect, yPosition: CGFloat, margin: CGFloat, contentWidth: CGFloat) -> CGFloat {
        let summaryFont = UIFont.boldSystemFont(ofSize: 14)
        let valueFont = UIFont.systemFont(ofSize: 16)
        
        let summaryData: [(String, String)] = [
            ("Total Expenses:", "£\(String(format: "%.2f", totalExpenses))"),
            ("Daily Budget:", "£\(String(format: "%.2f", dailyBalance ?? 0))"),
            ("Days Tracked:", "\(daysSinceStart)"),
            ("Average Daily:", "\(formattedAverageDaily)"),
            ("Current Balance:", "£\(String(format: "%.2f", calculatedBalance))")
        ]
        
        var currentY = yPosition
        
        // Summary title
        let summaryTitle = "Summary"
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.black
        ]
        let titleRect = CGRect(x: margin, y: currentY, width: contentWidth, height: 25)
        summaryTitle.draw(in: titleRect, withAttributes: titleAttributes)
        currentY += 35
        
        // Summary items
        for (label, value) in summaryData {
            let labelAttributes: [NSAttributedString.Key: Any] = [.font: summaryFont, .foregroundColor: UIColor.black]
            let valueAttributes: [NSAttributedString.Key: Any] = [.font: valueFont, .foregroundColor: UIColor.systemBlue]
            
            let labelRect = CGRect(x: margin, y: currentY, width: contentWidth * 0.6, height: 20)
            let valueRect = CGRect(x: margin + (contentWidth * 0.6), y: currentY, width: contentWidth * 0.4, height: 20)
            
            label.draw(in: labelRect, withAttributes: labelAttributes)
            value.draw(in: valueRect, withAttributes: valueAttributes)
            
            currentY += 25
        }
        
        return currentY + 30
    }
    
    private func drawExpensesTable(in pageRect: CGRect, yPosition: CGFloat, margin: CGFloat, contentWidth: CGFloat, context: UIGraphicsPDFRendererContext) -> CGFloat {
        var currentY = yPosition
        let rowHeight: CGFloat = 20
        let headerHeight: CGFloat = 25
        
        // Table title
        let tableTitle = "Expense Details"
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.black
        ]
        let titleRect = CGRect(x: margin, y: currentY, width: contentWidth, height: 25)
        tableTitle.draw(in: titleRect, withAttributes: titleAttributes)
        currentY += 35
        
        // Table headers
        let headers = ["Date", "Amount", "Category", "Description"]
        let columnWidths: [CGFloat] = [contentWidth * 0.2, contentWidth * 0.2, contentWidth * 0.25, contentWidth * 0.35]
        
        let headerFont = UIFont.boldSystemFont(ofSize: 12)
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: headerFont,
            .foregroundColor: UIColor.white
        ]
        
        // Draw header background
        let headerRect = CGRect(x: margin, y: currentY, width: contentWidth, height: headerHeight)
        UIColor.systemBlue.setFill()
        UIRectFill(headerRect)
        
        // Draw headers
        var xPosition: CGFloat = margin
        for (index, header) in headers.enumerated() {
            let rect = CGRect(x: xPosition + 5, y: currentY + 5, width: columnWidths[index] - 10, height: headerHeight - 10)
            header.draw(in: rect, withAttributes: headerAttributes)
            xPosition += columnWidths[index]
        }
        
        currentY += headerHeight
        
        // Table rows
        let cellFont = UIFont.systemFont(ofSize: 10)
        let cellAttributes: [NSAttributedString.Key: Any] = [
            .font: cellFont,
            .foregroundColor: UIColor.black
        ]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        for (index, expense) in expenseViewModels.enumerated() {
            // Check if we need a new page
            if currentY + rowHeight > pageRect.height - 60 {
                context.beginPage()
                currentY = 60
            }
            
            // Alternate row colors
            if index % 2 == 0 {
                UIColor.systemGray6.setFill()
                let rowRect = CGRect(x: margin, y: currentY, width: contentWidth, height: rowHeight)
                UIRectFill(rowRect)
            }
            
            let rowData = [
                dateFormatter.string(from: expense.date),
                "£\(String(format: "%.2f", expense.amount))",
                expense.name
            ]
            
            xPosition = margin
            for (index, data) in rowData.enumerated() {
                let rect = CGRect(x: xPosition + 5, y: currentY + 2, width: columnWidths[index] - 10, height: rowHeight - 4)
                data.draw(in: rect, withAttributes: cellAttributes)
                xPosition += columnWidths[index]
            }
            
            currentY += rowHeight
        }
        
        return currentY
    }
    
    func sharePDF(pdfData: Data) {
        let fileName = "FundBud_Expenses_\(Date().timeIntervalSince1970).pdf"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try pdfData.write(to: path)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                // Find the top-most presented view controller
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    
                    var topController = window.rootViewController
                    while let presentedController = topController?.presentedViewController {
                        topController = presentedController
                    }
                    
                    guard let presentingController = topController else { return }
                    
                    let activityController = UIActivityViewController(activityItems: [path], applicationActivities: nil)
                    activityController.setValue("FundBud Expense Report", forKey: "subject")
                    
                    // For iPad support
                    if let popover = activityController.popoverPresentationController {
                        popover.sourceView = presentingController.view
                        popover.sourceRect = CGRect(
                            x: presentingController.view.bounds.midX,
                            y: presentingController.view.bounds.midY,
                            width: 0,
                            height: 0
                        )
                        popover.permittedArrowDirections = []
                    }
                    
                    presentingController.present(activityController, animated: true)
                }
                self.disableLoadingView()
            }
        } catch {
            print("Error sharing PDF: \(error)")
        }
    }
}
