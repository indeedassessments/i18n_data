require 'i18n_data/version'

module I18nData
  extend self
  
  def languages(language_code='EN')
    data_provider.codes(:languages, normal_to_region_code(language_code.to_s.upcase))
  end

  def countries(language_code='EN')
    data_provider.codes(:countries, normal_to_region_code(language_code.to_s.upcase))
  end

  def country_code(name)
    recognise_code(:countries, name)
  end

  def language_code(name)
    recognise_code(:languages, name)
  end

  def data_provider
    if @data_provider
      @data_provider
    else
      require 'i18n_data/file_data_provider'
      FileDataProvider
    end
  end

  def data_provider=(provider)
    @data_provider = provider
  end

  private

  # hardcode languages that do not have a default type
  # e.g. zh does not exist, but zh_CN does
  def normal_to_region_code(normal)
    {
      "ZH" => "ZH_CN",
      "BN" => "BN_IN",
    }[normal] || normal
  end

  def recognise_code(type, search)
    search = search.strip

    # common languages first <-> faster in majority of cases
    common_languages = ['EN','ES','FR','DE','ZH']
    langs = (common_languages + (languages.keys - common_languages))
    
    langs.each do |code|
      begin
        send(type, code).each do |code, name|
          # supports "Dutch" and "Dutch; Flemish", checks for inclusion first -> faster
          match_found = (name.include?(search) and name.split(';').map{|s| s.strip }.include?(search))
          return code if match_found
        end
      rescue NoTranslationAvailable
      end
    end
    nil
  end
  
  class NoTranslationAvailable < Exception
    def to_s
      "NoTranslationAvailable -- #{super}"
    end
  end
end
