module Spectator
  module ContextDefinitions
    ALL = {} of Path => Object
    MAPPING = {} of String => Context

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
