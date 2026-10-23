//
//  OnboardingPager.swift
//  Formwork
//
//  Created by Daniel Wolbach on 12.10.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

protocol OnboardingPage: CaseIterable, Hashable {
    var tint: Pictogram.Tint { get }

    var title: LocalizedStringResource { get }

    var message: LocalizedStringResource { get }
}

extension OnboardingPage {
    var next: Self? {
        let pages = Array(Self.allCases)

        guard let index = pages.firstIndex(of: self), index + 1 < pages.count else {
            return nil
        }

        return pages[index + 1]
    }
}

struct OnboardingPager<Page: OnboardingPage, Preview: View, Controls: View>: View {
    private let preview: (Page) -> Preview

    private let controls: Controls

    @Binding
    private var selection: Page

    init(selection: Binding<Page>, @ViewBuilder preview: @escaping (Page) -> Preview, @ViewBuilder controls: () -> Controls) {
        self._selection = selection
        self.preview = preview
        self.controls = controls()
    }

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(pages, id: \.self) { page in
                    PageView(page: page, preview: preview(page))
                        .containerRelativeFrame(.horizontal)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: position)
        .scrollIndicators(.hidden)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: selection)
        .safeAreaBar(edge: .bottom) {
            VStack(spacing: 32) {
                indicator

                controls
            }
            .padding(.horizontal)
        }
        .background {
            LinearGradient(colors: [selection.tint.color.opacity(0.25), .clear], startPoint: .top, endPoint: .center)
                .animation(.smooth, value: selection)
                .ignoresSafeArea()
        }
    }

    private var indicator: some View {
        HStack(spacing: 6) {
            ForEach(pages, id: \.self) { page in
                Capsule()
                    .fill(.tint)
                    .opacity(page == selection ? 1 : 0.2)
                    .frame(width: page == selection ? 20 : 6, height: 6)
            }
        }
        .animation(.snappy, value: selection)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(.onboardingPageLabel(page: (pages.firstIndex(of: selection) ?? 0) + 1, count: pages.count)))
    }

    private var pages: [Page] {
        Array(Page.allCases)
    }

    /// The scroll view can report no page, and then the selection keeps the last one.
    private var position: Binding<Page?> {
        Binding(
            get: {
                selection
            },
            set: { page in
                if let page {
                    selection = page
                }
            }
        )
    }
}

private struct PageView<Page: OnboardingPage, Preview: View>: View {
    let page: Page

    let preview: Preview

    var body: some View {
        ViewThatFits(in: .vertical) {
            content

            ScrollView {
                content
            }
        }
    }

    private var content: some View {
        VStack(spacing: 16) {
            preview
                .frame(maxWidth: 256 + 128, maxHeight: .infinity)
                .accessibilityHidden(true)

            VStack(spacing: 16) {
                Text(page.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .accessibilityAddTraits(.isHeader)

                Text(page.message)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .frame(maxHeight: .infinity)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 64)
    }
}
