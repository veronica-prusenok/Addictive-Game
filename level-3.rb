def parse_data(*data)
  (0..(data[2].to_i*2)+3).each{|el| data[el] = data[el].to_i}
  [data[0],data[1],data[2], data[3..(data[2]*2)+2].each_slice(2).to_a, data[(data[2]*2)+3], data[(data[2]*2)+4..-1]]
end

def poz_of_point(point, last_in_rows)
  x, y = 0, 0

  last_in_rows.each_with_index do |last_in_row, i|
    if i != last_in_rows.size-1 && point.between?(last_in_row+1, last_in_rows[i+1])
      x = i+1
      y = (((last_in_rows[i]+1)..last_in_rows[i+1]).to_a.index(point)) + 1
    end
  end
  [x,y]
end

def calc_points_poz_with_color(arr, last_in_rows)
  temp = []
  arr.each do |point|
    temp << poz_of_point(point[0], last_in_rows) + [point[1]]
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
  return {status: -1} if move_to[0] < 0 || move_to[1] < 0 || move_to[0] >= rows || move_to[1] >= cols || (board[move_to[0]][move_to[1]] != nil && board[move_to[0]][move_to[1]] != color)

  if board[move_to[0]][move_to[1]] == color
    return {status: 1, board: board}
  else
    board[move_to[0]][move_to[1]] = -1
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
      return [1, i+1, res[:board]]
    when 0
      old_board = res[:board]
      old_coords = res[:current_poz]
    end
  end

end

rows, cols, size, points_with_color, num_of_paths, paths = parse_data(*ARGV)
last_in_rows = Array.new(rows+1){|index| (index)*cols }.push(0)
coords_with_color = calc_points_poz_with_color(points_with_color, last_in_rows)
distances_by_color = calc_distances_by_color(coords_with_color)

joined_paths = join_paths(num_of_paths, paths)

play_board = apply_points(coords_with_color, Array.new(rows){Array.new(cols)})

p play_board

joined_paths.each do |path|
  start_coords = poz_of_point(path[:start_poz],last_in_rows)
  start_coords[0], start_coords[1] = start_coords[0]-1, start_coords[1]-1

  p result = apply_moves(play_board, start_coords, path[:steps], path[:color])
end
