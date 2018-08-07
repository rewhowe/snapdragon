class String
  [
    [ 'red',    31 ],
    [ 'green',  32 ],
    [ 'yellow', 33 ],
    [ 'blue',   34 ],
    [ 'pink',   35 ],
    [ 'lblue',  36 ],
  ].each do |colour, code|
    define_method(colour) do
      "\e[#{code}m#{self}\e[0m"
    end
  end
end
