def validate_words(word_to_transform, word_to_end, hashed_dictionary)
  (hashed_dictionary[word_to_transform.length].include? word_to_transform) && (hashed_dictionary[word_to_end.length].include? word_to_end)
end

def query_dictionary(word_to_look, hashed_dictionary)
  regexp = Regexp.new("^#{word_to_look.gsub("?", ".")}$")
  hashed_index = 0
  begin
    hashed_index = hashed_dictionary.index(regexp, hashed_index)
    if hashed_index
      yield hashed_dictionary[hashed_index, word_to_look.size]
      hashed_index += word_to_look.size + 1
    end
  end while hashed_index
end

def check_hashed_dictionary(word_to_look, hashed_dictionary)
  query_dictionary(word_to_look, hashed_dictionary[word_to_look.length]) do |word_inside_hash|
    yield word_inside_hash
  end
end

def calculate_possible_words(word_to_transform, hashed_dictionary)
  possible_words_array = Array.new

  #Checking for length - 1 words
  (0..word_to_transform.size-1).each do |i|
    replaced_word = word_to_transform.gsub(word_to_transform[i],"")
    possible_words_array << replaced_word if ( hashed_dictionary[word_to_transform.length-1].include? replaced_word )
  end

  #Checking for same length words
  (0..word_to_transform.size-1).each do |i|
    replaced_word = word_to_transform.gsub(word_to_transform[i],"?")
    check_hashed_dictionary(replaced_word, hashed_dictionary) do |checking_word|
      possible_words_array << checking_word
    end
  end

  #Checking for length  + 1 words
  (0..word_to_transform.size).each do |i|
    replaced_word = word_to_transform.split('').insert(i,"?").join('')
    check_hashed_dictionary(replaced_word, hashed_dictionary) do |checking_word|
      possible_words_array << checking_word
    end
  end

  possible_words_array.uniq!.sort - [word_to_transform]
end

def levenshtein_distance_algorithm(word_to_transform, word_to_end)
  return 0 if word_to_transform == word_to_end
  word_to_end = word_to_end.to_s
  distance = Array.new(word_to_transform.size + 1, 0)
  (0..word_to_transform.size).each do |i|
    distance[i] = Array.new(word_to_end.size + 1)
    distance[i][0] = i
  end
  (0..word_to_end.size).each do |j|
    distance[0][j] = j
  end
  (1..word_to_transform.size).each do |i|
    (1..word_to_end.size).each do |j|
      distance[i][j] = [distance[i - 1][j] + 1,
                        distance[i][j - 1] + 1,
                        distance[i - 1][j - 1] + ((word_to_transform[i - 1] == word_to_end[j - 1]) ? 0 : 1)].min
    end
  end
  distance[word_to_transform.size][word_to_end.size]
end

def reorder_graph(graph,word_to_end)
  graph.sort_by { |node| node.length + levenshtein_distance_algorithm(node.last, word_to_end) }
end

def populating_graph(word_to_transform, word_to_end, hashed_dictionary)
  word_chain_graph = [[word_to_transform]]
  until word_chain_graph.empty? or levenshtein_distance_algorithm(word_chain_graph.first.last, word_to_end) == 1
    shifted_word = word_chain_graph.shift
    possibleWords = calculate_possible_words(shifted_word.last, hashed_dictionary)
    possibleWords.each { |x| word_chain_graph << (shifted_word.dup << x) }
    word_chain_graph = reorder_graph(word_chain_graph,word_to_end)
  end
  result = word_chain_graph.empty? ? Array.new : (word_chain_graph.shift << word_to_end)
end

p 'Ruby Algorith begins'

print 'The word to transform is? '
word_to_transform = gets.chomp

print 'The final word to get is? '
word_to_end = gets.chomp

p 'Loading Dictionary'
hashed_dictionary = Hash.new("")
File.read("dictionary.txt").each_line do |current_word|
  hashed_dictionary[current_word.length-1] += current_word
end
if validate_words(word_to_transform, word_to_end, hashed_dictionary)
  p 'All entries are in dictionary'
  p 'Word Chain Process starts now'
  start_time = Time.now
  p 'Using Levenshtein distance algorithm we are going to create our graph'
  word_chain_result = populating_graph(word_to_transform, word_to_end, hashed_dictionary)
  p ( word_chain_result.empty? ? "No chain found between #{word_to_transform} and #{word_to_end}." : word_chain_result.join(" -> ") )
  p "Word Chain Process ended in #{Time.now - start_time} seconds"
else
  p 'An entry is not in the dictionary'
end