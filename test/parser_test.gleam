import gleam/option
import gleeunit/should
import parser
import scanner

pub fn expr_to_string_test() {
  parser.expr_to_string(parser.Binary(
    parser.Unary(
      scanner.Token(scanner.Minus, "-", option.None, 1),
      parser.Literal(option.Some("123"), parser.LoxNumber),
    ),
    scanner.Token(scanner.Star, "*", option.None, 1),
    parser.Grouping(parser.Literal(option.Some("45.67"), parser.LoxNumber)),
  ))
  |> should.equal("(* (- 123) (group 45.67))")
}
