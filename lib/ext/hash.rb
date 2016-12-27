class Hash
  def include_hash?(other)
    merge(other) == self
  end
end
