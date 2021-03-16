class String
  [
    ['red',     31],
    ['green',   32],
    ['yellow',  33],
    ['blue',    34],
    ['pink',    35],
    ['purple',  36],
    ['lred',    91],
    ['lgreen',  92],
    ['lyellow', 93],
    ['lblue',   94],
    ['lpink',   95],
    ['lpurple', 96],
  ].each do |colour, code|
    define_method(colour) do
      "\e[#{code}m#{self}\e[0m"
    end
  end

  def numeric?
    !Float(self).nil?
  rescue
    false
  end
end
