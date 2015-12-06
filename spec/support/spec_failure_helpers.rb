module SpecFailureHelpers

  def failure_message(input, expected, outcome)
    "   input: #{input}\nexpected: #{expected}\n     got: #{outcome}\n"
  end

end
