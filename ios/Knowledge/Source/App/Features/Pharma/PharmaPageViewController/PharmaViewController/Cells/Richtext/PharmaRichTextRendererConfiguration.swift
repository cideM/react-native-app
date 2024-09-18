//
//  PharmaRichTextRendererConfiguration.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 08.02.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common
import RichTextRenderer
import DesignSystem

final class PharmaRichTextRendererConfiguration: RendererConfiguration {
    let fontProvider: FontProviding = PharmaRichTextFontProvider()
    let contentInsets: UIEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
    let textConfiguration = TextConfiguration(fontColor: .textPrimary, paragraphSpacing: 0, lineSpacing: 5)
    let blockQuote: BlockQuoteConfiguration = .default
    let textList: TextListConfiguration = .default
    let horizontalRuleViewProvider: HorizontalRuleViewProviding = HorizontalRuleViewProvider()
    let backgroundColor = UIColor.backgroundPrimary

    final class PharmaRichTextFontProvider: FontProviding {
        let regular = TextStyle.paragraph.typography.font()
        let bold = TextStyle.paragraphBold.typography.font()
        let italic = TextStyle.paragraph.typography.font()
        let boldItalic = TextStyle.paragraphBold.typography.font()
        let headingFonts = HeadingFonts(h1: TextStyle.h1.typography.font(),
                                        h2: TextStyle.h2.typography.font(),
                                        h3: TextStyle.h3.typography.font(),
                                        h4: TextStyle.h4.typography.font(),
                                        h5: TextStyle.h5.typography.font(),
                                        h6: TextStyle.h6.typography.font())
        let monospaced = TextStyle.paragraph.typography.font()
    }
}
