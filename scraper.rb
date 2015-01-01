# -*- coding: utf-8 -*-

require 'json'
require 'mechanize'
require 'turbotlib'
require 'active_support'

def clean_string(s)
  s.gsub(/\A[[:space:]]*(.*?)[[:space:]]*\z/) { $1 }
end

urls = {
  'Investment Services' => 'http://www.atvp.si/Default.aspx?id=98',
  'Investment Fund Management' => 'http://www.atvp.si/Default.aspx?id=101'
}

urls.each do |category, url|
  agent = Mechanize.new
  page = agent.get(url)
  page.search('.documentContent .tabela tr:not(.header)').each do |bank|

    company_name, *address_parts = bank.search('td')[1].text.strip.split("\r\n")
    contact = bank.search('td')[2].text.strip.split("\r\n")
    telephone_line = contact.detect {|x| x.match(/tel/)}
    telephone = telephone_line && telephone_line.gsub(/(telefon|tel.):/, '').strip
    fax_line = contact.detect {|x| x.match(/faks/)}
    fax = fax_line && fax_line.gsub('faks:', '').strip
    member_of_stock_exchange = bank.search('td')[6] && bank.search('td')[6].search('img').size > 0

    data = {
      company_name: clean_string(company_name),
      address: clean_string(address_parts.map {|x| x.strip}.join(', ')),
      telephone: clean_string(telephone),
      fax: clean_string(fax),
      url: bank.search('td')[1].search('a').attr('href'),
      member_of_stock_exchange: member_of_stock_exchange,
      category: category,
      source_url: url,
      sample_date: Time.now
    }

    puts JSON.dump(data)
  end
end

urls = {
  'Agent' => 'http://www.atvp.si/Default.aspx?id=163'
}

urls.each do |category, url|
  agent = Mechanize.new
  page = agent.get(url)
  page.search('.documentContent .tabela tr:not(.header)').each do |agent|

    data = {
      reference_number: clean_string(agent.search('td')[1].text),
      company_name: clean_string(agent.search('td')[2].text),
      address: clean_string(agent.search('td')[3].text.split("\r\n").join(', ').squeeze(' ')),
      tax_registration_number: clean_string(agent.search('td')[4].text),
      start_date: (Date.parse(clean_string(agent.search('td')[5].text).gsub(' ', '').gsub('.','/')) rescue nil),
      end_date: (Date.parse(clean_string(agent.search('td')[6].text).gsub(' ', '').gsub('.','/')) rescue nil),
      category: category,
      source_url: url,
      sample_date: Time.now
    }

    puts JSON.dump(data)
  end
end
