#!/bin/env ruby
# encoding: utf-8

require "mechanize"
require "ap"
require "pry-byebug"

TOP_URL = "https://www.j-platpat.inpit.go.jp/web/all/top/BTmTopPage"


def scrape(keyword)
  agent = Mechanize.new
  agent.user_agent_alias = 'Mac Mozilla'

  page = agent.get(TOP_URL)

  # キーワード検索
  page = page.form_with(:name => "searchForm") do |form|
    form.action = '/web/all/top/BTmTopSearchPage.action'
    sess_id = page.search("#jplatpatSession").first.text
    form.field_with(:name => 'bTmFCOMDTO.searchKeyword').value = keyword
    form.field_with(:name => 'bTmFCOMDTO.searchValue').value = "4"
    form.field_with(:name => 'bTmFCOMDTO.enzanShiValue').value = "1"
    form.add_field!('jplatpatSession', sess_id)
  end.submit()

  result_count = page.search(".searchbox-result-count").text.gsub("件", "").to_i
  ap result_count
  return if result_count == 0

  page = page.form_with(:name => 'syouhyouLink').submit()

  yomi_list = page.search(".table-result > tbody > tr").map do |tr|
    url = tr.search("td > a").first.attributes["href"].value
    detail_page = agent.get(url)
    detail_tr_list = detail_page.search(".table-information > tr")

    next if detail_tr_list.to_a.size == 0

    #  9: 商標
    # 11: 読み
    # 14: 権利者 氏名または名称
    td_list = detail_tr_list.search('td')

    [
      td_list[9].text,
      td_list[11].text,
      td_list[14].text
    ]
  end

  yomi_list
end

ap scrape('BMW')
