import gleam/io
import gleam/list
import gleam/option

import scanner.{type Token}

pub type LiteralType {
  Boolean
  LoxNumber
  LoxString
  LoxNil
}

pub type Expr {
  Binary(left: Expr, op: Token, right: Expr)
  Grouping(expr: Expr)
  Literal(value: option.Option(String), val_type: LiteralType)
  Unary(op: Token, right: Expr)
}

pub fn expr_to_string(expr: Expr) -> String {
  case expr {
    Binary(left, op, right) ->
      "("
      <> op.lexeme
      <> " "
      <> expr_to_string(left)
      <> " "
      <> expr_to_string(right)
      <> ")"
    Grouping(expr) -> "(group " <> expr_to_string(expr) <> ")"
    Literal(value, _) ->
      case value {
        option.Some(literal) -> literal
        option.None -> "nil"
      }
    Unary(op, right) -> "(" <> op.lexeme <> " " <> expr_to_string(right) <> ")"
  }
}

pub fn print_expr(expr: Expr) -> Nil {
  io.println(expr_to_string(expr))
}

pub fn parse_tokens(tokens: List(Token)) -> Expr {
  let current_token = list.first(tokens)
  case current_token {
    Error(Nil) -> todo as "empty"
    Ok(scanner.Token(scanner.BangEqual, ..))
    | Ok(scanner.Token(scanner.EqualEqual, ..)) -> {
      todo as "equality"
    }
    Ok(scanner.Token(scanner.Greater, ..))
    | Ok(scanner.Token(scanner.GreaterEqual, ..))
    | Ok(scanner.Token(scanner.Less, ..))
    | Ok(scanner.Token(scanner.LessEqual, ..)) -> todo as "comparison"
    Ok(scanner.Token(scanner.Minus, ..)) | Ok(scanner.Token(scanner.Plus, ..)) ->
      todo as "term"
    Ok(scanner.Token(scanner.Slash, ..)) | Ok(scanner.Token(scanner.Star, ..)) ->
      todo as "factor"
    Ok(scanner.Token(scanner.Bang, ..)) | Ok(scanner.Token(scanner.Minus, ..)) ->
      todo as "unary"
    Ok(scanner.Token(scanner.Falsey, ..)) ->
      Literal(option.Some("false"), Boolean)
    Ok(scanner.Token(scanner.Truey, ..)) ->
      Literal(option.Some("true"), Boolean)
    Ok(scanner.Token(scanner.Nilly, ..)) -> Literal(option.Some("nil"), LoxNil)
    Ok(scanner.Token(scanner.Numbery, _, literal, _)) ->
      Literal(literal, LoxNumber)
    Ok(scanner.Token(scanner.Stringy, _, literal, _)) ->
      Literal(literal, LoxString)
    Ok(scanner.Token(scanner.LeftParen, ..)) -> {
      let #(in_paren, rest_with_right_paren) =
        list.split_while(list.drop(tokens, 1), fn(token) {
          token.token_type != scanner.RightParen
        })
      let rest = list.drop(rest_with_right_paren, 1)
      case rest {
        [] -> todo as "no right paren error"
        _ -> Grouping(parse_tokens(in_paren))
      }
      todo
    }
    _ -> {
      todo as "unknown"
    }
  }
}

pub fn parse_source(source: String) {
  let tokens = scanner.scan_tokens(source)
  let tokens_without_errors = list.filter(tokens, scanner.is_token_valid)
  parse_tokens(tokens_without_errors)
}
