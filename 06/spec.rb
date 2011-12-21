# encoding: utf-8

describe GameOfLife::Board do
  describe 'initialization' do
    it 'can be initialized with no args' do
      board = new_board
    end

    it 'accepts multiple coords in the constructor' do
      board = new_board [0, 0], [1, 1], [2, 2]
    end
  end

  describe 'enumeration' do
    it 'responds to each, map, count, etc.' do
      board = new_board

      [:each, :count, :each_cons, :each_with_index, :map, :inject, :any?, :all?].each do |enumerable_method|
        board.should respond_to(enumerable_method)
      end
    end

    it 'yields nothing for empty boards' do
      new_board.each { fail }
    end

    it 'yields coordinates of live cells' do
      cells  = [0, 1], [2, 3], [5, 5]

      new_board(*cells).each do |x, y|
        cells.should include([x, y])
        cells.delete [x, y]
      end

      cells.should be_empty
    end

    describe 'live cells count' do
      it 'returns 0 for an empty board' do
        new_board.count.should eq 0
      end

      it 'returns the number of live cells on a board' do
        new_board([0, 0]).count.should eq 1
        new_board([0, 0], [1, 1]).count.should eq 2
        new_board([0, 0], [1, 1], [0, 0]).count.should eq 2
      end
    end
  end

  describe 'indexing' do
    it 'responds to []' do
      new_board.should respond_to(:[])
    end

    it 'works for live and dead cells' do
      board = new_board([1, 2])

      board[1, 2].should be_true
      board[2, 2].should be_false
      board[0, -2].should be_false

      new_board[42, 42].should be_false
    end
  end

  describe 'evolution' do
    it 'responds to next_generation' do
      new_board.should respond_to(:next_generation)
    end

    it 'returns a new board' do
      board = new_board
      next_gen = board.next_generation

      next_gen.should be_kind_of(GameOfLife::Board)
      next_gen.should_not be_equal(board)
    end

    describe 'rules' do
      it 'kills cells in underpopulated areas' do
        board = new_board [1, 1]
        board[1, 1].should be_true
        board.count.should eq 1

        next_gen = board.next_generation

        board.count.should eq 1
        board[1, 1].should be_true

        next_gen.count.should eq 0
        next_gen[1, 1].should be_false
      end

      it 'preserves stable cells' do
        board = new_board [0, 1], [1, 1], [2, 1], [1, 2]
        board[1, 1].should be_true
        board.count.should eq 4

        next_gen = board.next_generation
        board.count.should eq 4

        next_gen[1, 1].should be_true
      end

      it 'kills cells in overpopulated areas' do
        board = new_board [0, 1], [1, 1], [2, 1], [1, 2], [1, 0]
        board[1, 1].should be_true
        board.count.should eq 5

        next_gen = board.next_generation
        board.count.should eq 5

        next_gen[1, 1].should be_false
      end

      it 'sprouts new life when appropriate' do
        board = new_board [0, 1], [1, 1], [2, 1]
        board[1, 1].should be_true
        board[1, 0].should be_false
        board.count.should eq 3

        next_gen = board.next_generation

        next_gen[1, 0].should be_true
        next_gen[1, 2].should be_true
      end

      it 'evolves a formation correctly' do
        board = new_board [0, 1], [1, 1], [2, 1], [1, 2]
        board[1, 1].should be_true
        board.count.should eq 4

        next_gen = board.next_generation

        expect_generation_in next_gen, [0, 1], [1, 1], [2, 1], [0, 2], [1, 2], [2, 2], [1, 0]
      end

      it 'oscilates the oscilators' do
        board = new_board [0, 1], [1, 1], [2, 1]

        10.times do |n|
          expected = n.odd? ? [[1, 0], [1, 1], [1, 2]] : [[0, 1], [1, 1], [2, 1]]

          expect_generation_in board, *expected

          board = board.next_generation
        end
      end

      it 'keeps stable formations stable' do
        block   = [0, 0], [1, 0], [0, 1], [1, 1]
        beehive = [0, 0], [1, 0], [2, 1], [1, 2], [0, 2], [-1, 1]

        [block, beehive].each do |stable_formation|
          board = new_board *stable_formation

          12.times do
            board = board.next_generation
            expect_generation_in board, *stable_formation
          end
        end
      end
    end
  end

  def new_board(*args)
    GameOfLife::Board.new *args
  end

  def expect_generation_in(board, *cells)
    board.count.should eq cells.count
    (board.to_a - cells).should eq []
    (cells - board.to_a).should eq []
  end
end
