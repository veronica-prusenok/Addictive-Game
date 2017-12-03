def parse_data(*data)
  [data[0],data[1],data[2], data[3..-1].each_slice(2).to_a]
end

def calc_point_poz(point, last_in_rows)
  x, y = 0, 0

  last_in_rows.each_with_index do |last_in_row, i|
    if i != last_in_rows.size-1 && point.between?(last_in_row+1, last_in_rows[i+1])
      x = i+1
      y = ((last_in_rows[i]+1)..last_in_rows[i+1]).to_a.index(point)
    end
  end
  [x,y+1]
end

def distance_for(p1,p2)
  (p1[0] - p2[0]).abs + (p1[1] - p2[1]).abs
end

rows, cols, size, points_with_color = parse_data(*ARGV.map(&:to_i))
last_in_rows = Array.new(rows+1){|index| (index)*cols }.push(0)
coords_with_color = []
result_arr = []

points_with_color.each do |point|
  coords_with_color << calc_point_poz(point[0], last_in_rows) + [point[1]]
end

sorted_arr = coords_with_color.sort_by(&:last).each_slice(2).to_a

sorted_arr.each do |points|
  result_arr << distance_for(points[0].take(2), points[1].take(2))
end

p result_arr.join(', ').gsub(',', '')
