require "mechanize"

module TrademarkScraper
  TOP_URL = "https://www.j-platpat.inpit.go.jp/web/all/top/BTmTopPage"
  SEARCHED_ATTRIBUTES = %i{search_index none id name segments applicant applied_at registrated_at graphic status}

  def get_searched_elements(keyword)
    agent = Mechanize.new
    agent.user_agent_alias = 'Mac Mozilla'

    page = agent.get(TOP_URL)

    # キーワード検索
    result_page = page.form_with(:name => "searchForm") do |form|
      form.action = '/web/all/top/BTmTopSearchPage.action'
      sess_id = page.search("#jplatpatSession").first.text
      form.field_with(:name => 'bTmFCOMDTO.searchKeyword').value = keyword
      form.field_with(:name => 'bTmFCOMDTO.searchValue').value = "4"
      form.field_with(:name => 'bTmFCOMDTO.enzanShiValue').value = "1"
      form.add_field!('jplatpatSession', sess_id)
    end.submit()

    result_count = result_page.search(".searchbox-result-count").text.gsub("件", "").to_i

    # ap "----"
    # ap "検索件数: #{result_count} 件"
    return if result_count == 0

    list_page = result_page.form_with(:name => 'syouhyouLink').submit()

    extract_elements(list_page)
  end

  def extract_elements(page)
    elements = page.search(".table-result > tbody > tr").map do |tr|
      strip_from_elements(tr.search("td"))
    end
    # ap "#{elements.size} 件取得中..."
    url = get_pagination_link(page)
    return elements if url.nil?
    [elements, extract_elements(page.mech.get(url))].flatten
  end

  def get_pagination_link(page)
    a = page.search("li.pagination-link.icon-next a").first
    return if a.nil?
    a.attributes["href"].value
  end

  def strip_from_elements(elements)
    pair_list = SEARCHED_ATTRIBUTES.map.with_index do |attr, i|
      # 余白削除、全角→半角
      value = elements[i].text.strip.tr('０-９ａ-ｚＡ-Ｚ　', '0-9a-zA-Z ')
      [attr, value]
    end
    Hash[pair_list]
  end
end
