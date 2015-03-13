#!/usr/bin/env ruby

# The CSV file can't have empty lines!
# The CSV file can't have quoting
# Problem: Tecken och verklighet ; Samtal om Gud ; Ecce Homo

require 'csv'

shelf_list, copies = ARGV

$f_shelf_list = File.open(shelf_list)
f_copies = File.open(copies,"r:utf-8") # Do it re
f_seq = File.open("seq.txt","w")

copies = CSV.new(f_copies,{:headers=>:first_row,:col_sep=>";"})
shelves = Hash.new

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
		get_shelf(shelfMark[0,shelfMark.length-1]) #undefined method 'length' for nil
	end
end

# Initialize the shelves Hash
$f_shelf_list.each_line do |line|
	line = line.rstrip.split(',')
	line.each do |shelf|
		shelves[shelf] = []
	end
end

# Check if the items shelf mark is in the shelf list
# if not get the correct location
copies.each do |item|
	main_entry = item.field(1)[/\w.*/] # 'Irāqī, Fakhr al-Din Ibrāhīm
	shelf = get_shelf(item.field(5)) 
	label = item.field(9)
	shelves[shelf].push(["#{main_entry}","#{label}"])
end

# Sort the sequence
f_seq.puts "id"
shelves.each do |key, value|
	if value.length > 0
		arr_shelf = value.sort! {|x,y| x[0].downcase.gsub('w','v') <=> y[0].downcase.gsub('w','v') }
		arr_shelf.each do |book|
			if /^\d/.match(book[0]) # Sort numbers after letters
				arr_shelf.push(arr_shelf.shift)
			else
				break
			end
		end
		# Write label to sequence file and print main entry to STDOUT
		puts "\n#{key}\n"
		arr_shelf.each do |book|
			f_seq.puts book[1]
			puts book[0]
		end
	end
end
