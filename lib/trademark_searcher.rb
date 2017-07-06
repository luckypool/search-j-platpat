require "./lib/trademark_scraper"
require "./lib/trademark_sercher/result"

class TrademarkSearcher
  extend TrademarkScraper

  def self.search_by(keyword)
    elements = get_searched_elements(keyword)
    return if elements.nil?
    elements.map { |e| Result.new(e) }
  end
end
