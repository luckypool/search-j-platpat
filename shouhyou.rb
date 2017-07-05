#!/bin/env ruby
# encoding: utf-8

require "mechanize"
require "ap"
require "pry-byebug"

require 'active_support'
require 'active_support/core_ext'

class Trademark
  attr_reader :id
  attr_reader :name
  attr_reader :segments
  attr_reader :applicant
  attr_reader :applied_at
  attr_reader :registrated_at
  attr_reader :status

  @agent = Mechanize.new
  @agent.user_agent_alias = 'Mac Mozilla'

  def initialize(attributes)
    @id = attributes[:id]
    @name = attributes[:name]
    @segments = attributes[:segments]
    @applicant = attributes[:applicant]
    @applied_at = attributes[:applied_at]
    @registrated_at = attributes[:registrated_at]
    @status = attributes[:status]
  end


  def self.search_by(keyword)
    elements = get_searched_elements(keyword)
    return if elements.blank?
    elements.map do |e|
      self.new({
        id: e[:number],
        name: e[:applicant],
        segments: e[:segments],
        applicant: e[:applicant],
        applied_at: e[:applied_at],
        registrated_at: e[:registrated_at],
        status: e[:status]
      })
    end
  end

  private

  TOP_URL = "https://www.j-platpat.inpit.go.jp/web/all/top/BTmTopPage"
  SEARCHED_ATTRIBUTES = %i{search_index none number name segments applicant applied_at registrated_at graphic status}

  def self.get_searched_elements(keyword)
    page = @agent.get(TOP_URL)

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

    ap "----"
    ap "検索件数: #{result_count} 件"
    return if result_count == 0

    result_page = page.form_with(:name => 'syouhyouLink').submit()

    extract_elements(result_page)
  end

  def self.extract_elements(page)
    elements = page.search(".table-result > tbody > tr").map do |tr|
      strip_from_elements(tr.search("td"))
    end
    ap "#{elements.size} 件取得中..."
    url = get_pagination_link(page)
    return elements if url.blank?
    [elements, extract_elements(@agent.get(url))].flatten
  end

  def self.get_pagination_link(page)
    a = page.search("li.pagination-link.icon-next a").first
    return if a.blank?
    a.attributes["href"].value
  end

  def self.strip_from_elements(elements)
    pair_list = SEARCHED_ATTRIBUTES.map.with_index do |attr, i|
      # 余白削除、全角→半角
      value = elements[i].text.strip.tr('０-９ａ-ｚＡ-Ｚ　', '0-9a-zA-Z ')
      [attr, value]
    end
    Hash[pair_list]
  end
end

ap Trademark.search_by('BMW').size

