def isCharacter?(test)
    test.match?(/[[:alpha:]]/)
end

def firstInteger?(x)
    x[/\d+/]
end

def firstChar?(x)
    x.index(/[a-z]/)
end

def titleize?(str)
    str.split(/ |\_/).map(&:capitalize).join(" ")
  end

def findBPM?(blhNoteLength)
    145*blhNoteLength**3/-192+1895*blhNoteLength**2/64-77075*blhNoteLength/192+138125/64
end

def findGenLength?(bpm)
    -1777*bpm**3/14000910000+128449*bpm**2/466697000-12806713*bpm/70004550+21242435/466697
end

def nearest?(a,x)
    tmp = a.sort
    tmp << x
    tmp.sort!
    idx = tmp.index x
    tst1 = x - tmp[idx-1]
    tst2 = tmp[idx+1] - x
    if tst1 < tst2 then tmp[idx-1] else tmp[idx+1] end
end

notes = []
outputFirmware = "BLHeli32"

print "Are you convering from BLHeli32 to BlueJay? (Y/N): "
toBluejay = if gets.chomp.upcase == 'Y' then true else false end

if toBluejay # BLHeli32 to Bluejay
    outputFirmware = "Bluejay"
    octaveCalc = [];
    
    print "Enter the name of the tune: "
    tuneName = titleize?(gets.chomp).delete(' ')
    print "Enter the Gen. Length: "
    noteLength = gets.chomp.to_i
    if noteLength == nil then noteLength = 8 end
    print "Enter the Gen. Interval: "
    noteInterval = gets.chomp.to_i
    if noteInterval == nil then noteInterval = 0 end

    if noteInterval > 0 then
        noteInterval = 17 - noteInterval
        noteInterval = nearest?([1,2,4,8,16],noteInterval)

        puts "Interval: #{noteInterval}"
    end
    
    puts "Enter the BLHeli32 Music notation"
    notation = gets.chomp.downcase

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
        fi = firstInteger?(i)
        unless fi == nil
            idx = i.index(fi)
            note = i[(idx+1)..-1].delete(' ')
            case note
                when "1/1"
                    note = 1
                when "1/2"
                    note = 2
                when "1/4"
                    note = 4
                when "1/8"
                    note = 8
                when "1/16"
                    note = 16
                when "1/32"
                    note = 32
                when "1/64"
                    note = 64
                when "1/128"
                    note = 128
                else
                    note = note.to_i
            end

            if i[0] == "p"
                if note > 0 && note < noteLength then
                    pause = noteLength / note
                    notation += pause.to_s
                end
                notation += "p,"
            else
                octaveCalc.append(i[(idx),1].to_i)
                notation += note.to_s + i[0..idx] + ","
            end

            if noteInterval > 0 then
                notation+= "#{noteInterval}p,"
            end
        end
    end
    avgOctave = (octaveCalc.sum(0.0) / octaveCalc.size).round()
    notation = notation[0..-2]

    notation = "#{tuneName}:o=#{avgOctave},d=#{noteLength},b=#{findBPM?(noteLength)}:#{notation}"
else # Bluejay to BLHeli32
    puts "Enter the BlueJay Music notation"
    notation = gets.chomp

    durations = {1=>1, 2=>2, 3=>4, 4=>8, 5=>16, 6=>32}
    defaultOctave = 5
    defaultDuration = 8
    bpm = 120

    notationParts = notation.split(':')
    title = notationParts[0]
    
    notationParams = notationParts[1].split(',')
    notationParams.each do |i|
        case i[0,2].downcase
            when "o="
                defaultOctave = i[2..-1].to_i
            when "d="
                defaultDuration = i[2..-1].to_i
            when "b="
                bpm = i[2..-1].to_i
        end
    end

    durationOffset = 0
    while defaultDuration > 8
        durationOffset += 1
        defaultDuration /= 2
    end

    if bpm < 250 then
        interval = 250 - bpm
        if interval < 250 then interval = 250 end
        
        genLength = findGenLength?(250)
        genInterval = findGenLength?(interval)
    else
        genLength = findGenLength?(bpm)
        genInterval = 0
    end

    puts "Name: #{title} | Gen. Length #{genLength} | Gen. Interval #{genInterval}"

    notation = ""
    notes = notationParts[2].split(',')
    notes.each do |i|
        fc = firstChar?(i)
        fi = firstInteger?(i[fc..-1])
        lastIndex = -1 
        
        if i[-1] == '.' then lastIndex = -2 end

        notation += i[fc..lastIndex].upcase

        if fi == nil then notation += defaultOctave end
        
        if fc == 0 then 
            notation += " #{defaultDuration.to_s} "
        else
            durKey = durations.key(i[0..fc-1].to_i)
            durKey -= durationOffset
            if durKey < 1 then durKey = 1 end
            notation += " #{durations[durKey]} "
        end

        if lastIndex == -2 then
            notation += "P#{defaultDuration} "
        end
    end
end

puts "\nHere are the new notes for #{outputFirmware}"
puts notation