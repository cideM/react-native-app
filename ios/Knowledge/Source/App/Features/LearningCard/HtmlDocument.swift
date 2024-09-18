//
//  HtmlDocument.swift
//  Knowledge
//
//  Created by CSH on 14.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain

struct HtmlDocument: Equatable {
    var headerElements: [String]
    var bodyElements: [String]

    var asHtml: String {
        """
        <html>
        <head>
        <meta charset="UTF-8">
        \(headerElements.joined(separator: "\n"))
        </head>
        <body>
        \(bodyElements.joined(separator: "\n"))
        </body>
        </html>
        """
    }

    var asData: Data? {
        asHtml.data(using: .utf8)
    }

    var asUnicodeData: Data? {
        asHtml.data(using: .unicode)
    }

    mutating func addHeaderTag(_ tag: Tag) {
        headerElements.append(tag.description)
    }

    mutating func setBodyTags(_ tags: [String]) {
        bodyElements = tags
    }
}

extension HtmlDocument {

    private static var defaultHeader: [String] = {
        let theme = ThemeManager.currentTheme
        // Using "handler.url" makes sure this will adpot automatically to any "scheme" name changes
        let handler = CommonBundleSchemeHandler.self
        let defaultFontURLString = handler.url(for: "\(theme.htmlDefaultFontName).ttf").absoluteString
        let headerFontURLString = handler.url(for: "\(theme.htmlHeaderFontName).ttf").absoluteString
        let subheaderFontURLString = handler.url(for: "\(theme.htmlSubHeaderFontName).ttf").absoluteString

        let defaultFont = (name: theme.htmlDefaultFontName, url: defaultFontURLString)
        let headerFont = (name: theme.htmlHeaderFontName, url: headerFontURLString)
        let subheaderFont = (name: theme.htmlSubHeaderFontName, url: subheaderFontURLString)

        let customCss =
            """
            @font-face {font-family: '\(defaultFont.name)'; src: url('\(defaultFont.url)')}
            @font-face {font-family: '\(headerFont.name)'; src: url('\(headerFont.url)')}
            @font-face {font-family: '\(subheaderFont.name)'; src: url('\(subheaderFont.url)')}
            body, p {font-family: '\(defaultFont.name)'}
            h1 {font-family: '\(headerFont.name)'}
            h2, h3, h4, h5, h6 {font-family: '\(subheaderFont.name)'}
            """

        return [
            // This is sometimes overriden in TableDetailViewController's WKNavigationDelegate!
            Tag.meta("viewport", "width=device-width").description,
            Tag.css(customCss).description
        ]
    }()

    static func termsDocument(body: String) -> HtmlDocument {
        var headerElements = defaultHeader.map { $0.description }

        let css = Tag.css("""
            h1 {
                font-size: 1.4em
            }
            @media (prefers-color-scheme: light) {
                html { background: #ffffff }
                h1 { color: #1a1c1c }
                p { color: #607585; }
                a { color: #047a88; }
            }
            @media (prefers-color-scheme: dark) {
                html { background: #1a1c1c }
                h1 { color: #ced1d6 }
                p { color: #93979f; }
                a { color: #2e9aa7; }
            }
        """)
        headerElements.append(css.description)

        return HtmlDocument(headerElements: headerElements, bodyElements: [body])
    }

    static func libraryDocument(body: String) -> HtmlDocument {
        var cssFile = Tag.cssFile("/css/mobile.css")
        var jsFile = Tag.jsFile("/js/mobile.js")

        #if Debug || QA
        if let (_, css, js) = ArchiveQAPlugin.urls {
            cssFile = Tag.cssFile(css.description)
            jsFile = Tag.jsFile(js.description)
        }
        #endif

        var headerElements = defaultHeader.map { $0.description }

        headerElements.append(contentsOf: [
            jsFile.description,
            cssFile.description,
            Tag.jsFile("/js/jquery.js").description
        ])

        return HtmlDocument(headerElements: headerElements, bodyElements: [body])
    }
}

extension HtmlDocument {
    enum Tag: CustomStringConvertible {
        case raw(_ string: String)
        case meta(_ name: String, _ content: String)
        case cssFile(_ path: String)
        case jsFile(_ path: String)
        case css(_ value: String)

        var description: String {
            switch self {
            case .raw(let string): return string
            case .cssFile(let path): return "<link rel=\"stylesheet\" type=\"text/css\" href=\"\(path)\" />"
            case .jsFile(let path): return "<script type=\" text/javascript\" src=\"\(path)\"></script>"
            case .css(let value): return "<style type=\"text/css\">\(value)</style>"
            case .meta(let name, let content): return "<meta name=\"\(name)\" content=\"\(content)\">"
            }
        }
    }
}
