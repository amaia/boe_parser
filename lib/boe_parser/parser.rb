require 'open-uri'
require 'hpricot'

module BoeParser

  BASE_URL = "http://boe.es/boe/dias/"

  class Parser

    def self.fetch_and_parse(date)
      doc = fetch(date)
      result = parse(doc)
    end

    def self.fetch(date)
      # fetch BOE for date
      begin
        date_string = date.strftime("%Y/%m/%d")
        url = "#{BASE_URL}#{date_string}"
        open(url).read
      rescue OpenURI::HTTPError => e
        if e.message =~ /404/
          return nil
        else
          raise
        end
      end
    end

    def self.parse(doc)
      return nil if doc.nil?
      # parse html into a array of hashes
      entries = []
      boe = Hpricot(doc)
      linea_numero = boe.at("h2").inner_html
      numero = linea_numero.scan(/<\/abbr>(.*)<span>/).flatten.first.strip

      boe.at('//a[@name="contenido"]').following_siblings.each do |elemento|
        if elemento.name == 'h3'
          @seccion_nivel1 = (elemento/"a").inner_html
          @seccion_nivel2 = nil
          @seccion_nivel3 = nil
        end
        if elemento.name == 'h4'
          @seccion_nivel2 = (elemento/"a").inner_html
          @seccion_nivel3 = nil
        end
        if elemento.name == 'h5'
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

            entries << {
                    :boe_num => numero,
                    :summary => texto,
                    :link => enlace,
                    :reference => disposicion,
                    :level1_section => @seccion_nivel1,
                    :level2_section => @seccion_nivel2,
                    :level3_section => @seccion_nivel3
            }

          end
        end

      end
      entries
    end
  end

end
