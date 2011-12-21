module GameOfLife
  module Rules
    def newborn_cells
      map do |cell|
        neighbours_of(cell).select { |neighbour| 3 == alive_neighbours_count_of(neighbour) }
      end.flatten(1)
    end

    def stable_cells
      select { |cell| (2..3) === alive_neighbours_count_of(cell) }
    end
  end

  class Board
    include Enumerable
    include Rules

    def initialize(*cells)
      live_cells = cells.map { |cell| [key(cell), true] }
      @cells = Hash[*live_cells.flatten]
    end

    def each
      @cells.each do |key, alive|
        yield coords(key) if alive
      end
    end

    def [](x, y)
      @cells[key(x, y)] == true
    end

    def next_generation
      Board.new *(stable_cells + newborn_cells)
    end

    private

    def neighbours_of(*cell)
      x, y = [cell].flatten

      [
        [x - 1, y + 1], [x, y + 1], [x + 1, y + 1],
        [x - 1, y    ],             [x + 1, y    ],
        [x - 1, y - 1], [x, y - 1], [x + 1, y - 1],
      ]
    end

    def alive_neighbours_count_of(*cell)
      neighbours_of(cell).count { |x, y| self[x, y] }
    end

    def coords(key)
      key.split('.').map(&:to_i)
    end

    def key(*cell)
      x, y = [cell].flatten

      "#{x}.#{y}"
    end
  end
end
