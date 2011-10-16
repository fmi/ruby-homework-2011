describe "Array#to_hash" do
  it "converts an array to a hash" do
    [[:one, 1], [:two, 2]].to_hash.should eq(one: 1, two: 2)
  end
end

describe "Array#index_by" do
  it "indexes the array elemens by a block" do
    ['John Coltrane', 'Miles Davis'].index_by { |name| name.split(' ').last }.should eq('Coltrane' => 'John Coltrane', 'Davis' => 'Miles Davis')
  end
end

describe "Array#subarray_count(subarray)" do
  it "counts the number of times the argument is present as a sub-array" do
    [1, 1, 2, 1, 1, 1].subarray_count([1, 1]).should eq 3
  end
end

describe "Array#occurences_count" do
  it "counts how many times an element is present in an array" do
    [:foo, :bar, :foo].occurences_count.should eq(foo: 2, bar: 1)
  end
end
