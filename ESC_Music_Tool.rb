def isCharacter?(test)
    test.match?(/[[:alpha:]]/)
end

def firstInteger?(x)
    x[/\d+/]
end

notes = []
outputFirmware = "BLHeli32"

print "Are you convering from BLHeli32 to BlueJay? (Y/N): "
toBluejay = if gets.chomp.upcase == 'Y' then true else false end

if toBluejay
    outputFirmware = "Bluejay"
    puts "Enter the BLHeli32 Music notation"
    notation = gets.chomp

    note = ""
    notation.each_char do |i|
        if isCharacter?(i) && (i != '#' && i != '/')
            unless note == ""
                notes.append(note)
            end
            note = i
        else
            note += i
        end
    end
    notes.append(note)

    notation = ""
    notes.each do |i|
        if i[0] == "P"
            notation = notation[0..-2] 
            notation += ".,"
        else
            fi = firstInteger?(i)
            unless fi == nil
                idx = i.index(fi)
                note = i[(idx+1)..-1].delete(' ')
                case note
                when "1/2"
                    note = "2"
                when "1/4"
                    note = "4"
                when "1/8"
                    note = 8
                when "1/16"
                    note = 16
                end

                notation += note + i[0..idx] + ","
            end
        end
    end
    notation = notation[0..-2]
else
    puts "Enter the BlueJay Music notation"
    notation = gets.chomp
end

puts "\nHere are the new notes for #{outputFirmware}"
puts notation