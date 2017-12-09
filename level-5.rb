def parse_data(data)
  (0..(data[2].to_i*2)+3).each{|el| data[el] = data[el].to_i}
  [data[0],data[1],data[2], data[3..(data[2]*2)+2].each_slice(2).to_a, data[(data[2]*2)+3], data[(data[2]*2)+4..-1]]
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

p 'start'
data = ''
File.open('level4/level4-5.in').each do |line|
  data << line
end
rows, cols, size, points_with_color, num_of_paths, paths = parse_data(data.split(" "))
coords_with_color = calc_points_poz_with_color(points_with_color, cols)
distances_by_color = calc_distances_by_color(coords_with_color)
result = []

p 'start joins'

joined_paths = join_paths(num_of_paths, paths)

p 'start board'

play_board = apply_points(coords_with_color, Array.new(rows){Array.new(cols, ' ')})

p 'start paths'

joined_paths.each do |path|
  board = play_board.map(&:clone)
  start_coords = poz_of_point(path[:start_poz], cols)
  start_coords[0], start_coords[1] = start_coords[0]-1, start_coords[1]-1
  res = apply_moves(board, start_coords, path[:steps], path[:color])

  play_board = res[2] if res[0] == 1
end

p 'file write'


File.open('test.txt','w'){ |f| f << play_board.map{ |row| row.map{|cell| cell == ' ' ? ' ' : '*'}.join('') }.join("\n") }
