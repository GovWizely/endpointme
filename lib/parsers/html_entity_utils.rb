module HTMLEntityUtils
  def sanitize_value(v, flavor = 'xhtml1')
    html_entities_coder = HTMLEntities.new(flavor)
    html_entities_coder.decode(Sanitize.clean(v)).squish
  end
end
