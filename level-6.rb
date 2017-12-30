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

data = ''
File.open('level6/level6-11.in').each do |line|
  data << line
end
data = data.split(" ")
tests_num = data.slice!(0).to_i
rest = data
result = []

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
  result << Array.new(parsed_data[2]/2)
end

tests.each_with_index do |(key,data),index|
  coords_with_color = calc_points_poz_with_color(data[:points_with_color], data[:cols])
  play_board = apply_points(coords_with_color, Array.new(data[:rows]){Array.new(data[:cols], ' ')})
  play_board = apply_paths(play_board, data[:joined_paths], data[:cols])

  colors_to_establish = (1..data[:size]/2).to_a
  # apply certain values
  distances_by_color = calc_distances_by_color(coords_with_color)
  distances_by_color.each_index.select{|i| distances_by_color[i] == 1}.each{|i|
    result[index][i] = 2
    colors_to_establish.delete(i+1)
  }
  data[:joined_paths].each{|path|
    result[index][path[:color]-1] = 1
    colors_to_establish.delete(path[:color])
  }

  play_board.each do |row|
    puts row.each { |p| p }.join(" ")
  end
  p '*'*90

  next unless result[index].any?(&:nil?)
  x, y = play_board.find_index{ |row| !row.include?(' ') }, play_board.transpose.find_index{ |row| !row.include?(' ') }

  sort_by_color(coords_with_color.select{|coords| colors_to_establish.include?(coords[2])}).each do |points|
    first, second = points[0].take(2), points[1].take(2)
    first, second = [first[0]-1, first[1]-1], [second[0]-1, second[1]-1]

    if (x.nil? || ((first[0]>=x && second[0]>=x) || (first[0]<=x && second[0]<=x))) && (y.nil? || ((first[1]>=y && second[1]>=y) || (first[1]<=y && second[1]<=y))) && is_connectively?(first, second, play_board, points[0][2])
      result[index][points[0][2]-1] = 2
    else
      result[index][points[0][2]-1] = 3
    end
  end
end

p as_str(result)
