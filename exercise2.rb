def get_words_from_dictionary
  File.readlines('dictionary.txt').map { |item| item.chomp }
end

def validate_words(word_to_transform, word_to_end)
  (get_words_from_dictionary.include? word_to_transform) && (get_words_from_dictionary.include? word_to_end)
end

def reducing_dictionary(longest_word)
  get_words_from_dictionary.select { |item| (item.length >= longest_word.length - 1) && (item.length <= longest_word.length + 1) }
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

def populating_graph(word_to_transform, word_to_end, reducedDictionary)
  word_chain_graph = [[word_to_transform]]
  until word_chain_graph.empty? or levenshtein_distance_algorithm(word_chain_graph.first.last, word_to_end) == 1
    shifted_word = word_chain_graph.shift
    possibleWords = reducedDictionary.select { |current_word_in_dictionary| levenshtein_distance_algorithm(shifted_word.last, current_word_in_dictionary) == 1 && !(shifted_word.include? current_word_in_dictionary) }
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

if validate_words(word_to_transform, word_to_end)
  p 'All entries are in dictionary'
  p 'Word Chain Process starts now'
  start_time = Time.now
  p "First Filter: Words that its length is +-1 the longest word between entries"
  reducedDictionary = reducing_dictionary(word_to_transform > word_to_end ? word_to_transform : word_to_end)
  p 'Using Levenshtein distance algorithm we are going to create our graph'
  word_chain_result = populating_graph(word_to_transform, word_to_end, reducedDictionary)
  p ( word_chain_result.empty? ? "No chain found between #{word_to_transform} and #{word_to_end}." : word_chain_result.join(" -> ") )
  p "Word Chain Process ended in #{Time.now - start_time} seconds"
else
  p 'An entry is not in the dictionary'
end