def parse_data(data)
  (0..(data[2].to_i*2)+3).each{|el| data[el] = data[el].to_i}
  points_x_2 = data[2]*2
  [data[0],data[1],data[2],data[3..points_x_2+2].each_slice(2).to_a, data[points_x_2+3], data[points_x_2+4..-1]]
end

def poz_of_point(point, width)
  i = point - 1
  x, y = i / width, i % width
  [x,y]
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
    board[point[0]][point[1]] = point[2]
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

def can_move(board, point, width, color, paths)
  x,y = poz_of_point(point, width)

  moves = []
  rows = board.size
  cols = board.first.size

  n = [point_by_coords(x-1, y, width), [x-1, y]]
  s = [point_by_coords(x+1, y, width) ,[x+1, y]]
  w = [point_by_coords(x, y-1, width), [x, y-1]]
  e = [point_by_coords(x, y+1, width), [x, y+1]]

  moves << n if x-1 >= 0 && (board[x-1][y] == ' ' || (board[x-1][y] == 'o' && paths.any?{ |path| path.first[:color] == color && path.first[:move_to].include?(n.first) }) || (board[x-1][y] == color && !paths.any?{ |path| path.first[:parent] == n.first }))
  moves << s if x+1 < rows && (board[x+1][y] == ' ' || (board[x+1][y] == 'o' && paths.any?{ |path| path.first[:color] == color && path.first[:move_to].include?(s.first) }) || (board[x+1][y] == color && !paths.any?{ |path| path.first[:parent] == s.first }))
  moves << w if y-1 >= 0 && (board[x][y-1] == ' ' || (board[x][y-1] == 'o' && paths.any?{ |path| path.first[:color] == color && path.first[:move_to].include?(w.first) }) || (board[x][y-1] == color && !paths.any?{ |path| path.first[:parent] == w.first }))
  moves << e if y+1 < cols && (board[x][y+1] == ' ' || (board[x][y+1] == 'o' && paths.any?{ |path| path.first[:color] == color && path.first[:move_to].include?(e.first) }) || (board[x][y+1] == color && !paths.any?{ |path| path.first[:parent] == e.first }))

  moves
end

def move_by_points(point1, point2)
  return 'W' if point1 == point2 + 1
  return 'E' if point1 == point2 - 1
  return 'N' if point1 > point2
  return 'S' if point1 < point2
end

def apply_sure_moves(points_with_color, board, cols)
  points_to_check = points_with_color.map{|point, color| [point,color,point]}
  points_to_check_dup = points_to_check
  paths = []

  1000.times do
    points_to_check = points_to_check.uniq
    points_to_check.each do |point, color, parent|
      if points_to_check_dup.include?([point, color, parent])
        possible_moves = can_move(board, point, cols, color, paths)

        if possible_moves.size == 1
          move = possible_moves.first.first
          new_x, new_y = possible_moves.first.last
          cur_x, cur_y = poz_of_point(point, cols)

          points_to_check_dup -= [[point, color, parent]]

          if board[new_x][new_y] != 'o' || paths.any?{|path| path.first[:move_to].include?(move)}
            if paths.any?{|path| path.first[:parent] == parent}
              paths.select{|path| path.first[:parent] == parent}.first.first[:move_to] << move
            else
              paths << [{color: color, parent: parent, move_to: [parent, move]}]
            end
            cur_path = paths.select{|path| path.first[:parent] == parent}.first.first
            board[cur_x][cur_y] = 0 if board[cur_x][cur_y] == 'o'

            if board[new_x][new_y] == ' '
              points_to_check_dup << [move, color, parent]
              board[new_x][new_y] = 'o'
            elsif board[new_x][new_y] == color
              if move < parent
                cur_path[:parent] = move
                cur_path[:move_to].reverse!
              end
              points_to_check_dup -= [[move, color, move]]
            elsif board[new_x][new_y] == 'o'
              cross_path = paths.select{|path| path.first[:move_to].include?(move) && path.first[:parent] != parent}.first.first
              board[new_x][new_y] = 0 if board[new_x][new_y] == 'o'
              if cross_path[:parent] < parent
                cross_path[:move_to] = cross_path[:move_to] - [move] + cur_path[:move_to].reverse
                paths -= [[cur_path]]
              else
                cur_path[:move_to] = cur_path[:move_to] - [move] + cross_path[:move_to].reverse
                paths -= [[cross_path]]
              end
              points_to_check_dup.each{|point_to_check| points_to_check_dup -= [point_to_check] if point_to_check.last == cross_path[:parent] || point_to_check.last == parent }
            end
          end
          points_to_check = points_to_check_dup
        end
      end
    end
  end
  paths
end

def is_board_has_holes?(board)
  board.any?{|row| row.include?(' ')}
end

data = ''
File.open('level7/level7-3.in').each do |line|
  data << line
end
data = data.split(" ")
tests_num = data.slice!(0).to_i
rest = data
result = Array.new(tests_num)
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

  paths = apply_sure_moves(data[:points_with_color], play_board, data[:cols])


  p paths.size == data[:size]/2
  p !is_board_has_holes?(play_board)
  play_board.each do |str|
    puts str.join(', ').gsub(',', '')
  end
  result[index] = paths
end

result_str = tests_num.to_s
result.each do |paths|
  result_str += ' ' + paths.size.to_s + ' '

  resss = []
  paths.sort_by{|el| [el.first[:color], el.first[:parent]]}.each do |el|
    resss << el.first[:color]
    resss << el.first[:parent]
    resss << el.first[:move_to].size - 1
    resss << el.first[:move_to].map.with_index{|point, index| move_by_points(point, el.first[:move_to][index+1]) if index + 1 < el.first[:move_to].size }[0..-2]
  end

  result_str += resss.join(', ').gsub(',', '')
end

p result_str
