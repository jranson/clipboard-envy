//
//  AboutPage.swift
//  Clipboard Envy
//

import SwiftUI
import AppKit

struct AboutClipboardEnvyView: View {
    private static let windowTitle = "About \(AppIdentifier.name)"
    @State private var escapeMonitor: Any?
    @State private var isGitHubLinkHovered = false
    @State private var isAppStoreLinkHovered = false
    @State private var didCopyBuildInfo = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                Image("AppIconTransparent")
                    .resizable()
                    .frame(width: 56, height: 56)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Text(AppIdentifier.nameTM)
                            .font(.system(size: 30, weight: .semibold))

                        Text("v" + BuildInfo.version)
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                    }

                    Text(AppIdentifier.copyright)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
            }

            Text(
                "\(AppIdentifier.name) and the \(AppIdentifier.name) logo are trademarks of " +
                    "\(AppIdentifier.copyrightHolder)\nAll rights reserved."
            )
            .font(.system(size: 12))
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            Divider()

            Label("\(AppIdentifier.name) is 100% private. It does not snoop or collect analytics.", systemImage: "shield")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            Label("\(AppIdentifier.name) is written by humans with AI assistance.\nIt is completely free and open source for you to enjoy.", systemImage: "heart")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            Link(destination: AppIdentifier.repoURL) {
                Label("GitHub: \(AppIdentifier.repoPath)", systemImage: "arrow.up.right.square")
                    .foregroundStyle(Color(nsColor: .linkColor))
                    .underline(isGitHubLinkHovered, color: Color(nsColor: .linkColor).opacity(0.8))
            }
            .font(.system(size: 15))
            .onHover { isHovering in
                isGitHubLinkHovered = isHovering
            }

            buildInfoSection

            Label("\(AppIdentifier.name) is not a password manager and should not be used to store passwords or other secrets. Use a dedicated password manager like Apple Passwords for sensitive credentials.", systemImage: "exclamationmark.triangle")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            Divider()

            HStack(spacing: 12) {
                Link(destination: AppIdentifier.appleStoreReviewURL) {
                    Label("Rate on the Mac App Store", systemImage: "star.leadinghalf.filled")
                        .foregroundStyle(Color(nsColor: .linkColor))
                        .underline(isAppStoreLinkHovered, color: Color(nsColor: .linkColor).opacity(0.8))
                }
                .font(.system(size: 14))
                .onHover { isHovering in
                    isAppStoreLinkHovered = isHovering
                }
                Spacer()
                Button("Close") {
                    closeAboutWindow()
                }
                .font(.system(size: 15))
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .padding(.leading, 10)
        .frame(width: 540)
        .onKeyPress(.escape) {
            closeAboutWindow()
            return .handled
        }
        .onAppear {
            escapeMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                guard event.keyCode == 53 else { return event } // Escape
                guard NSApp.keyWindow?.title == Self.windowTitle else { return event }
                Task { @MainActor in closeAboutWindow() }
                return nil
            }
        }
        .onDisappear {
            if let m = escapeMonitor {
                NSEvent.removeMonitor(m)
                escapeMonitor = nil
            }
        }
    }

    private var buildInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Build info (copy for support)", systemImage: "doc.text")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)

            HStack(alignment: .top, spacing: 12) {
                Text(BuildInfo.copyableBlob)
                    .font(.system(size: 14, design: .monospaced))
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, minHeight: 84, alignment: .leading)
                Spacer()
                Button(didCopyBuildInfo ? "✓ Copied" : "Copy to Clipboard") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(BuildInfo.copyableBlob, forType: .string)
                    didCopyBuildInfo = true
                }
                .font(.system(size: 15))
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
                .padding(.top, 10)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 0)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }

    private func closeAboutWindow() {
        NSApp.windows.first { $0.title == Self.windowTitle }?.close()
    }
}

#Preview {
    AboutClipboardEnvyView()
        .frame(width: 540, height: 560)
}
