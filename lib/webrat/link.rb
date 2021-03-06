module Webrat
  class Link
    
    def initialize(page, element)
      @page     = page
      @element  = element
    end
    
    def click(method = nil)
      method ||= http_method
      return if href =~ /^#/ && method == :get
      
      Page.new(@page.session, absolute_href, method, authenticity_token.blank? ? {} : {"authenticity_token" => authenticity_token})
    end
    
    def matches_text?(link_text)
      text =~ /#{Regexp.escape(link_text.to_s)}/i
    end
    
    def text
      @element.innerHTML
    end
    
  protected

    def href
      @element["href"]
    end

    def absolute_href
      if href =~ /^\?/
        "#{@page.url}#{href}"
      elsif href !~ /^\//
        "#{@page.url}/#{href}"
      else
        href
      end
    end
    
    def authenticity_token
      return unless onclick && onclick.include?("s.setAttribute('name', 'authenticity_token');") &&
        onclick =~ /s\.setAttribute\('value', '([a-f0-9]{40})'\);/
      $LAST_MATCH_INFO.captures.first
    end
    
    def onclick
      @element["onclick"]
    end
    
    def http_method
      if !onclick.blank? && onclick.include?("f.submit()")
        http_method_from_js_form
      else
        :get
      end
    end

    def http_method_from_js_form
      if onclick.include?("m.setAttribute('name', '_method')")
        http_method_from_fake_method_param
      else
        :post
      end
    end

    def http_method_from_fake_method_param
      if onclick.include?("m.setAttribute('value', 'delete')")
        :delete
      elsif onclick.include?("m.setAttribute('value', 'put')")
        :put
      else
        raise "No HTTP method for _method param in #{onclick.inspect}"
      end
    end

  end
end
