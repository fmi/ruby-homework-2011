describe Collection do
  let(:additional_tags) do
    {}
  end

  let(:input) do
    <<-END
      'Round Midnight.              John Coltrane.      Jazz
      Tutu.                         Miles Davis.        Jazz, Fusion.       weird, cool
      Autumn Leaves.                Bill Evans.         Jazz.               popular
      Waltz for Debbie.             Bill Evans.         Jazz
      'Round Midnight.              Thelonious Monk.    Jazz, Bebop
      Toccata e Fuga.               Bach.               Classical, Baroque. popular
      Goldberg Variations.          Bach.               Classical, Baroque
    END
  end

  let(:collection) { Collection.new input, additional_tags }

  it "can look up songs by artist" do
    songs(artist: 'Bill Evans').map(&:name).should =~ ['Autumn Leaves', 'Waltz for Debbie']
  end

  it "can look up songs by name" do
    songs(name: "'Round Midnight").map(&:artist).should =~ ['John Coltrane', 'Thelonious Monk']
  end

  it "can find songs by tag" do
    songs(tags: 'baroque').map(&:name).should =~ ['Toccata e Fuga', 'Goldberg Variations']
  end

  it "constructs an object for each song" do
    song = collection.find(name: 'Tutu').first

    song.name.should      eq 'Tutu'
    song.artist.should    eq 'Miles Davis'
    song.genre.should     eq 'Jazz'
    song.subgenre.should  eq 'Fusion'
    song.tags.should      include('weird', 'cool')
  end

  def songs(options = {})
    collection.find(options)
  end
end
