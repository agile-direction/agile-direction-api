module RequirementsHelper
  ALLOWED_TLDS = %w(
    com
    info
    net
    org
    gov
    au
    br
    cn
    de
    es
    fr
    in
    ir
    it
    jp
    nl
    pl
    ru
    uk
  )
  DEFAULT_PROTOCOL = "http://"
  PROTOCOL_MATCHER = /:\/\//
  HTTP_PROTOCOL = "http"
  ALLOWED_TLDS_REGEX = "(#{ALLOWED_TLDS.join("|")})"
  ALLOWED_DOMAIN_CHARACTERS = /([\w\-]+\.)+/
  ALLOWED_DOMAINS = %r{#{ALLOWED_DOMAIN_CHARACTERS}#{ALLOWED_TLDS_REGEX}}

  def inject_links(string)
    result = string.gsub(%r{(\w+?:\/\/)?(#{ALLOWED_DOMAINS})(\/.*)?}) do |url|
      url = "#{HTTP_PROTOCOL}://#{url}" unless url.match(PROTOCOL_MATCHER)
      return url unless url.match(HTTP_PROTOCOL)
      link_text = url.match(ALLOWED_DOMAINS)
      content_tag(:a, link_text, { href: "#{url}" }).html_safe
    end
  end
end
