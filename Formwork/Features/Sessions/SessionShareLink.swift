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

    @State
    private var shareImage: SessionShareImage?

    init(_ session: Session) {
        self.session = session
    }

    var body: some View {
        Group {
            if let shareImage {
                ShareLink(
                    item: shareImage,
                    subject: Text(verbatim: shareImage.name),
                    message: Text(.shareMessage),
                    preview: SharePreview(shareImage.name, image: Image(uiImage: shareImage.image))
                ) {
                    label
                }
            } else {
                Button {} label: { label }
                    .disabled(true)
            }
        }
        .task(id: session.persistentModelID) {
            shareImage = SessionShareImage(session: session, units: units)
        }
    }

    private var label: some View {
        Label(.share)
    }
}

private struct SessionShareCard: View {
    let session: Session

    let tint: Color

    @Environment(\.units)
    private var units: Units

    init(session: Session) {
        self.session = session
        self.tint = session.workout?.pictogram.color ?? Pictogram.workout.color
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

                PictogramRow(session.pictogram, title: session.title, subtitle: session.startDate.formatted(session.wallClockTime(date: .numeric)))
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
                ReadingCard(kind, reading: kind.reading(of: session))
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
        let ratio = { (entry: SessionEntry) in entry.previousBest.map { entry.target.rank / $0.rank } ?? 0 }
        let personalBest = session.orderedEntries.filter(\.isBest).max { ratio($0) < ratio($1) }

        if let personalBest {
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

                    Text(personalBest.title)
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    HStack(spacing: 2) {
                        if let previous = personalBest.previousBest {
                            Text(verbatim: Reading(rank: previous.rank, of: previous.exerciseKind).formatted(.reading(units: units)))
                                .font(.footnote)
                        }

                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 8))
                    }
                    .foregroundStyle(.secondary)
                    .baselineOffset(2)

                    Text(verbatim: Reading(rank: personalBest.target.rank, of: personalBest.target.exerciseKind).formatted(.reading(units: units)))
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
}

private struct SessionShareImage: Transferable {
    let image: UIImage

    let name: String

    @MainActor
    init?(session: Session, units: Units) {
        guard let image = Self.renderShareImage(for: session, units: units) else {
            return nil
        }

        self.image = image
        self.name = "\(session.title), \(session.startDate.formatted(session.wallClockTime(date: .numeric)))"
    }

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { item in
            item.image.pngData() ?? Data()
        }
        .suggestedFileName {
            "\($0.name).png"
        }
    }

    @MainActor
    private static func renderShareImage(for session: Session, units: Units) -> UIImage? {
        let renderer = ImageRenderer(
            content: SessionShareCard(session: session)
                .environment(\.colorScheme, .light)
                .environment(\.locale, .current)
                .environment(\.units, units)
        )
        renderer.scale = 3
        renderer.isOpaque = true
        return renderer.uiImage
    }
}

#Preview("Rendered") {
    let sessions = (try? Samples.container.mainContext.fetch(Session.finishedDescriptor)) ?? []

    if let session = sessions.first, let shareImage = SessionShareImage(session: session, units: .current) {
        Image(uiImage: shareImage.image)
            .resizable()
            .scaledToFit()
    } else {
        Text(verbatim: "Render failed")
    }
}

#Preview("View") {
    SessionShareCard(session: Samples.sessions.first!)
}
