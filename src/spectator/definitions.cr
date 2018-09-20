module Spectator
  module Definitions
    ALL = {} of Path => Object
    GROUPS = {} of String => ExampleGroup

    SPECIAL_CHARS = {
      '~' => "Tilde",
      '`' => "Tick",
      '!' => "Bang",
      '@' => "At",
      '#' => "Hash",
      '$' => "Dollar",
      '%' => "Percent",
      '^' => "Carret",
      '&' => "And",
      '*' => "Star",
      '(' => "LParen",
      ')' => "RParen",
      '+' => "Plus",
      '=' => "Eq",
      '{' => "LBrace",
      '}' => "RBrace",
      '[' => "LBracket",
      ']' => "RBracket",
      ':' => "Colon",
      ';' => "SColon",
      '<' => "Lt",
      '>' => "Gt",
      ',' => "Comma",
      '.' => "Dot",
      '?' => "Question",
      '/' => "Slash",
      '"' => "DQuote",
      '|' => "Or",
      '\\' => "BSlash",
      '\'' => "SQuote"
    }
  end
end
