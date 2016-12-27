class String
  def indexize
    tableize.tr('/', ':')
  end
end
