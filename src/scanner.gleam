import gleam/int
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
  ParseError
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
    Bang -> "BANG"
    BangEqual -> "BANG_EQUAL"
    Equal -> "EQUAL"
    EqualEqual -> "EQUAL_EQUAL"
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
    ParseError -> ""
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
  case token.token_type {
    ParseError ->
      print_error("Unexpected character: " <> token.lexeme, token.line)
    _ -> io.println(token_to_string(token))
  }
}

pub fn print_tokens(tokens: List(Token)) -> Nil {
  list.each(tokens, fn(token) { print_token(token) })
}

pub fn print_error(error: String, line: Int) -> Nil {
  io.println_error("[line " <> int.to_string(line) <> "] Error: " <> error)
}

pub fn scan_current_token(
  source: String,
  start: Int,
  current: Int,
  line: Int,
) -> List(Token) {
  case current >= string.length(source) {
    True -> [Token(EOF, "", option.None, line)]
    False -> {
      let current_char = string.slice(source, current, 1)
      case current_char {
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
        "!" -> {
          let next_char = string.slice(source, current + 1, 1)
          case next_char {
            "" -> [
              Token(Bang, "!", option.None, line),
              Token(EOF, "", option.None, line),
            ]
            "=" -> [
              Token(BangEqual, "!=", option.None, line),
              ..scan_current_token(source, start + 2, current + 2, line)
            ]
            _ -> [
              Token(Bang, "!", option.None, line),
              ..scan_current_token(source, start + 1, current + 1, line)
            ]
          }
        }
        "=" -> {
          let next_char = string.slice(source, current + 1, 1)
          case next_char {
            "" -> [
              Token(Equal, "=", option.None, line),
              Token(EOF, "", option.None, line),
            ]
            "=" -> [
              Token(EqualEqual, "==", option.None, line),
              ..scan_current_token(source, start + 2, current + 2, line)
            ]
            _ -> [
              Token(Equal, "=", option.None, line),
              ..scan_current_token(source, start + 1, current + 1, line)
            ]
          }
        }
        "<" -> {
          let next_char = string.slice(source, current + 1, 1)
          case next_char {
            "" -> [
              Token(Bang, "!", option.None, line),
              Token(EOF, "", option.None, line),
            ]
            "=" -> [
              Token(BangEqual, "!=", option.None, line),
              ..scan_current_token(source, start + 2, current + 2, line)
            ]
            _ -> [
              Token(Bang, "*", option.None, line),
              ..scan_current_token(source, start + 1, current + 1, line)
            ]
          }
        }
        ">" -> {
          let next_char = string.slice(source, current + 1, 1)
          case next_char {
            "" -> [
              Token(Bang, "!", option.None, line),
              Token(EOF, "", option.None, line),
            ]
            "=" -> [
              Token(BangEqual, "!=", option.None, line),
              ..scan_current_token(source, start + 2, current + 2, line)
            ]
            _ -> [
              Token(Bang, "*", option.None, line),
              ..scan_current_token(source, start + 1, current + 1, line)
            ]
          }
        }
        " " | "\r" | "\t" ->
          scan_current_token(source, start + 1, current + 1, line)
        "\n" -> scan_current_token(source, start + 1, current + 1, line + 1)
        _ -> {
          [
            Token(ParseError, current_char, option.None, line),
            ..scan_current_token(source, start + 1, current + 1, line)
          ]
        }
      }
    }
  }
}

pub fn scan_tokens(source: String) -> List(Token) {
  scan_current_token(source, 0, 0, 1)
}
