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
require 'unicode_utils/compatibility_decomposition'
require 'unicode_utils/general_category'

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

def normalize(entry)
	str = ""

	entry.each_codepoint do |c|
		case c

		when 256..(1.0/0.0) # 
			unicode_char = UnicodeUtils.compatibility_decomposition([c].pack('U').to_s).split('').select do |unicode_c|
				UnicodeUtils.general_category(unicode_c) =~ /Letter|Separator|Punctation|Number/
			end.join
			str << unicode_char
		when 48..57
			str << c+198 # Sortera siffror efter bokstäver, vi lånar slutet av teckentabellen
		when 39 # 'Iraqi..
		when 87, 119 # Sortera w som w
			str << c-1
		when 196, 228 # ä ligger före å i teckentabellen
			str << c+2
		else
			str << c
		end
		
	end

	return str
end

def sort_shelf(arr)
	#arr_shelf = value.sort_by! { |book| book[0].split(/(\d+)/).map { |v| v =~ /\d+/ ? v.to_i : v } }
	#arr_shelf.each do |book|
		#if /^\d+\b/.match(book[0]) # Sort numbers after letters
			#arr_shelf.push(arr_shelf.shift)
		#else
			#break
		#end
	#end
	#
	# TODO: natural sorting (and remove numbers from normalize function)
	
	return arr.sort
end

#### Main

$f_shelf_list = File.open(shelf_list)
f_copies = File.open(copies,"r:utf-8") # BOOK-IT saves the CSV in ISO-8859-1 but we want to be able to sort all languages
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
copies.each do |item|
	main_entry = item.field(1)
	main_entry_normalized = normalize(main_entry)
	shelf = get_shelf(item.field(5)) 
	label = item.field(9)

	shelves[shelf].push(["#{main_entry_normalized}","#{label}","#{main_entry}"])
end

# Sort the sequence and write sequence file
f_seq.puts "id"
shelves.each do |key, value|
	if value.length > 0
		# The actual sorting
		arr_shelf = sort_shelf(value)

		# Write label to sequence file and print main entry to STDOUT
		puts "\n#{key}\n"
		arr_shelf.each do |book|
			f_seq.puts book[1]
			puts book[2] # Print the original main entry
		end
	end
end
