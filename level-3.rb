def parse_data(*data)
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

def calc_points_poz_with_color(rows, cols, arr)
  last_in_rows = Array.new(rows+1){|index| (index)*cols }.push(0)
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

rows, cols, size, points_with_color, num_of_paths, paths = parse_data(*ARGV.map(&:to_i))
coords_with_color = calc_points_poz_with_color(rows, cols, points_with_color)
distances_by_color = calc_distances_by_color(coords_with_color)

p as_str(distances_by_color)
