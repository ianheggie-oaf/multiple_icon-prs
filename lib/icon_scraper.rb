# frozen_string_literal: true

require "icon_scraper/version"
require "icon_scraper/page/terms_and_conditions"
require "icon_scraper/authorities"

require "mechanize"
require "scraperwiki"
require "active_support/core_ext/hash"

# Scrape an icon application development system
module IconScraper
  def self.scrape(authority)
    params = AUTHORITIES[authority]
    raise "Unexpected authority: #{authority}" if params.nil?

    scrape_with_params(params) do |record|
      yield record
    end
  end

  def self.scrape_with_params(url:, period:, types: nil, ssl_verify: true, australian_proxy: false,
                              use_html_scraper: false)
    url += "/SearchApplication.aspx"

    agent = Mechanize.new
    agent.verify_mode = OpenSSL::SSL::VERIFY_NONE unless ssl_verify
    if australian_proxy
      # On morph.io set the environment variable MORPH_AUSTRALIAN_PROXY to
      # http://morph:password@au.proxy.oaf.org.au:8888 replacing password with
      # the real password.
      agent.agent.set_proxy(ENV["MORPH_AUSTRALIAN_PROXY"])
    end

    # Hardcode special handling for weird content encoding server setting for gosnells
    agent.content_encoding_hooks << lambda { |_httpagent, _uri, response, _body_io|
      response["content-encoding"] = "gzip" if response["content-encoding"] == "gzip,gzip"
    }

    doc = agent.get(url)
    Page::TermsAndConditions.agree(doc, agent) if Page::TermsAndConditions.on?(doc)
    params = { d: period, k: "LodgementDate", o: "xml" }
    params[:t] = types.join(",") if types
    if use_html_scraper
      scrape_html(url, params, agent) do |record|
        yield record
      end
    else
      rest_xml(url, params, agent) do |record|
        yield record
      end
    end
  end

  def self.scrape_and_save(authority)
    scrape(authority) do |record|
      save(record)
    end
  end

  def self.rest_xml(base_url, query, agent)
    query = query.to_query
    page = agent.get("#{base_url}?#{query}")

    # Explicitly interpret as XML
    page = Nokogiri::XML(page.content)

    root = page.at("NewDataSet")

    raise "Can't find <NewDataSet> element" if root.nil?

    root.search("Application").each do |application|
      council_reference = application.at("ReferenceNumber").inner_text.strip

      application_id = application.at("ApplicationId").inner_text.strip

      # For some reason Coffs Harbour isn't wrapping the address in an <Address>
      line1 = application.at("Address Line1")
      line2 = application.at("Address Line2")

      if line1.nil?
        properties = application.search("Line1").map(&:parent).select do |p|
          p.at("ApplicationId").inner_text == application_id
        end
        # If there's more than one property only consider the first
        if properties.first
          line1 = properties.first.at("Line1")
          line2 = properties.first.at("Line2")
          line3 = properties.first.at("Line3")
        end
        # If empty check in a different location (this is specific to penrith council)
        if properties.empty?
          desc = application.search("Assess").search("Description")
          desc.inner_text.split("|").each do |desc_item|
            next unless desc_item.is_a?(String)

            line1 = desc_item if desc_item =~ /([A-Z]{3})\s([0-9]{4})/ # matches `NSW 2753`
          end

        end
      end

      if line1.nil?
        puts "No address found for #{council_reference}. So, skipping"
        next
      end

      # to avoid calling .inner_text on a string
      address = clean_whitespace(line1.inner_text) unless line1.is_a?(String)
      address = line1 if line1.is_a?(String)
      unless line2.nil? || line2.inner_text.empty?
        address += ", " + clean_whitespace(line2.inner_text)
      end
      unless line3.nil? || line3.inner_text.empty?
        address += ", " + clean_whitespace(line3.inner_text)
      end

      # No idea what this means but it's required to calculate the
      # correct info_url
      pprs = application.at("ThePPRS")&.inner_text&.strip

      info_url = "#{base_url}?id=#{application_id}"
      info_url += "&pprs=#{pprs}" if pprs

      description = application.at("ApplicationDetails") ||
                    application.at("SubNatureOfApplication")

      unless description
        puts "Skipping due to lack of description for #{council_reference}"
        next
      end

      record = {
        "council_reference" => council_reference,
        # It looks like descriptions are entity encoded twice over (for example
        # & is encoded as &amp;amp;)
        "description" => CGI.unescapeHTML(description.inner_text).strip,
        "date_received" => Date.parse(application.at("LodgementDate").inner_text).to_s,
        # TODO: There can be multiple addresses per application
        # We can't just create a new application for each address as we would then have multiple
        # applications with the same council_reference which isn't currently allowed.
        "address" => address,
        "date_scraped" => Date.today.to_s,
        "info_url" => info_url
      }
      # DA03NY1 appears to be the event code for putting this application on exhibition
      # Commenting this out because I don't know whether this can be applied generally to all
      # councils. It seems likely that the event codes are different in each council
      # e = application.search("Event EventCode").find{|e| e.inner_text.strip == "DA03NY1"}
      # if e
      #   record["on_notice_from"] = Date.parse(e.parent.at("LodgementDate").inner_text).to_s
      #   record["on_notice_to"] = Date.parse(e.parent.at("DateDue").inner_text).to_s
      # end

      yield record
    end
  end

  # TODO: NO SUPPORT FOR PAGINATION AND ONLY WORKS FOR NORTHERN BEACHES
  def self.scrape_html(base_url, query, agent)
    query.delete(:o)
    query = query.to_query

    page = agent.get("#{base_url}?#{query}")

    page.search(".result").each do |record|
      council_reference = record.at("a").inner_text.to_s
      info_url = record.at("a").attribute("href").to_s
      info_url = base_url + "/" + info_url
      address = record.at("strong").inner_text.to_s

      inner_div = record.search("div").first.to_s.split("\n")
      date_received = inner_div[9].strip.split("<br>").first
      description = inner_div[3].strip.split("<br>")[1]
      description = description.split("-")[1].strip if description.include?("-")

      record = {}
      record["council_reference"] = council_reference
      record["description"] = description
      record["date_received"] = begin
                                  Date.parse(date_received).to_s
                                rescue ArgumentError
                                  "N/A"
                                end
      record["address"] = address
      record["date_scraped"] = Date.today.to_s
      record["info_url"] = info_url
      yield record
    end
  end

  def self.save(record)
    log(record)
    ScraperWiki.save_sqlite(["council_reference"], record)
  end

  def self.log(record)
    puts "Storing #{record['council_reference']} - #{record['address']}"
  end

  # Copied from lib_icon_rest_xml repo
  def self.clean_whitespace(string)
    string.gsub("\r", " ").gsub("\n", " ").squeeze(" ").strip
  end
end
