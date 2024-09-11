import gleam/io
import gleam/list

import argv
import simplifile

import parser
import scanner

pub fn main() {
  let args = argv.load().arguments

  case args {
    ["tokenize", filename] -> {
      case simplifile.read(filename) {
        Ok(contents) -> {
          let tokens = scanner.scan_tokens(contents)
          scanner.print_tokens(tokens)
          case list.any(tokens, fn(token) { !scanner.is_token_valid(token) }) {
            True -> exit(65)
            False -> exit(0)
          }
        }
        Error(error) -> {
          io.println_error("Error: " <> simplifile.describe_error(error))
          exit(1)
        }
      }
    }
    ["parse", filename] -> {
      case simplifile.read(filename) {
        Ok(contents) -> {
          let parsed_expr = parser.parse_source(contents)
          parser.print_expr(parsed_expr)
          exit(0)
        }
        Error(error) -> {
          io.println_error("Error: " <> simplifile.describe_error(error))
          exit(1)
        }
      }
    }
    _ -> {
      io.println_error("Usage: ./your_program.sh tokenize <filename>")
      exit(1)
    }
  }
}

@external(erlang, "erlang", "halt")
pub fn exit(code: Int) -> Nil
