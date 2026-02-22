import Foundation

/// Fetches vehicle exterior photos from caranddriver.com by scraping the vehicle page
/// for image URLs hosted on the Hearst CDN (hips.hearstapps.com).
class CarAndDriverImageService {

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Fetches up to 2 exterior photo URLs for the given make and model.
    /// Returns an empty array if no photos are found or on any error.
    func fetchExteriorPhotos(make: String, model: String) async -> [URL] {
        guard let pageURL = buildURL(make: make, model: model) else { return [] }

        do {
            let (data, response) = try await session.data(from: pageURL)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let html = String(data: data, encoding: .utf8) else {
                return []
            }
            return parseImageURLs(from: html)
        } catch {
            return []
        }
    }

    // MARK: - URL Construction

    /// Builds the caranddriver.com URL for a given make and model.
    func buildURL(make: String, model: String) -> URL? {
        let makeSlug = slugify(make)
        let modelSlug = slugify(model)
        guard !makeSlug.isEmpty, !modelSlug.isEmpty else { return nil }
        return URL(string: "https://www.caranddriver.com/\(makeSlug)/\(modelSlug)/")
    }

    /// Converts a vehicle name component to a URL-friendly slug.
    func slugify(_ name: String) -> String {
        name.lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: ".", with: "-")
    }

    // MARK: - HTML Parsing

    /// Extracts up to 2 unique exterior photo URLs from the page HTML.
    func parseImageURLs(from html: String) -> [URL] {
        let pattern = #"https://hips\.hearstapps\.com/hmg-prod/images/[^\s"'<>]+"#

        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }

        let nsRange = NSRange(html.startIndex..., in: html)
        let matches = regex.matches(in: html, range: nsRange)

        var seenBaseURLs = Set<String>()
        var urls: [URL] = []

        for match in matches {
            guard let matchRange = Range(match.range, in: html) else { continue }
            var urlString = String(html[matchRange])

            // Clean trailing characters that may have been captured
            urlString = urlString.trimmingCharacters(in: CharacterSet(charactersIn: ");,"))

            let lower = urlString.lowercased()

            // Skip non-vehicle images
            if lower.contains("icon") || lower.contains("logo") || lower.contains("avatar") ||
               lower.contains("badge") || lower.contains("author") || lower.contains("headshot") {
                continue
            }

            // Extract base URL (without query parameters) for deduplication
            let baseURL = urlString.components(separatedBy: "?").first ?? urlString

            // Must end with an image file extension
            let baseLower = baseURL.lowercased()
            let hasImageExt = baseLower.hasSuffix(".jpg") || baseLower.hasSuffix(".jpeg") ||
                              baseLower.hasSuffix(".png") || baseLower.hasSuffix(".webp")
            guard hasImageExt else { continue }

            guard !seenBaseURLs.contains(baseURL) else { continue }
            seenBaseURLs.insert(baseURL)

            // Use the base URL with a consistent resize parameter
            if let url = URL(string: baseURL + "?resize=800:*") {
                urls.append(url)
            }

            if urls.count >= 2 { break }
        }

        return urls
    }
}
