# -*- encoding: utf-8 -*-

require 'ostruct'
require 'open-uri'
require 'nokogiri'
require 'iconv'

module BoeParser

  class Parser

    BASE_URL = "http://boe.es/boe/dias/"

    def initialize(date)
      @date = date
      @status = 0
    end

    def html
      @html_doc ||= self.fetch_html
    end

    def fetch_html
      # fetch BOE for date
      begin
        date_string = @date.strftime("%Y/%m/%d")
        @url = "#{BASE_URL}#{date_string}/index.php?s=c"
        @status = 200
        page_content = open(@url).read
        @html_doc = page_content.encode('utf-8')
      rescue OpenURI::HTTPError => e
        if e.message =~ /404/
          @status = 404
          return nil
        else
          @status = e.message
          raise
        end
      end
    end

    def entries
      self.fetch_html
      return nil if @html_doc.nil?
      # parse html into a array of ostructs 
      entries = []
      boe = Nokogiri::HTML(@html_doc, nil, 'utf-8')
      linea_numero = boe.at("h2").inner_html
      numero = linea_numero.scan(/<\/abbr>(.*)/).flatten.first.strip

      boe.at('div#indiceSumario').children.each do |elemento|
        if elemento.name == 'h4'
          @seccion_nivel1 = (elemento/"a").inner_html
          @seccion_nivel2 = nil
          @seccion_nivel3 = nil
        end
        if elemento.name == 'h5'
          @seccion_nivel2 = (elemento/"a").inner_html
          @seccion_nivel3 = nil
        end
        if elemento.name == 'h6'
          @seccion_nivel3 = elemento.inner_html
        end
        if elemento.name == 'ul'
          dispos = elemento.search("//li[@class='dispo']")
          dispos.each do |d|
            #buscamos el enlace a la disposicion en html (no al pdf)
            enlaces = d.search("//li[@class='puntoMas']/a")
            # por alguna razon a veces hay un nil aquí, si hay nil saltamos a la siguiente vuelta
            next if enlaces.first.nil?
            enlace_href = enlaces.first["href"]
            enlace = "http://boe.es" + enlace_href
            disposicion = enlace_href.scan(/\?id\=.*/).first.gsub('?id=', '')
            (d/"div.enlacesDoc").remove
            texto = d.inner_html.strip

            entry = OpenStruct.new(
                    :boe_number => numero,
                    :summary => texto,
                    :link => enlace,
                    :reference => disposicion,
                    :level1_section => @seccion_nivel1,
                    :level2_section => @seccion_nivel2,
                    :level3_section => @seccion_nivel3
                    )

            entries << entry

          end
        end
      end
      entries
    end
  end

end
