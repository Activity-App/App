//
//  PointsGraph.swift
//  Project SF
//
//  Created by Christian Privitelli on 16/7/20.
//

import Foundation
import SwiftUI

struct PointsGraph: View {
    
    @State var currentPage = 1
    @State var translation: CGFloat = 0
    let startDate = Calendar.current.date(byAdding: .day, value: -11, to: Date())
    let history: [CGFloat] = [10, 40, 500, 250, 5, 65, 92, 520, 40, 20, 50]
    let bars = 7
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ForEach(1 ..< pages() + 1) { page in
                    VStack {
                        Text(dateRange())
                            .font(.caption)
                            .foregroundColor(Color(.tertiaryLabel))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        HStack {
                            ForEach(history.indices[start(page) ..< end(page)], id: \.self) { index in
                                bar((history[index]/maxFor(page))*geometry.size.height)
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
                        .frame(width: geometry.size.width)
                    }
                }
            }
            .offset(x: calcOffset(width: geometry.size.width))
            .frame(width: geometry.size.width*CGFloat(pages()))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        translation = value.translation.width
                    }
                    .onEnded { _ in
                        withAnimation(.spring()) {
                            if translation < -150 {
                                currentPage += 1
                            } else if translation > 150 {
                                currentPage -= 1
                            }
                            translation = 0
                        }
                    }
            )
        }
    }
    
    func dateRange() -> ClosedRange<Date> {
        let startPageValue = (currentPage - 1) * bars
        var lastPageValue = 0
        
        if currentPage == pages() { // Then it's the last page
            let lastPageAmount = (history.count - (pages() - 1) * bars) - 1
            lastPageValue = startPageValue+lastPageAmount
        } else {
            lastPageValue = bars * currentPage - 1
        }
        
        let start = Calendar.current.date(byAdding: .day, value: startPageValue, to: startDate!)!
        let endDate = Calendar.current.date(byAdding: .day, value: lastPageValue, to: startDate!)!
        return start...endDate
    }
    
    func calcOffset(width: CGFloat) -> CGFloat {
        if currentPage == 1 {
            return 0 + translation
        } else {
            let negativeWidth = -width
            let calculated = negativeWidth * CGFloat(currentPage - 1)
            return calculated + translation
        }
    }
    
    func pages() -> Int {
        return Int(ceil(Double(history.count) / Double(bars)))
    }
    
    func maxFor(_ page: Int) -> CGFloat {
        return history[start(page) ..< end(page)].max() ?? 0
    }
    
    func start(_ page: Int) -> Int {
        if page == 1 { return 0 } else {
            return (page-1)*7
        }
    }
    
    func end(_ page: Int) -> Int {
        return min(page*7, history.count)
    }
    
    func bar(_ height: CGFloat) -> some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .foregroundColor(Color(.secondarySystemFill))
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .foregroundColor(.accentColor)
                .frame(height: height)
        }
        .mask(RoundedRectangle(cornerRadius: 15, style: .continuous))
    }
}

struct PointsGraph_Previews: PreviewProvider {
    static var previews: some View {
        PointsGraph()
            .frame(width: nil, height: 200, alignment: .center)
    }
}
