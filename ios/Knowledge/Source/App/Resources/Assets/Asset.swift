// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
public typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
public typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum Asset {
  public static let cmeStamp = ImageAsset(name: "CMEStamp")
  public static let launchScreenBackground = ColorAsset(name: "LaunchScreenBackground")
  public static let ahfsLogo = ImageAsset(name: "ahfs-logo")
  public static let ambossLogo = ImageAsset(name: "amboss-logo")
  public static let article = ImageAsset(name: "article")
  public static let closeButton = ImageAsset(name: "closeButton")
  public static let doctors = ImageAsset(name: "doctors")
  public static let externalLink = ImageAsset(name: "external-link")
  public static let fileText = ImageAsset(name: "file-text")
  public enum Icon {
    public static let index = ImageAsset(name: "icon/Index")
    public static let arrowRight16 = ImageAsset(name: "icon/arrow-right-16")
    public static let arrowRight = ImageAsset(name: "icon/arrow-right")
    public static let back = ImageAsset(name: "icon/back")
    public static let bold = ImageAsset(name: "icon/bold")
    public static let bookmark = ImageAsset(name: "icon/bookmark")
    public static let calculators = ImageAsset(name: "icon/calculators")
    public static let checkSquare = ImageAsset(name: "icon/check-square")
    public static let chevronRight = ImageAsset(name: "icon/chevron-right")
    public static let chevronUp = ImageAsset(name: "icon/chevron-up")
    public static let closeAllSections = ImageAsset(name: "icon/close-all-sections")
    public static let crossSmall = ImageAsset(name: "icon/cross-small")
    public static let dashboard = ImageAsset(name: "icon/dashboard")
    public static let disclosureArrow = ImageAsset(name: "icon/disclosure-arrow")
    public static let drugListIcon = ImageAsset(name: "icon/drugListIcon")
    public static let ellipsis = ImageAsset(name: "icon/ellipsis")
    public static let favoriteFilled = ImageAsset(name: "icon/favorite-filled")
    public static let favorite = ImageAsset(name: "icon/favorite")
    public enum Feature {
      public static let `default` = ImageAsset(name: "icon/feature/default")
      public static let easyradiology = ImageAsset(name: "icon/feature/easyradiology")
      public static let meditricks = ImageAsset(name: "icon/feature/meditricks")
      public static let smartzoom = ImageAsset(name: "icon/feature/smartzoom")
    }
    public static let flowcharts = ImageAsset(name: "icon/flowcharts")
    public static let historyNext = ImageAsset(name: "icon/historyNext")
    public static let historyPrevious = ImageAsset(name: "icon/historyPrevious")
    public static let imageDescription = ImageAsset(name: "icon/image-description")
    public static let imageOverlay = ImageAsset(name: "icon/image-overlay")
    public static let inArticleSearchNext = ImageAsset(name: "icon/in-article-search-next")
    public static let inArticleSearchPrevious = ImageAsset(name: "icon/in-article-search-previous")
    public static let inArticleSearch = ImageAsset(name: "icon/in-article-search")
    public static let infoIcon = ImageAsset(name: "icon/infoIcon")
    public static let italic = ImageAsset(name: "icon/italic")
    public static let layers = ImageAsset(name: "icon/layers")
    public static let learnCheck = ImageAsset(name: "icon/learnCheck")
    public static let learnCircle = ImageAsset(name: "icon/learnCircle")
    public static let learned = ImageAsset(name: "icon/learned")
    public static let library = ImageAsset(name: "icon/library")
    public enum Lists {
      public static let favorite = ImageAsset(name: "icon/lists/favorite")
      public static let learned = ImageAsset(name: "icon/lists/learned")
      public static let notes = ImageAsset(name: "icon/lists/notes")
      public static let recent = ImageAsset(name: "icon/lists/recent")
    }
    public static let mediaBroken = ImageAsset(name: "icon/media-broken")
    public static let media = ImageAsset(name: "icon/media")
    public enum MediaTypes {
      public static let auditor = ImageAsset(name: "icon/auditor")
      public static let box = ImageAsset(name: "icon/box")
      public static let calculator = ImageAsset(name: "icon/calculator")
      public static let chart = ImageAsset(name: "icon/chart")
      public static let film = ImageAsset(name: "icon/film")
      public static let flowchart = ImageAsset(name: "icon/flowchart")
      public static let headphones = ImageAsset(name: "icon/headphones")
      public static let illustration = ImageAsset(name: "icon/illustration")
      public static let image = ImageAsset(name: "icon/image")
      public static let imaging = ImageAsset(name: "icon/imaging")
      public static let link = ImageAsset(name: "icon/link")
      public static let microscope = ImageAsset(name: "icon/microscope")
      public static let users = ImageAsset(name: "icon/users")
    }
    public static let midiSearch = ImageAsset(name: "icon/midi-search")
    public static let minimapCircle = ImageAsset(name: "icon/minimap-circle")
    public static let minimap = ImageAsset(name: "icon/minimap")
    public static let more = ImageAsset(name: "icon/more")
    public static let openAllSections = ImageAsset(name: "icon/open-all-sections")
    public static let orderedList = ImageAsset(name: "icon/orderedList")
    public static let pharmaExpandableSectionHeader = ImageAsset(name: "icon/pharma-expandable-section-header")
    public static let pillIcon = ImageAsset(name: "icon/pill-icon")
    public static let questionSession = ImageAsset(name: "icon/questionSession")
    public static let redo = ImageAsset(name: "icon/redo")
    public static let searchHistory = ImageAsset(name: "icon/search-history")
    public static let searchList = ImageAsset(name: "icon/search-list")
    public static let search = ImageAsset(name: "icon/search")
    public static let send = ImageAsset(name: "icon/send")
    public static let settings = ImageAsset(name: "icon/settings")
    public static let share = ImageAsset(name: "icon/share")
    public static let thumbsDown = ImageAsset(name: "icon/thumbsDown")
    public static let thumbsUp = ImageAsset(name: "icon/thumbsUp")
    public static let tinySearch = ImageAsset(name: "icon/tiny-search")
    public static let underline = ImageAsset(name: "icon/underline")
    public static let undo = ImageAsset(name: "icon/undo")
    public static let unorderedList = ImageAsset(name: "icon/unorderedList")
    public static let wifiOff = ImageAsset(name: "icon/wifi-off")
    public static let xCircle = ImageAsset(name: "icon/x-circle")
  }
  public static let ifapLogo = ImageAsset(name: "ifap-logo")
  public enum Image {
    public static let coffeeCup = ImageAsset(name: "image/coffee-cup")
  }
  public static let launchscreenImage = ImageAsset(name: "launchscreen-image")
  public static let learningCard = ImageAsset(name: "learningCard")
  public static let libraryInstallationArt = ImageAsset(name: "library-installation-art")
  public static let librarySettings = ImageAsset(name: "library-settings")
  public enum LogoAnimation {
    public static let refreshAnimationFrame0 = ImageAsset(name: "RefreshAnimationFrame_0")
    public static let refreshAnimationFrame1 = ImageAsset(name: "RefreshAnimationFrame_1")
    public static let refreshAnimationFrame10 = ImageAsset(name: "RefreshAnimationFrame_10")
    public static let refreshAnimationFrame11 = ImageAsset(name: "RefreshAnimationFrame_11")
    public static let refreshAnimationFrame12 = ImageAsset(name: "RefreshAnimationFrame_12")
    public static let refreshAnimationFrame13 = ImageAsset(name: "RefreshAnimationFrame_13")
    public static let refreshAnimationFrame14 = ImageAsset(name: "RefreshAnimationFrame_14")
    public static let refreshAnimationFrame15 = ImageAsset(name: "RefreshAnimationFrame_15")
    public static let refreshAnimationFrame16 = ImageAsset(name: "RefreshAnimationFrame_16")
    public static let refreshAnimationFrame17 = ImageAsset(name: "RefreshAnimationFrame_17")
    public static let refreshAnimationFrame18 = ImageAsset(name: "RefreshAnimationFrame_18")
    public static let refreshAnimationFrame19 = ImageAsset(name: "RefreshAnimationFrame_19")
    public static let refreshAnimationFrame2 = ImageAsset(name: "RefreshAnimationFrame_2")
    public static let refreshAnimationFrame20 = ImageAsset(name: "RefreshAnimationFrame_20")
    public static let refreshAnimationFrame21 = ImageAsset(name: "RefreshAnimationFrame_21")
    public static let refreshAnimationFrame3 = ImageAsset(name: "RefreshAnimationFrame_3")
    public static let refreshAnimationFrame4 = ImageAsset(name: "RefreshAnimationFrame_4")
    public static let refreshAnimationFrame5 = ImageAsset(name: "RefreshAnimationFrame_5")
    public static let refreshAnimationFrame6 = ImageAsset(name: "RefreshAnimationFrame_6")
    public static let refreshAnimationFrame7 = ImageAsset(name: "RefreshAnimationFrame_7")
    public static let refreshAnimationFrame8 = ImageAsset(name: "RefreshAnimationFrame_8")
    public static let refreshAnimationFrame9 = ImageAsset(name: "RefreshAnimationFrame_9")
  }
  public static let subtreeFolder = ImageAsset(name: "subtreeFolder")

  // swiftlint:disable trailing_comma
  public static let allColors: [ColorAsset] = [
    launchScreenBackground,
  ]
  public static let allImages: [ImageAsset] = [
    cmeStamp,
    ahfsLogo,
    ambossLogo,
    article,
    closeButton,
    doctors,
    externalLink,
    fileText,
    Icon.index,
    Icon.arrowRight16,
    Icon.arrowRight,
    Icon.back,
    Icon.bold,
    Icon.bookmark,
    Icon.calculators,
    Icon.checkSquare,
    Icon.chevronRight,
    Icon.chevronUp,
    Icon.closeAllSections,
    Icon.crossSmall,
    Icon.dashboard,
    Icon.disclosureArrow,
    Icon.drugListIcon,
    Icon.ellipsis,
    Icon.favoriteFilled,
    Icon.favorite,
    Icon.Feature.`default`,
    Icon.Feature.easyradiology,
    Icon.Feature.meditricks,
    Icon.Feature.smartzoom,
    Icon.flowcharts,
    Icon.historyNext,
    Icon.historyPrevious,
    Icon.imageDescription,
    Icon.imageOverlay,
    Icon.inArticleSearchNext,
    Icon.inArticleSearchPrevious,
    Icon.inArticleSearch,
    Icon.infoIcon,
    Icon.italic,
    Icon.layers,
    Icon.learnCheck,
    Icon.learnCircle,
    Icon.learned,
    Icon.library,
    Icon.Lists.favorite,
    Icon.Lists.learned,
    Icon.Lists.notes,
    Icon.Lists.recent,
    Icon.mediaBroken,
    Icon.media,
    Icon.MediaTypes.auditor,
    Icon.MediaTypes.box,
    Icon.MediaTypes.calculator,
    Icon.MediaTypes.chart,
    Icon.MediaTypes.film,
    Icon.MediaTypes.flowchart,
    Icon.MediaTypes.headphones,
    Icon.MediaTypes.illustration,
    Icon.MediaTypes.image,
    Icon.MediaTypes.imaging,
    Icon.MediaTypes.link,
    Icon.MediaTypes.microscope,
    Icon.MediaTypes.users,
    Icon.midiSearch,
    Icon.minimapCircle,
    Icon.minimap,
    Icon.more,
    Icon.openAllSections,
    Icon.orderedList,
    Icon.pharmaExpandableSectionHeader,
    Icon.pillIcon,
    Icon.questionSession,
    Icon.redo,
    Icon.searchHistory,
    Icon.searchList,
    Icon.search,
    Icon.send,
    Icon.settings,
    Icon.share,
    Icon.thumbsDown,
    Icon.thumbsUp,
    Icon.tinySearch,
    Icon.underline,
    Icon.undo,
    Icon.unorderedList,
    Icon.wifiOff,
    Icon.xCircle,
    ifapLogo,
    Image.coffeeCup,
    launchscreenImage,
    learningCard,
    libraryInstallationArt,
    librarySettings,
    LogoAnimation.refreshAnimationFrame0,
    LogoAnimation.refreshAnimationFrame1,
    LogoAnimation.refreshAnimationFrame10,
    LogoAnimation.refreshAnimationFrame11,
    LogoAnimation.refreshAnimationFrame12,
    LogoAnimation.refreshAnimationFrame13,
    LogoAnimation.refreshAnimationFrame14,
    LogoAnimation.refreshAnimationFrame15,
    LogoAnimation.refreshAnimationFrame16,
    LogoAnimation.refreshAnimationFrame17,
    LogoAnimation.refreshAnimationFrame18,
    LogoAnimation.refreshAnimationFrame19,
    LogoAnimation.refreshAnimationFrame2,
    LogoAnimation.refreshAnimationFrame20,
    LogoAnimation.refreshAnimationFrame21,
    LogoAnimation.refreshAnimationFrame3,
    LogoAnimation.refreshAnimationFrame4,
    LogoAnimation.refreshAnimationFrame5,
    LogoAnimation.refreshAnimationFrame6,
    LogoAnimation.refreshAnimationFrame7,
    LogoAnimation.refreshAnimationFrame8,
    LogoAnimation.refreshAnimationFrame9,
    subtreeFolder,
  ]
  // swiftlint:enable trailing_comma
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public final class ColorAsset {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  public private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  public func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleToken.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

public extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

public struct ImageAsset {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  public var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  public func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif
}

public extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
