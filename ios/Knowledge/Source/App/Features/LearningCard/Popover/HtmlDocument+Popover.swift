//
//  HtmlDocument+Popover.swift
//  Knowledge DE
//
//  Created by CSH on 03.07.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import UIKit
import DesignSystem
import Common

extension HtmlDocument {
    enum AdditionalPopoverCss {
        // "padding-bottom" was initially "48px" which lead to quite large and odd looking bottom margins ...
        // It is now 16px to make it look less odd but can not be zero since the content size calculation
        // via HTMLContentSizeCalculator is not reliable and sometimes clips the last line
        // Hence we add approximately a line of space to be on the save side ...
        // padding-bottom: (line-height - font-height) / 2 + font-height => 21px
        static var textOnly: String { // can not be "static let" cause user might switch to light/dark mode
            """
            root {
                color-scheme: light dark;
            }
            @media (prefers-color-scheme: light) {
                :root {
                    --themeColorTextPrimary:\(UIColor.textPrimary.cssRGBA(style: .light));
                    --themeColorBackgroundPrimary:\(UIColor.backgroundPrimary.cssRGBA(style: .light));
                }
            }

            @media (prefers-color-scheme: dark) {
                :root {
                   --themeColorTextPrimary:\(UIColor.textPrimary.cssRGBA(style: .dark));
                    --themeColorBackgroundPrimary:\(UIColor.backgroundPrimary.cssRGBA(style: .dark));
                }
            }
                /* Body styling */
                body { line-height: 26px; font-weight: 400; font-size: 16px; color: var(--themeColorTextPrimary); padding-left: 24px; padding-top: 16px; padding-right: 24px; padding-bottom: 21px; background-color:var(--themeColorBackgroundPrimary);}

                .nowrap {
                    white-space: nowrap;
                }

                /* External link styling */
                span[data-type="link"] {
                  border-bottom: 1px solid rgb(201, 204, 206) ;
                }

                /* Internal link styling */
                span[data-type="link"].link--internal {
                    border-bottom: 1px dotted rgb(201, 204, 206) ;
                }

                /* Inline references styling */
                a {
                    color:var(--themeColorTextPrimary);
                }
                a:after {
                    margin-left: 3px;
                    content: url(data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxNiIgaGVpZ2h0PSIxNiIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9InJnYigxNTMsIDE2NywgMTc5KSIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGNsYXNzPSJmZWF0aGVyIGZlYXRoZXItZXh0ZXJuYWwtbGluayI+PHBhdGggZD0iTTE4IDEzdjZhMiAyIDAgMCAxLTIgMkg1YTIgMiAwIDAgMS0yLTJWOGEyIDIgMCAwIDEgMi0yaDYiPjwvcGF0aD48cG9seWxpbmUgcG9pbnRzPSIxNSAzIDIxIDMgMjEgOSI+PC9wb2x5bGluZT48bGluZSB4MT0iMTAiIHkxPSIxNCIgeDI9IjIxIiB5Mj0iMyI+PC9saW5lPjwvc3ZnPgo=)
                }
            """
        }

        // can not be "static let" cause user might switch to light/dark mode
        static var imagesOnly: String {
            """
                        root {
                            color-scheme: light dark;
                        }
                        @media (prefers-color-scheme: light) {
                            :root {
                                --themeColorBackgroundPrimary:\(UIColor.backgroundPrimary.cssRGBA(style: .light));
                            }
                        }

                        @media (prefers-color-scheme: dark) {
                            :root {
                                --themeColorBackgroundPrimary:\(UIColor.backgroundPrimary.cssRGBA(style: .dark));
                            }
                        }

                /* Body styling */
                body { padding-left: 27px; padding-top: 32px; padding-right: 27px; padding-bottom: 44px; background-color:var(--themeColorBackgroundPrimary); }

                /* Image styling */
                img {
                  border-color: rgba(26, 28, 28, 0.1);
                  border-style: solid;
                  border-width: 1px;
                  display: block;
                  margin-left: auto;
                  margin-right: auto;
                  border-radius: 8px;
                  width: 96px;
                  height: 96px;
                  -webkit-tap-highlight-color: rgba(0, 0, 0, 0);
                }

                span[data-type="image"]::after {
                  position: absolute;
                  bottom: 0px;
                  right: 0px;
                  padding: 5px;
                  background-color: transparent;
                  border-radius: 8px 0px;
                  margin: 2px;
                  content: url(data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTciIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNyAxNiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTE0LjUgMkw5LjUgNyIgc3Ryb2tlPSIjNDA1MTVFIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz4KPHBhdGggZD0iTTIuNSAxNEw3LjUgOSIgc3Ryb2tlPSIjNDA1MTVFIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz4KPHBhdGggZD0iTTEwLjUgMkgxNC41VjYiIHN0cm9rZT0iIzQwNTE1RSIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz4KPHBhdGggZD0iTTYuNSAxNEgyLjVWMTAiIHN0cm9rZT0iIzQwNTE1RSIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz4KPC9zdmc+Cg==)

                }

                .modal-tooltip, .step-1-imppact2, .step-2-imppact2, .imppact2, .usmle-gs-imppact2, .step-1-condensed, .step-2-condensed {
                  display: flex;
                  justify-content: center;
                  flex-wrap: wrap;
                  gap: 16px;
                }

                span[data-type="image"] {
                  position: relative;
                }
            """
        }
    }

    static func popoverDocument(_ popover: String) -> HtmlDocument {

        let adjustedHTML = Self.adustTextColor(htmlString: popover)

        let wrappedBody = "<div class='api overlay' data-type='overlay'><div class='modal-tooltip'>"
            + adjustedHTML
            + "</div></div>"
        var document = HtmlDocument.libraryDocument(body: wrappedBody)
        document.addHeaderTag(.meta("viewport", "width=device-width shrink-to-fit='YES' initial-scale='1.0' maximum-scale='1.0' minimum-scale='1.0' user-scalable='no'"))

        if adjustedHTML.contains("<img") {
            document.addHeaderTag(.css(AdditionalPopoverCss.imagesOnly))
        } else {
            document.addHeaderTag(.css(AdditionalPopoverCss.textOnly))
        }

        return document
    }

    // The color token here comes directly from the bridge via BASE64 we need to change the color
    // Somewhere in the library. As a quick workaround we remove the color string and default to system.
    private static func adustTextColor(htmlString: String) -> String {
       htmlString.replacingOccurrences(of: "color: #999;", with: "")
    }
}
