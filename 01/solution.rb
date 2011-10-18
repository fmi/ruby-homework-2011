class Array

  def to_hash
    inject({}) do
      |hash, pair| hash[pair[0]] = pair[1]
      hash
    end
  end

  def index_by(&block)
    ((map &block).zip self).to_hash
  end

  def subarray_count(subarray)
    subarray.each do |elem|
      
    end
  end

  def occurences_count
    (zip collect {|x| count x}).to_hash
  end
end
