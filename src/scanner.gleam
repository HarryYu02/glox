import gleam/io
import gleam/list
import gleam/option.{type Option}
import gleam/string

pub type TokenType {
  // Single character tokens
  LeftParen
  RightParen
  LeftBrace
  RightBrace
  Comma
  Dot
  Minus
  Plus
  Semicolon
  Slash
  Star

  // One or Two character tokens
  Bang
  BangEqual
  Equal
  EqualEqual
  Greater
  GreaterEqual
  Less
  LessEqual

  // Literals
  Identifier
  Stringy
  Numbery

  // Keywords
  And
  Class
  Else
  Falsey
  Fun
  For
  If
  Nilly
  Or
  Print
  Return
  Super
  This
  Truey
  Var
  While

  EOF
}

pub type Token {
  Token(
    token_type: TokenType,
    lexeme: String,
    literal: Option(String),
    line: Int,
  )
}

pub fn token_type_to_string(token_type: TokenType) -> String {
  case token_type {
    LeftParen -> "LEFT_PAREN"
    RightParen -> "RIGHT_PAREN"
    LeftBrace -> "LEFT_BRACE"
    RightBrace -> "RIGHT_BRACE"
    Comma -> "COMMA"
    Dot -> "DOT"
    Minus -> "MINUS"
    Plus -> "PLUS"
    Semicolon -> "SEMICOLON"
    Slash -> ""
    Star -> "STAR"
    Bang -> ""
    BangEqual -> ""
    Equal -> ""
    EqualEqual -> ""
    Greater -> ""
    GreaterEqual -> ""
    Less -> ""
    LessEqual -> ""
    Identifier -> ""
    Stringy -> ""
    Numbery -> ""
    And -> ""
    Class -> ""
    Else -> ""
    Falsey -> ""
    Fun -> ""
    For -> ""
    If -> ""
    Nilly -> ""
    Or -> ""
    Print -> ""
    Return -> ""
    Super -> ""
    This -> ""
    Truey -> ""
    Var -> ""
    While -> ""
    EOF -> "EOF"
  }
}

pub fn token_to_string(token: Token) -> String {
  token_type_to_string(token.token_type)
  <> " "
  <> token.lexeme
  <> case token.literal {
    option.Some(literal) -> " " <> literal
    option.None -> " null"
  }
}

pub fn print_token(token: Token) -> Nil {
  io.println(token_to_string(token))
}

pub fn print_tokens(tokens: List(Token)) -> Nil {
  list.each(tokens, fn(token) { io.println(token_to_string(token)) })
}

pub fn scan_current_token(
  source: String,
  start: Int,
  current: Int,
  line: Int,
) -> List(Token) {
  case current >= string.length(source) {
    True -> [Token(EOF, "", option.None, line)]
    False ->
      case string.slice(source, current, 1) {
        "(" -> [
          Token(LeftParen, "(", option.None, line),
          ..scan_current_token(source, start + 1, current + 1, line)
        ]
        ")" -> [
          Token(RightParen, ")", option.None, line),
          ..scan_current_token(source, start + 1, current + 1, line)
        ]
        "{" -> [
          Token(LeftBrace, "{", option.None, line),
          ..scan_current_token(source, start + 1, current + 1, line)
        ]
        "}" -> [
          Token(RightBrace, "}", option.None, line),
          ..scan_current_token(source, start + 1, current + 1, line)
        ]
        "," -> [
          Token(Comma, ",", option.None, line),
          ..scan_current_token(source, start + 1, current + 1, line)
        ]
        "." -> [
          Token(Dot, ".", option.None, line),
          ..scan_current_token(source, start + 1, current + 1, line)
        ]
        "-" -> [
          Token(Minus, "-", option.None, line),
          ..scan_current_token(source, start + 1, current + 1, line)
        ]
        "+" -> [
          Token(Plus, "+", option.None, line),
          ..scan_current_token(source, start + 1, current + 1, line)
        ]
        ";" -> [
          Token(Semicolon, ";", option.None, line),
          ..scan_current_token(source, start + 1, current + 1, line)
        ]
        "*" -> [
          Token(Star, "*", option.None, line),
          ..scan_current_token(source, start + 1, current + 1, line)
        ]
        "\n" -> scan_current_token(source, start + 1, current + 1, line + 1)
        _ -> panic as "Unexpected character."
      }
  }
}

pub fn scan_tokens(source: String) -> List(Token) {
  scan_current_token(source, 0, 0, 1)
}
