# -*- coding: utf-8 -*-

require 'json'
require 'mechanize'
require 'turbotlib'
require 'byebug'

urls = {
  'Investment Services' => 'http://www.atvp.si/Default.aspx?id=98'
}

urls.each do |category, url|
  agent = Mechanize.new
  page = agent.get(url)
  page.search('.documentContent .tabela tr:not(.header)').each do |bank|

    data = {
      # todo strip strange utf-8 blanks from beginning and end of string
      company_name: bank.search('td')[1].text.strip.split("\r\n").first.strip,
      # president: bank.search('td')[1].text.strip.split("\r\n").first,
      # general_manager: bank.search('td')[2].text.strip.split("\r\n").first,
      # address: bank.search('td')[3].text.strip.gsub(/\r\n/, ', ').squeeze(' '),
      # telephone: bank.search('td')[4].text.strip.gsub(/\r\n/, ', ').squeeze(' '),
      # fax: (bank.search('td')[5].text.strip.gsub(/\r\n/, ', ').squeeze(' ') rescue ''),
      # url: (bank.search('td')[0].search('a')[0].attr('href') rescue ''),
      # category: category,
      # source_url: url,
      # sample_date: Time.now
    }

    puts JSON.dump(data)
  end
end
