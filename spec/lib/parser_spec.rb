# -*- encoding: utf-8 -*-

require 'spec_helper'
require 'date'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :fakeweb
  c.allow_http_connections_when_no_cassette = true
end


describe BoeParser::Parser do


  it "fetches the boe page for a valid date" do
    date = Date.parse("2012-03-02")
    boe = BoeParser::Parser.new(date)
    boe.html.should_not be_nil
  end

  it "handles the 404 status for an invalid date (a sunday with no BOE published)" do
    date = Date.parse("2012-03-11")
    boe = BoeParser::Parser.new(date)
    boe.html.should be_nil
  end

  it "handles the 404 status for an future date (no BOE published yet, 404 status)" do
    date = Date.today + 10 # ten days in the future
    boe = BoeParser::Parser.new(date)
    boe.html.should be_nil
  end

  describe ".entries" do 
    it "returns an array of objects for a valid html doc" do
      #doc = File.open(File.expand_path('../../support/sample_valid_doc.html', __FILE__))
      VCR.use_cassette 'boe' do 
        date = Date.parse("2012-03-02")
        boe = BoeParser::Parser.new(date)
        entries = boe.entries
        entries.class.should eql Array
        entries.first.should respond_to :link
        entries.first.boe_number.should eq '53'
        entries.first.reference.should eq 'BOE-A-2012-2974'
        entries.first.level1_section.should eq 'I. Disposiciones generales'
        entries.first.level2_section.should eq 'MINISTERIO DE ASUNTOS EXTERIORES Y DE COOPERACIÓN'
        entries.first.level3_section.should eq 'Acuerdos internacionales'
        entries.first.link.should eq 'http://boe.es/diario_boe/txt.php?id=BOE-A-2012-2974'
        entries.first.summary.should eq '<p>Acuerdo sobre la participación de la República de Bulgaria y Rumania en el Espacio Económico Europeo, hecho en Bruselas el 25 de julio de 2007.</p>'
      end
    end

  end

end
