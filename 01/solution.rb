class Array
  def to_hash
    {}.tap do |result|
      each { |key, value| result[key] = value }
    end
  end

  def index_by
    map { |n| [yield(n), n] }.to_hash
  end

  def subarray_count(subarray)
    each_cons(subarray.length).count(subarray)
  end

  def occurences_count
    Hash.new(0).tap do |result|
      each { |item| result[item] += 1 }
    end
  end
end
