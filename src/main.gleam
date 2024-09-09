import gleam/io
import gleam/list
import gleam/string

import argv
import simplifile

import scanner

pub fn main() {
  // You can use print statements as follows for debugging, they'll be visible when running tests.
  io.println_error("Logs from your program will appear here!")

  let args = argv.load().arguments

  case args {
    ["tokenize", filename] -> {
      case simplifile.read(filename) {
        Ok(contents) -> {
          case string.length(contents) {
            // Uncomment this line to pass the first stage
            0 -> io.println("EOF  null")
            _ -> {
              let tokens = scanner.scan_tokens(contents)
              scanner.print_tokens(tokens)
              case
                list.any(tokens, fn(token) {
                  token.token_type == scanner.ParseError
                })
              {
                True -> exit(65)
                False -> exit(0)
              }
            }
          }
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

@external(erlang, "init", "stop")
pub fn stop(code: Int) -> Nil
