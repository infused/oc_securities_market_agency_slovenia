# -*- coding: utf-8 -*-

require 'json'
require 'mechanize'
require 'turbotlib'

def clean_string(s)
  s.gsub(/\A[[:space:]]*(.*?)[[:space:]]*\z/) { $1 }
end

urls = {
  'Investment Services' => 'http://www.atvp.si/Eng/Default.aspx?id=98',
  'Investment Fund Management' => 'http://www.atvp.si/Eng/Default.aspx?id=101',
  'Mutual Pension Fund' => 'http://www.atvp.si/Eng/Default.aspx?id=104'
}

urls.each do |category, url|
  agent = Mechanize.new
  page = agent.get(url)
  page.search('.documentContent .tabela tr:not(.header)').each do |bank|

    company_name, *address_parts = bank.search('td')[1].text.strip.split("\r\n")
    contact = bank.search('td')[2].text.strip.split("\r\n")
    telephone_line = contact.detect {|x| x.match(/tel/)}
    telephone = telephone_line && telephone_line.gsub(/(telefon|tel.):/, '').strip
    fax_line = contact.detect {|x| x.match(/(faks|fax)/i)}
    fax = fax_line && fax_line.gsub(/(faks|fax):/i, '').strip
    member_of_stock_exchange = bank.search('td')[6] && bank.search('td')[6].search('img').size > 0

    data = {
      company_name: clean_string(company_name),
      address: clean_string(address_parts.map {|x| x.strip}.join(', ').squeeze(' ')),
      url: bank.search('td')[1].search('a').attr('href'),
      member_of_stock_exchange: member_of_stock_exchange,
      category: category,
      source_url: url,
      sample_date: Time.now
    }

    data[:telephone] = clean_string(telephone) if telephone
    data[:fax] = clean_string(fax) if fax

    puts JSON.dump(data)
  end
end

urls = {
  'Agent' => 'http://www.atvp.si/Eng/Default.aspx?id=138'
}

urls.each do |category, url|
  agent = Mechanize.new
  page = agent.get(url)
  page.search('.documentContent .tabela tr:not(.header)').each do |agent|

    data = {
      reference_number: clean_string(agent.search('td')[1].text),
      company_name: clean_string(agent.search('td')[2].text),
      address: agent.search('td')[3].text.split("\r\n").map {|x| clean_string(x)}.join(', ').squeeze(','),
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

urls = {
  'Stock Exchange' => 'http://www.atvp.si/Eng/Default.aspx?id=99',
  'Central Securities Clearing Corporation' => 'http://www.atvp.si/Eng/Default.aspx?id=102'
}

urls.each do |category, url|
  agent = Mechanize.new
  page = agent.get(url)
  page.search('.documentContent .tabela tr:not(.header)').each do |co|

    next if co.search('td')[2].nil? # skip blank rows

    contact = co.search('td')[2].text.strip.split("\r\n")
    telephone_line = contact.detect {|x| x.match(/tel/)}
    telephone = telephone_line && telephone_line.gsub(/(telefon|tel.):/, '').strip
    fax_line = contact.detect {|x| x.match(/(faks|fax)/i)}
    fax = fax_line && fax_line.gsub(/(faks|fax):/i, '').strip

    data = {
      company_name: clean_string(co.search('td')[0].text),
      address: co.search('td')[1].text.split("\r\n").map{|x| x.strip}.join(', ').squeeze(' '),
      telephone: telephone,
      fax: fax,
      category: category,
      source_url: url,
      sample_date: Time.now
    }

    data[:url] = !co.search('td')[0].search('a').empty? && co.search('td')[0].search('a').attr('href')

    puts JSON.dump(data)
  end
end

urls = {
  'Public Company' => 'http://www.atvp.si/Eng/Default.aspx?id=93'
}

urls.each do |category, url|
  agent = Mechanize.new
  page = agent.get(url)
  page.search('.documentContent .tabela tr:not(.header)').each do |co|
    data = {
      company_name: clean_string(co.search('td')[1].text),
      address: co.search('td')[2].text.split("\r\n").map{|x| x.strip}.join(', ').squeeze(' '),
      category: category,
      source_url: url,
      sample_date: Time.now
    }

    puts JSON.dump(data)
  end
end
