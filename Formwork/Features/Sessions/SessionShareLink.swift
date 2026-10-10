//
//  SessionShareLink.swift
//  Formwork
//
//  Created by Daniel Wolbach on 21.09.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct SessionShareLink: View {
    private let session: Session

    @Environment(\.units)
    private var units: Units

    init(_ session: Session) {
        self.session = session
    }

    var body: some View {
        let shareImage = SessionShareImage(session: session, units: units)

        ShareLink(
            item: shareImage,
            subject: Text(verbatim: shareImage.name),
            message: Text(.shareMessage),
            preview: SharePreview(shareImage.name, image: Image(.imageAppIcon))
        ) {
            Label(.share)
        }
    }
}

private struct SessionShareCard: View {
    private let session: Session

    @Environment(\.units)
    private var units: Units

    init(_ session: Session) {
        self.session = session
    }

    var body: some View {
        VStack(spacing: 24) {
            header
            summary
            footer
        }
        .padding()
        .padding(.top)
        .frame(width: 1080 / 3)
        .fixedSize(horizontal: false, vertical: true)
        .background {
            Color.white
            LinearGradient(colors: [tint.opacity(0.25), .clear], startPoint: .top, endPoint: .center)
        }
    }

    private var header: some View {
        HStack {
            VStack {
                Text(.shareTitle)
                    .font(.system(.title2, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .minimumScaleFactor(0.8)
                    .padding(.leading, 4)
                    .lineLimit(3)

                PictogramRow(
                    session.pictogram,
                    title: session.title,
                    subtitle: session.startDate.formatted(session.wallClockTime(date: .numeric))
                )
            }

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 100))
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, tint.gradient)
                .rotationEffect(.degrees(15))
                .offset(y: -25)
        }
    }

    private var summary: some View {
        TileGrid(columns: 2, spacing: 8, aspectRatio: 2) {
            ForEach([SessionFigureKind.duration, .volume, .completedExercises, .exerciseDuration]) { kind in
                ReadingCard(kind.definition, reading: kind.reading(of: session))
            }
            personalBest.tileSpan(columns: 2)
        }
    }

    private var footer: some View {
        HStack(spacing: 8) {
            Image(.imageAppIcon)
                .resizable()
                .frame(width: 24, height: 24)
                .clipShape(.rect(cornerRadius: 6.3, style: .continuous))

            Text(verbatim: AppMetadata.appName)
                .font(.system(.footnote, design: .rounded, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var personalBest: some View {
        if let bestEntry {
            HStack {
                Image(systemName: Pictogram.record.image)
                    .font(.system(size: 32))
                    .foregroundStyle(Pictogram.record.color)
                    .frame(width: 48, height: 48)

                VStack(alignment: .leading) {
                    Text(StatisticKind.personalBest.definition.title)
                        .font(.subheadline)
                        .lineLimit(1)
                        .foregroundStyle(.secondary)

                    Text(bestEntry.title)
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    HStack(spacing: 2) {
                        if let previous = bestEntry.previousBest {
                            let reading = Reading(rank: previous.rank, of: previous.exerciseKind)

                            Text(verbatim: reading.formatted(.reading(units: units)))
                                .font(.footnote)
                        }

                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 8))
                    }
                    .foregroundStyle(.secondary)
                    .baselineOffset(2)

                    let reading = Reading(rank: bestEntry.target.rank, of: bestEntry.target.exerciseKind)

                    Text(verbatim: reading.formatted(.reading(units: units)))
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            }
            .padding()
            .frame(maxHeight: .infinity)
            .background(Pictogram.record.color.quinary, in: .rect(cornerRadius: 16, style: .continuous))
        }
    }

    private var tint: Color {
        session.workout?.pictogram.color ?? Pictogram.workout.color
    }

    private var bestEntry: SessionEntry? {
        let ratio = { (entry: SessionEntry) in entry.previousBest.map { entry.target.rank / $0.rank } ?? 0 }
        return session.orderedEntries.filter(\.isBest).max { ratio($0) < ratio($1) }
    }
}

/// Renders only when actually shared, so the session is fetched again on the main actor by its identifier.
private struct SessionShareImage: Transferable {
    let name: String

    private let identifier: PersistentIdentifier

    private let container: ModelContainer?

    private let units: Units

    init(session: Session, units: Units) {
        self.name = "\(session.title), \(session.startDate.formatted(session.wallClockTime(date: .numeric)))"
        self.identifier = session.persistentModelID
        self.container = session.modelContext?.container
        self.units = units
    }

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { item in
            try await item.pngData()
        }
        .suggestedFileName {
            "\($0.name.replacing(/[\/:]/, with: "-")).png"
        }
    }

    @MainActor
    static func render(_ session: Session, units: Units) -> UIImage? {
        let renderer = ImageRenderer(
            content: SessionShareCard(session)
                .environment(\.colorScheme, .light)
                .environment(\.locale, .current)
                .environment(\.units, units)
        )
        renderer.scale = 3
        renderer.isOpaque = true
        return renderer.uiImage
    }

    @MainActor
    private func pngData() throws -> Data {
        guard
            let session = container?.mainContext.model(for: identifier) as? Session,
            let data = Self.render(session, units: units)?.pngData()
        else {
            throw CocoaError(.fileWriteUnknown)
        }

        return data
    }
}

#Preview("Rendered") {
    let sessions = (try? Samples.container.mainContext.fetch(Session.finishedDescriptor)) ?? []

    if let session = sessions.first, let image = SessionShareImage.render(session, units: .current) {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
    } else {
        Text(verbatim: "Render failed")
    }
}

#Preview("View") {
    SessionShareCard(Samples.sessions.first!)
}
