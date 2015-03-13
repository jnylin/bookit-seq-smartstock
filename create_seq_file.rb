#!/usr/bin/env ruby

require 'csv'

shelf_list, copies = ARGV

$f_shelf_list = File.open(shelf_list)
f_copies = File.open(copies)
f_seq = File.open("seq.txt","w")

copies = CSV.new(f_copies,{:headers=>:first_row,:col_sep=>";"})

def shelf_is_in_list(shelfMark)
	list = $f_shelf_list
	is_in_list = false

	list.rewind

	list.each_line do |line|
		line = line.rstrip.split(',')
		if line.include?(shelfMark)
			is_in_list = true
		end
	end

	return is_in_list
end

def get_shelf(shelfMark)
	if shelf_is_in_list(shelfMark)
		return shelfMark
	else
		get_shelf(shelfMark[0,shelfMark.length-1])
	end
end

# Check if the items shelf mark is in the shelf list
copies.each do |item|
	title = item.field(1)
	shelfMark = get_shelf(item.field(5))
	id = item.field(9)

	# I need to think about how to do the sorting

	puts "#{title},#{shelfMark},#{id}"
end
