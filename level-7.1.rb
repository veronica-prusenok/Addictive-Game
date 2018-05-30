def new_coords_by_move(coords, move)
  move_to = case move
    when 'N' then [coords[0]-1, coords[1]]
    when 'E' then [coords[0], coords[1]+1]
    when 'S' then [coords[0]+1, coords[1]]
    when 'W' then [coords[0], coords[1]-1]
    else [nil,nil]
  end
end

class Point
  attr_reader :point, :color, :coords

  def initialize(point, color, board_width)
    @point = point
    @color = color
    @coords = [(point-1)/board_width, (point-1)%board_width]
  end

  def distance_with(another_point)
    (self.coords[0] - another_point.coords[0]).abs + (self.coords[1] - another_point.coords[1]).abs
  end
end

class Path
  attr_reader :start_point, :moves, :color

  def initialize(color, start_poz, length, steps, board_width)
    @color = color
    @start_point = Point.new(start_poz, color, board_width)
    @length = length
    @moves = steps
  end
end

class Game
  attr_reader :rows, :cols, :points, :paths

  def initialize(array)
    @rows = array.slice!(0).to_i
    @cols = array.slice!(0).to_i
    @points_count = array.slice!(0).to_i
    @points_with_color = array.slice!(0...@points_count*2).map(&:to_i).each_slice(2).to_a
    @points = @points_with_color.map{ |point| Point.new(point[0], point[1], @cols) }
    @paths_count = array.slice!(0).to_i
    @paths = []
    @paths_count.times do
      color = array.slice!(0).to_i
      start_poz = array.slice!(0).to_i
      length = array.slice!(0).to_i
      steps = array.slice!(0, length)
      @paths << Path.new(color, start_poz, length, steps, @cols)
    end
  end
end

class Board
  attr_reader :board

  def initialize(rows_count, cols_count, points, paths)
    @board = Array.new(rows_count){Array.new(cols_count, ' ')}

    apply_points(points)
    apply_paths(paths)
  end

  def print
    board.each do |row|
      puts row.join(', ').gsub(',', '')
    end
  end

  private
  def apply_points(points)
    points.each{ |point| self.board[point.coords[0]][point.coords[1]] = point.color }
  end

  def apply_paths(paths)
    paths.each do |path|
      point = path.start_point.coords
      path.moves.each do |move|
        point = new_coords_by_move(point, move)
        self.board[point[0]][point[1]] = self.board[point[0]][point[1]] == ' ' ? 0 : path.color
      end
    end
  end
end


data = File.open('level7/level7-11.in').map{ |line| line.split(" ") }
tests_num = data.flatten!.slice!(0).to_i

tests_num.times do
  game = Game.new(data)
  board = Board.new(game.rows, game.cols, game.points, game.paths)
  board.print
end
