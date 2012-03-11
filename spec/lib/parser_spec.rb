require 'spec_helper'
require 'date'

describe BoeParser::Parser do

  describe "fetch" do

    it "fetches the boe page for a valid date" do
      date = Date.parse("2012-03-02")
      doc = BoeParser::Parser.fetch(date)
      doc.should_not be_nil
    end

    it "handles the 404 status for an invalid date (a sunday with no BOE published)" do
      date = Date.parse("2012-03-11")
      doc = BoeParser::Parser.fetch(date)
      doc.should be_nil
    end

    it "handles the 404 status for an future date (no BOE published yet, 404 status)" do
      date = Date.today + 10 # ten days in the future
      doc = BoeParser::Parser.fetch(date)
      doc.should be_nil
    end

  end

  describe "parse" do

    it "handles a nil doc" do
      boe = BoeParser::Parser.parse(nil)
      boe.should be_nil
    end

    it "returns an array of hashes for a valid html doc" do
      doc = File.open(File.expand_path('../../support/sample_valid_doc.html', __FILE__))
      boe = BoeParser::Parser.parse(doc)
      boe.class.should eql Array
    end

  end

end