class Array

  def to_hash
    inject({}) do |hash, pair|
      hash[pair[0]] = pair[1]
      hash
    end
  end

  def index_by(&block)
    ((map &block).zip self).to_hash
  end

  def subarray_count(subarray)
    cnt = 0
    0.upto(length - subarray.length) do |first|
      cnt += 1 if self[first, subarray.length] == subarray
    end
    cnt
  end

  def occurences_count
    occurences = (zip collect {|x| count x}).to_hash
    occurences.default = 0
    occurences
  end
end
