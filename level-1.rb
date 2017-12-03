def parse_data(*data)
  [data[0],data[1],data[2], data[3..-1]]
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

rows, cols, size, points = parse_data(*ARGV.map(&:to_i))
last_in_rows = Array.new(rows+1){|index| (index)*cols }.push(0)
result_arr = []

points.each do |point|
  result_arr << calc_point_poz(point, last_in_rows)
end

p result_arr.flatten.join(', ').gsub(',', '')
