//
//  PointsGraph.swift
//  Project SF
//
//  Created by Christian Privitelli on 16/7/20.
//

import Foundation
import SwiftUI

struct PointsGraph: View {
    
    @State var currentPage: Int = 0
    @State var translation: CGFloat = 0
    @State var allowAnimation = false
    var startDate: Date
    let history: [CGFloat]
    let bars = 7
    
    init(history: [CGFloat] = [10, 40, 500, 250, 5, 65, 92, 90, 95, 76, 29]) {
        self.history = history
        self.startDate = Date()
        self.startDate = Calendar.current.date(byAdding: .day, value: -history.count, to: Date())!
    }
    
    var body: some View {
        VStack {
            GeometryReader { masterGeo in
                HStack(spacing: 0) {
                    ForEach(1 ..< pages() + 1) { page in
                        VStack {
                            Text(dateRange())
                                .font(.caption)
                                .foregroundColor(Color(.tertiaryLabel))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            GeometryReader { innerGeo in
                                HStack {
                                    ForEach(history.indices[start(page) ..< end(page)],
                                            id: \.self) { index in
                                        bar(currentPage == page ? barHeight(history[index],
                                                                            height: innerGeo.size.height,
                                                                            page: page) : 0)
                                        if index == end(page) - 1 {
                                            VStack {
                                                Text("\(Int(maxFor(page)))")
                                                Spacer()
                                                Text("0")
                                            }
                                            .font(.caption)
                                            .foregroundColor(Color(.tertiaryLabel))
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .frame(width: masterGeo.size.width)
                            }
                        }
                    }
                }
                .offset(x: calcOffset(width: masterGeo.size.width))
                .frame(width: masterGeo.size.width*CGFloat(pages()))
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            translation = value.translation.width
                        }
                        .onEnded { _ in
                            withAnimation(.spring()) {
                                if translation < -100 {
                                    currentPage = min(pages(), currentPage+1)
                                } else if translation > 100 {
                                    currentPage = max(1, currentPage-1)
                                }
                                translation = 0
                            }
                        }
                )
            }
            .onAppear {
                currentPage = pages()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    allowAnimation = true
                }
            }
            HStack {
                ForEach(1 ..< pages() + 1) { dot in
                    Circle()
                        .foregroundColor(dot == currentPage ? Color(.systemGray) : Color(.tertiaryLabel))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 6)
        }
    }
    
    /// Calculates date range for current page.
    /// - Returns: A closed range of dates.
    func dateRange() -> ClosedRange<Date> {
        let startPageValue = (currentPage - 1) * bars
        var lastPageValue = 0
        
        if currentPage == pages() { // Then it's the last page
            let lastPageAmount = (history.count - (pages() - 1) * bars) - 1
            lastPageValue = startPageValue+lastPageAmount
        } else {
            lastPageValue = bars * currentPage - 1
        }
        
        let start = Calendar.current.date(byAdding: .day, value: startPageValue, to: startDate)!
        let endDate = Calendar.current.date(byAdding: .day, value: lastPageValue, to: startDate)!
        return start...endDate
    }
    
    /// Calculates the offset and page of the view
    /// - Parameter width: Parent view width.
    /// - Returns: An offset as a CGFloat.
    func calcOffset(width: CGFloat) -> CGFloat {
        if currentPage == 1 {
            return 0 + translation
        } else {
            let negativeWidth = -width
            let calculated = negativeWidth * CGFloat(currentPage - 1)
            return calculated + translation
        }
    }
    
    /// Maps pages to be opposite so latest data shows first.
    /// - Parameter page: The current non converted page.
    /// - Returns: Int of converted range page.
    func converted(_ page: Int) -> Int {
        let range = (1, pages())
        let reversedRange = (pages(), 1)
        let converted = page.convert(fromRange: range, toRange: reversedRange)
        return Int(converted)
    }
    
    /// Function to calculate how many pages there should be based on provided array.
    /// - Returns: Int for number of pages.
    func pages() -> Int {
        return Int(ceil(Double(history.count) / Double(bars)))
    }
    
    /// Gets the max value on a certain page.
    /// - Parameter page: Page to find max value.
    /// - Returns: Max value on certain page as CGFloat.
    func maxFor(_ page: Int) -> CGFloat {
        return history[start(page) ..< end(page)].max() ?? 0
    }
    
    /// Start index for provided array. Use with `end()` function.
    /// - Parameter page: Current page.
    /// - Returns: Provides the start index for certain page.
    func start(_ page: Int) -> Int {
        if page == 1 { return 0 } else {
            return (page - 1) * bars
        }
    }
    
    /// End index for provided array. Use with `start()` function.
    /// - Parameter page: Current page.
    /// - Returns: Provides the end index for certain page.
    func end(_ page: Int) -> Int {
        return min(page * bars, history.count)
    }
    
    /// Calculates what the height of a bar should be based on it's value, view height and the current page.
    /// - Parameters:
    ///   - value: Value of the bar (how many points)
    ///   - height: Height of view. Use geometry reader to feed max height possible
    ///   - page: Current page. Used to find max value for specific page.
    /// - Returns: Returns an approriate height for the bar fill.
    func barHeight(_ value: CGFloat, height: CGFloat, page: Int) -> CGFloat {
        return (value/maxFor(page)) * height
    }
    
    /// The bar view, set any bar styling here.
    /// - Parameter height: The height of the filled bar
    /// - Returns: Returns a bar view.
    func bar(_ height: CGFloat) -> some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .foregroundColor(Color(.secondarySystemFill))
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .foregroundColor(.accentColor)
                .frame(height: height)
                .animation(allowAnimation ? .spring() : nil)
        }
        .frame(maxWidth: 45)
        .mask(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

struct PointsGraph_Previews: PreviewProvider {
    static var previews: some View {
        PointsGraph()
            .frame(width: nil, height: 500, alignment: .center)
    }
}
