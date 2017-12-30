def parse_data(data)
  (0..(data[2].to_i*2)+3).each{|el| data[el] = data[el].to_i}
  points_x_2 = data[2]*2
  [data[0],data[1],data[2],data[3..points_x_2+2].each_slice(2).to_a, data[points_x_2+3], data[points_x_2+4..-1]]
end

def poz_of_point(point, width)
  i = point - 1
  x, y = i / width, i % width
  [x+1,y+1]
end

def point_by_coords(x, y, width)
  (x * width) + (y % width) + 1
end

def calc_points_poz_with_color(arr,width)
  temp = []
  arr.each do |point|
    temp << poz_of_point(point[0], width) + [point[1]]
  end
  temp
end

def sort_by_color(arr)
  arr.sort_by(&:last).each_slice(2).to_a
end

def distance_for(p1,p2)
  (p1[0] - p2[0]).abs + (p1[1] - p2[1]).abs
end

def calc_distances_by_color(arr)
  temp = []
  sort_by_color(arr).each do |points|
    temp << distance_for(points[0].take(2), points[1].take(2))
  end
  temp
end

def as_str(arr)
  arr.join(', ').gsub(',', '')
end

def join_paths(num_of_paths, paths)
  join_paths = Array.new(num_of_paths){Hash.new(4)}
  join_paths.each do |path|
    path[:color] = paths.slice!(0).to_i
    path[:start_poz] = paths.slice!(0).to_i
    path[:length] = paths.slice!(0).to_i
    path[:steps] = paths.slice!(0, path[:length])
  end
  [join_paths, paths]
end

def apply_points(points, board)
  points.each do |point|
    board[point[0]-1][point[1]-1] = point[2]
  end
  board
end

def new_poz_by_old(board, coords, move, color)
  rows, cols = board.size, board[0].size
  move_to = case move
    when 'N' then [coords[0]-1,coords[1]]
    when 'E' then [coords[0],coords[1]+1]
    when 'S' then [coords[0]+1,coords[1]]
    when 'W' then [coords[0],coords[1]-1]
    else [-1,-1]
  end
  return {status: -1} if move_to[0] < 0 || move_to[1] < 0 || move_to[0] >= rows || move_to[1] >= cols || (board[move_to[0]][move_to[1]] != ' ' && board[move_to[0]][move_to[1]] != color)

  if board[move_to[0]][move_to[1]] == color
    return {status: 1, board: board, current_poz: [move_to[0],move_to[1]]}
  else
    board[move_to[0]][move_to[1]] = 0
    return {status: 0, board: board, current_poz: [move_to[0],move_to[1]]}
  end
end

def apply_moves(board, start_coords, moves, color)
  old_board = board
  old_coords = start_coords
  moves.each_with_index do |move, i|
    res = new_poz_by_old(old_board, old_coords, move, color)

    case res[:status]
    when -1
      return [-1, i+1]
    when 1
      if res[:current_poz] == start_coords
        return [-1, i+1]
      elsif i != moves.size-1
        old_board = res[:board]
        old_coords = res[:current_poz]
      else
        return [1, i+1, res[:board]]
      end
    when 0
      old_board = res[:board]
      old_coords = res[:current_poz]

      return [-1, i+1] if i == moves.size-1
    end
  end
end

def apply_paths(play_board, joined_paths, cols)
  joined_paths.each do |path|
    board = play_board.map(&:clone)
    start_coords = poz_of_point(path[:start_poz], cols)
    start_coords[0], start_coords[1] = start_coords[0]-1, start_coords[1]-1
    result = apply_moves(board, start_coords, path[:steps], path[:color])

    play_board = result[2] if result[0] == 1
  end
  play_board
end

def is_connectively?(point1, point2, play_board, color)
  board = play_board.map(&:clone)
  rows = board.size
  cols = board.first.size
  node_queue = [point1]

  while(node_queue.size != 0)
    curr_node = node_queue.pop

    return true if board[curr_node[0]][curr_node[1]] == color && curr_node != point1
    next if board[curr_node[0]][curr_node[1]] != ' ' && board[curr_node[0]][curr_node[1]] != color

    board[curr_node[0]][curr_node[1]] = 0

    children = []

    children << [curr_node[0]-1, curr_node[1]] if curr_node[0]-1 >= 0
    children << [curr_node[0]+1, curr_node[1]] if curr_node[0]+1 < rows
    children << [curr_node[0], curr_node[1]-1] if curr_node[1]-1 >= 0
    children << [curr_node[0], curr_node[1]+1] if curr_node[1]+1 < cols

    node_queue = children + node_queue
  end
end

def can_move(board, point, width, color, path_end_points)
  x,y = poz_of_point(point, width)
  x,y = x-1, y-1

  variants = []
  rows = board.size
  cols = board.first.size

  variants << ['S', [x-1, y]] if x-1 >= 0 && (board[x-1][y] == ' ' || path_end_points.include?([x-1, y]))
  variants << ['N', [x+1, y]] if x+1 < rows && (board[x+1][y] == ' ' || path_end_points.include?([x+1, y]))
  variants << ['W', [x, y-1]] if y-1 >= 0 && (board[x][y-1] == ' ' || path_end_points.include?([x, y-1]))
  variants << ['E', [x, y+1]] if y+1 < cols && (board[x][y+1] == ' ' || path_end_points.include?([x, y+1]))

  variants
end

data = ''
File.open('level6/level6-11.in').each do |line|
  data << line
end
data = data.split(" ")
tests_num = data.slice!(0).to_i
rest = data
result = [tests_num]
tests = {}

tests_num.times do |i|
  parsed_data = parse_data(rest)
  joined_paths, rest = join_paths(parsed_data[4], parsed_data[5])
  tests[:"test#{i+1}"] = {
    rows: parsed_data[0],
    cols: parsed_data[1],
    size: parsed_data[2],
    points_with_color: parsed_data[3],
    joined_paths: joined_paths,
  }
end

tests.each_with_index do |(key,data),index|
  coords_with_color = calc_points_poz_with_color(data[:points_with_color], data[:cols])
  play_board = apply_points(coords_with_color, Array.new(data[:rows]){Array.new(data[:cols], ' ')})
  play_board = apply_paths(play_board, data[:joined_paths], data[:cols])
  paths = []

  points_to_check = data[:points_with_color]
  path_end_points = []

  3.times do
    points_to_check.each do |point, color|
      possible_moves = can_move(play_board, point, data[:cols], color, path_end_points)
      if possible_moves.size == 1
        pos_x, pos_y = possible_moves.first.last
        points_to_check = points_to_check - [point, color]
        play_board[pos_x][pos_y] = 0
        path_end_points << [pos_x, pos_y]
        points_to_check.push([point_by_coords(pos_x, pos_y, data[:cols]), color])
        paths << [point, color, possible_moves.first.first]
      end
    end
  end
  p paths
end
