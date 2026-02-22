import XCTest
@testable import Fleet

final class CarAndDriverImageServiceTests: XCTestCase {

    let service = CarAndDriverImageService()

    // MARK: - slugify

    func testSlugifyLowercasesMake() {
        XCTAssertEqual(service.slugify("Toyota"), "toyota")
    }

    func testSlugifyReplacesSpacesWithHyphens() {
        XCTAssertEqual(service.slugify("Land Rover"), "land-rover")
    }

    func testSlugifyPreservesExistingHyphens() {
        XCTAssertEqual(service.slugify("Mercedes-Benz"), "mercedes-benz")
    }

    func testSlugifyReplacesPeriodsWithHyphens() {
        XCTAssertEqual(service.slugify("ID.4"), "id-4")
    }

    func testSlugifyAllUppercase() {
        XCTAssertEqual(service.slugify("BMW"), "bmw")
    }

    func testSlugifyAlreadyLowercase() {
        XCTAssertEqual(service.slugify("smart"), "smart")
    }

    func testSlugifyEmpty() {
        XCTAssertEqual(service.slugify(""), "")
    }

    func testSlugifyModelWithNumber() {
        XCTAssertEqual(service.slugify("Model 3"), "model-3")
    }

    func testSlugifyModelWithHyphenAndNumber() {
        XCTAssertEqual(service.slugify("F-150"), "f-150")
    }

    func testSlugifyModelCRV() {
        XCTAssertEqual(service.slugify("CR-V"), "cr-v")
    }

    func testSlugifySeries() {
        XCTAssertEqual(service.slugify("3 Series"), "3-series")
    }

    // MARK: - buildURL

    func testBuildURLBasicMakeModel() {
        let url = service.buildURL(make: "Toyota", model: "Camry")
        XCTAssertEqual(url?.absoluteString, "https://www.caranddriver.com/toyota/camry/")
    }

    func testBuildURLWithSpaces() {
        let url = service.buildURL(make: "Land Rover", model: "Range Rover")
        XCTAssertEqual(url?.absoluteString, "https://www.caranddriver.com/land-rover/range-rover/")
    }

    func testBuildURLWithHyphens() {
        let url = service.buildURL(make: "Mercedes-Benz", model: "C-Class")
        XCTAssertEqual(url?.absoluteString, "https://www.caranddriver.com/mercedes-benz/c-class/")
    }

    func testBuildURLEmptyMakeReturnsNil() {
        XCTAssertNil(service.buildURL(make: "", model: "Camry"))
    }

    func testBuildURLEmptyModelReturnsNil() {
        XCTAssertNil(service.buildURL(make: "Toyota", model: ""))
    }

    func testBuildURLBothEmptyReturnsNil() {
        XCTAssertNil(service.buildURL(make: "", model: ""))
    }

    func testBuildURLTeslaModel3() {
        let url = service.buildURL(make: "Tesla", model: "Model 3")
        XCTAssertEqual(url?.absoluteString, "https://www.caranddriver.com/tesla/model-3/")
    }

    func testBuildURLFordF150() {
        let url = service.buildURL(make: "Ford", model: "F-150")
        XCTAssertEqual(url?.absoluteString, "https://www.caranddriver.com/ford/f-150/")
    }

    // MARK: - parseImageURLs

    func testParseFindsImageURLsFromSrcAttributes() {
        let html = """
        <html><body>
        <img src="https://hips.hearstapps.com/hmg-prod/images/2024-toyota-camry-front.jpg?resize=600:*">
        <img src="https://hips.hearstapps.com/hmg-prod/images/2024-toyota-camry-rear.jpg?crop=1xw:1xh">
        </body></html>
        """
        let urls = service.parseImageURLs(from: html)
        XCTAssertEqual(urls.count, 2)
        XCTAssertTrue(urls[0].absoluteString.contains("front"))
        XCTAssertTrue(urls[1].absoluteString.contains("rear"))
    }

    func testParseAddsResizeParameter() {
        let html = """
        <img src="https://hips.hearstapps.com/hmg-prod/images/car-photo.jpg?resize=300:*">
        """
        let urls = service.parseImageURLs(from: html)
        XCTAssertEqual(urls.count, 1)
        XCTAssertTrue(urls[0].absoluteString.contains("resize=800"))
        XCTAssertFalse(urls[0].absoluteString.contains("resize=300"))
    }

    func testParseSkipsIconImages() {
        let html = """
        <img src="https://hips.hearstapps.com/hmg-prod/images/nav-icon-small.jpg">
        <img src="https://hips.hearstapps.com/hmg-prod/images/2024-camry.jpg">
        """
        let urls = service.parseImageURLs(from: html)
        XCTAssertEqual(urls.count, 1)
        XCTAssertTrue(urls[0].absoluteString.contains("camry"))
    }

    func testParseSkipsLogoImages() {
        let html = """
        <img src="https://hips.hearstapps.com/hmg-prod/images/company-logo.png">
        <img src="https://hips.hearstapps.com/hmg-prod/images/civic-side.jpg">
        """
        let urls = service.parseImageURLs(from: html)
        XCTAssertEqual(urls.count, 1)
        XCTAssertTrue(urls[0].absoluteString.contains("civic"))
    }

    func testParseSkipsAvatarImages() {
        let html = """
        <img src="https://hips.hearstapps.com/hmg-prod/images/staff-avatar.jpg">
        <img src="https://hips.hearstapps.com/hmg-prod/images/mustang-front.jpg">
        """
        let urls = service.parseImageURLs(from: html)
        XCTAssertEqual(urls.count, 1)
        XCTAssertTrue(urls[0].absoluteString.contains("mustang"))
    }

    func testParseSkipsAuthorImages() {
        let html = """
        <img src="https://hips.hearstapps.com/hmg-prod/images/author-profile.jpg">
        <img src="https://hips.hearstapps.com/hmg-prod/images/bronco-exterior.jpg">
        """
        let urls = service.parseImageURLs(from: html)
        XCTAssertEqual(urls.count, 1)
    }

    func testParseDeduplicatesSameBaseURL() {
        let html = """
        <img src="https://hips.hearstapps.com/hmg-prod/images/car.jpg?resize=300:*">
        <img src="https://hips.hearstapps.com/hmg-prod/images/car.jpg?resize=600:*">
        <img src="https://hips.hearstapps.com/hmg-prod/images/car.jpg?crop=1xw">
        """
        let urls = service.parseImageURLs(from: html)
        XCTAssertEqual(urls.count, 1)
    }

    func testParseLimitsToTwoImages() {
        let html = """
        <img src="https://hips.hearstapps.com/hmg-prod/images/car1.jpg">
        <img src="https://hips.hearstapps.com/hmg-prod/images/car2.jpg">
        <img src="https://hips.hearstapps.com/hmg-prod/images/car3.jpg">
        <img src="https://hips.hearstapps.com/hmg-prod/images/car4.jpg">
        """
        let urls = service.parseImageURLs(from: html)
        XCTAssertEqual(urls.count, 2)
    }

    func testParseReturnsEmptyForNoHTML() {
        let urls = service.parseImageURLs(from: "")
        XCTAssertTrue(urls.isEmpty)
    }

    func testParseReturnsEmptyForNoMatchingImages() {
        let html = """
        <img src="https://example.com/photo.jpg">
        <img src="https://cdn.other.com/image.png">
        """
        let urls = service.parseImageURLs(from: html)
        XCTAssertTrue(urls.isEmpty)
    }

    func testParseSkipsNonImageExtensions() {
        let html = """
        <script src="https://hips.hearstapps.com/hmg-prod/images/script.js"></script>
        <link href="https://hips.hearstapps.com/hmg-prod/images/style.css">
        <img src="https://hips.hearstapps.com/hmg-prod/images/vehicle.jpg">
        """
        let urls = service.parseImageURLs(from: html)
        XCTAssertEqual(urls.count, 1)
        XCTAssertTrue(urls[0].absoluteString.contains("vehicle"))
    }

    func testParseHandlesWebpExtension() {
        let html = """
        <img src="https://hips.hearstapps.com/hmg-prod/images/car-photo.webp">
        """
        let urls = service.parseImageURLs(from: html)
        XCTAssertEqual(urls.count, 1)
    }

    func testParseHandlesPngExtension() {
        let html = """
        <img src="https://hips.hearstapps.com/hmg-prod/images/car-render.png">
        """
        let urls = service.parseImageURLs(from: html)
        XCTAssertEqual(urls.count, 1)
    }

    func testParseHandlesJpegExtension() {
        let html = """
        <img src="https://hips.hearstapps.com/hmg-prod/images/exterior.jpeg">
        """
        let urls = service.parseImageURLs(from: html)
        XCTAssertEqual(urls.count, 1)
    }

    func testParseHandlesOGMetaContent() {
        let html = """
        <meta property="og:image" content="https://hips.hearstapps.com/hmg-prod/images/og-image-car.jpg?resize=1200:*">
        """
        let urls = service.parseImageURLs(from: html)
        XCTAssertEqual(urls.count, 1)
        XCTAssertTrue(urls[0].absoluteString.contains("og-image-car"))
    }

    func testParseSkipsBadgeImages() {
        let html = """
        <img src="https://hips.hearstapps.com/hmg-prod/images/award-badge.jpg">
        <img src="https://hips.hearstapps.com/hmg-prod/images/sedan-view.jpg">
        """
        let urls = service.parseImageURLs(from: html)
        XCTAssertEqual(urls.count, 1)
        XCTAssertTrue(urls[0].absoluteString.contains("sedan"))
    }

    func testParseHandlesURLsWithoutQueryParams() {
        let html = """
        <img src="https://hips.hearstapps.com/hmg-prod/images/clean-url.jpg">
        """
        let urls = service.parseImageURLs(from: html)
        XCTAssertEqual(urls.count, 1)
        // Should still add resize parameter
        XCTAssertTrue(urls[0].absoluteString.hasSuffix("resize=800:*"))
    }

    func testParseReturnsValidURLs() {
        let html = """
        <img src="https://hips.hearstapps.com/hmg-prod/images/photo-a.jpg">
        <img src="https://hips.hearstapps.com/hmg-prod/images/photo-b.jpg">
        """
        let urls = service.parseImageURLs(from: html)
        for url in urls {
            XCTAssertNotNil(URL(string: url.absoluteString))
        }
    }
}
