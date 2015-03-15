#!/usr/bin/env ruby
# Copyright 2015 Jakob Nylin (jakob [dot] nylin [at] gmail [dot] com)
# All rights reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'csv'

shelf_list, copies = ARGV

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

$f_shelf_list = File.open(shelf_list)
f_copies = File.open(copies,"r:utf-8")
f_seq = File.open("seq.txt","w")

copies = CSV.new(f_copies,{:headers=>:first_row,:col_sep=>";"})
shelves = Hash.new

# Initialize the shelves Hash
$f_shelf_list.each_line do |line|
	line = line.rstrip.split(',')
	line.each do |shelf|
		shelves[shelf] = []
	end
end

# Place item on correct shelf
# TODO: Check for quotes and ; in the main entry
copies.each do |item|
	main_entry = item.field(1)[/\w.*/] # 'Irāqī, Fakhr al-Din Ibrāhīm
	shelf = get_shelf(item.field(5)) 
	label = item.field(9)
	shelves[shelf].push(["#{main_entry}","#{label}"])
end

# Sort the sequence and write sequence file
f_seq.puts "id"
shelves.each do |key, value|
	if value.length > 0
		# The actual sorting
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
